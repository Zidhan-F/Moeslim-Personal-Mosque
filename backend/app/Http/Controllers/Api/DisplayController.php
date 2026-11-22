<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\DomainRuleException;
use App\Http\Controllers\Controller;
use App\Models\DisplayDevice;
use App\Models\DisplayPairingCode;
use App\Models\Mosque;
use App\Services\DisplayContent;
use App\Support\Audit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class DisplayController extends Controller
{
    public function index(Mosque $mosque): JsonResponse
    {
        $settings = array_replace_recursive(Mosque::DEFAULT_SETTINGS, $mosque->settings ?? []);

        return response()->json([
            'data' => $mosque->displayDevices()->orderByDesc('status')->orderBy('id')->get(),
            'limit' => Mosque::MAX_DISPLAYS,
            'mosque_settings' => [
                'display_show_finance' => (bool) $settings['display_show_finance'],
                'display_show_qris' => (bool) $settings['display_show_qris'],
                'qris_label' => (string) $settings['qris_label'],
                'iqamah_minutes' => $settings['iqamah_minutes'],
                'praying_minutes' => $settings['praying_minutes'],
                'silent_prayer_screen' => (bool) $settings['silent_prayer_screen'],
                'silent_prayer_message' => (string) $settings['silent_prayer_message'],
                'iqamah_beep' => (bool) $settings['iqamah_beep'],
            ],
            'qris' => [
                'has_image' => $mosque->qris_image_path !== null,
                'enabled' => (bool) $settings['display_show_qris'] && $mosque->qris_image_path !== null,
                'label' => (string) $settings['qris_label'],
            ],
            'override' => $mosque->activeDisplayOverride(),
        ]);
    }

    public function updateSettings(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate([
            'display_show_finance' => ['sometimes', 'boolean'],
            'display_show_qris' => ['sometimes', 'boolean'],
            'qris_label' => ['sometimes', 'string', 'max:100'],
            'iqamah_minutes' => ['sometimes', 'array'],
            'iqamah_minutes.*' => ['integer', 'between:0,60'],
            'praying_minutes' => ['sometimes', 'array'],
            'praying_minutes.*' => ['integer', 'between:1,120'],
            'silent_prayer_screen' => ['sometimes', 'boolean'],
            'silent_prayer_message' => ['sometimes', 'string', 'max:160'],
            'iqamah_beep' => ['sometimes', 'boolean'],
        ]);

        $mosque->update([
            'settings' => array_replace_recursive($mosque->settings ?? [], $data),
        ]);
        Audit::log($mosque, 'display.settings_updated', $mosque, array_keys($data));

        return response()->json([
            'data' => array_replace_recursive(Mosque::DEFAULT_SETTINGS, $mosque->fresh()->settings ?? []),
        ]);
    }

    public function setOverride(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate([
            'type' => ['required', 'in:duka,darurat'],
            'title' => ['required', 'string', 'max:120'],
            'body' => ['required', 'string', 'max:500'],
            'duration_minutes' => ['required', 'integer', 'between:5,1440'],
        ]);

        $override = [
            'type' => $data['type'],
            'title' => $data['title'],
            'body' => $data['body'],
            'created_by_name' => $request->user()->name,
            'started_at' => now()->toIso8601String(),
            'expires_at' => now()->addMinutes($data['duration_minutes'])->toIso8601String(),
        ];

        $mosque->forceFill(['display_override' => $override])->save();
        Audit::log($mosque, 'display.override_set', $mosque, ['type' => $data['type'], 'title' => $data['title']]);

        return response()->json(['data' => $override]);
    }

    public function clearOverride(Mosque $mosque): JsonResponse
    {
        $mosque->forceFill(['display_override' => null])->save();
        Audit::log($mosque, 'display.override_cleared', $mosque);

        return response()->json(['data' => null]);
    }

    public function uploadQris(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate([
            'file' => ['required', 'file', 'max:2048', 'mimes:jpg,jpeg,png,webp'],
            'label' => ['nullable', 'string', 'max:100'],
        ]);

        $file = $request->file('file');
        $bytes = (int) $file->getSize();
        $disk = config('filesystems.attachments_disk', 'local');

        $mosque = DB::transaction(function () use ($mosque, $file, $bytes, $disk, $data) {
            $locked = Mosque::whereKey($mosque->id)->lockForUpdate()->firstOrFail();
            $netDelta = $bytes - (int) $locked->qris_image_bytes;
            if ($locked->storage_used_bytes + $netDelta > Mosque::STORAGE_QUOTA_BYTES) {
                throw new DomainRuleException('storage_quota_exceeded', 'Kuota penyimpanan 1 GB penuh.');
            }
            if ($locked->qris_image_path) {
                Storage::disk($disk)->delete($locked->qris_image_path);
            }
            $ext = $file->extension() ?: 'png';
            $path = Storage::disk($disk)->putFileAs("mosques/{$locked->id}/qris", $file, Str::ulid().'.'.$ext);

            $settings = $locked->settings ?? [];
            $settings['display_show_qris'] = true;
            if (! empty($data['label'])) {
                $settings['qris_label'] = $data['label'];
            }

            $locked->forceFill([
                'qris_image_path' => $path,
                'qris_image_bytes' => $bytes,
                'storage_used_bytes' => max(0, $locked->storage_used_bytes + $netDelta),
                'settings' => $settings,
            ])->save();

            return $locked;
        });

        Audit::log($mosque, 'display.qris_updated', $mosque, ['bytes' => $bytes]);

        return response()->json([
            'data' => [
                'has_image' => true,
                'enabled' => true,
                'label' => (string) $mosque->setting('qris_label'),
            ],
        ], 201);
    }

    public function deleteQris(Mosque $mosque): JsonResponse
    {
        $disk = config('filesystems.attachments_disk', 'local');
        DB::transaction(function () use ($mosque, $disk) {
            $locked = Mosque::whereKey($mosque->id)->lockForUpdate()->firstOrFail();
            if ($locked->qris_image_path) {
                Storage::disk($disk)->delete($locked->qris_image_path);
            }
            $settings = $locked->settings ?? [];
            $settings['display_show_qris'] = false;
            $locked->forceFill([
                'qris_image_path' => null,
                'storage_used_bytes' => max(0, $locked->storage_used_bytes - (int) $locked->qris_image_bytes),
                'qris_image_bytes' => 0,
                'settings' => $settings,
            ])->save();
        });
        Audit::log($mosque, 'display.qris_deleted', $mosque);

        return response()->json(['data' => ['has_image' => false, 'enabled' => false]]);
    }

    public function qrisImage(Request $request)
    {
        /** @var DisplayDevice $device */
        $device = $request->attributes->get('display');
        $mosque = $device->mosque;
        abort_unless($mosque->qris_image_path && $mosque->setting('display_show_qris'), 404);
        $disk = Storage::disk(config('filesystems.attachments_disk', 'local'));
        abort_unless($disk->exists($mosque->qris_image_path), 404);

        return $disk->response($mosque->qris_image_path);
    }

    public function createPairingCode(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate(['name' => ['nullable', 'string', 'max:100']]);
        $this->guardLimit($mosque);

        // Kode 6 digit unik di antara kode yang masih berlaku.
        do {
            $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
            $hash = DisplayPairingCode::hashCode($code);
        } while (DisplayPairingCode::where('code_hash', $hash)->usable()->exists());

        $pairing = DisplayPairingCode::create([
            'mosque_id' => $mosque->id,
            'code_hash' => $hash,
            'name' => $data['name'] ?? null,
            'created_by' => $request->user()->id,
            'expires_at' => now()->addMinutes(DisplayPairingCode::TTL_MINUTES),
        ]);
        Audit::log($mosque, 'display.pairing_code_created', $pairing);

        return response()->json(['data' => ['code' => $code, 'expires_at' => $pairing->expires_at]], 201);
    }

    public function pair(Request $request): JsonResponse
    {
        $data = $request->validate([
            'code' => ['required', 'digits:6'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ]);

        return DB::transaction(function () use ($data) {
            $pairing = DisplayPairingCode::where('code_hash', DisplayPairingCode::hashCode($data['code']))
                ->usable()->lockForUpdate()->first();
            if (! $pairing) {
                throw ValidationException::withMessages(['code' => 'Kode pairing tidak valid atau kedaluwarsa.']);
            }
            $mosque = Mosque::whereKey($pairing->mosque_id)->lockForUpdate()->firstOrFail();
            $this->guardLimit($mosque);

            $token = Str::random(64);
            $device = $mosque->displayDevices()->create([
                'name' => $pairing->name ?? $data['device_name'] ?? 'TV Display',
                'token_hash' => DisplayDevice::hashToken($token),
                'status' => 'active',
                'config' => [],
                'paired_at' => now(),
            ]);
            $pairing->update(['used_at' => now()]);
            Audit::log($mosque, 'display.paired', $device, ['name' => $device->name], 'device', $device->id);

            return response()->json([
                'token' => $token,
                'device' => ['id' => $device->id, 'name' => $device->name],
                'mosque' => ['id' => $mosque->id, 'name' => $mosque->name],
            ], 201);
        });
    }

    public function update(Request $request, Mosque $mosque, DisplayDevice $displayDevice): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:100'],
            'config' => ['sometimes', 'array'],
            'config.theme' => ['sometimes', 'in:auto,light,dark'],
            'config.rotation_seconds' => ['sometimes', 'integer', 'between:5,120'],
            'config.show_staff' => ['sometimes', 'boolean'],
        ]);
        if (isset($data['config'])) {
            $data['config'] = array_intersect_key($data['config'], array_flip(['theme', 'rotation_seconds', 'show_staff']))
                + ($displayDevice->config ?? []);
        }
        $displayDevice->update($data);

        return response()->json(['data' => $displayDevice]);
    }

    public function revoke(Mosque $mosque, DisplayDevice $displayDevice): JsonResponse
    {
        $displayDevice->update(['status' => 'revoked', 'revoked_at' => now()]);
        Audit::log($mosque, 'display.revoked', $displayDevice);

        return response()->json(['data' => $displayDevice]);
    }

    public function content(Request $request, DisplayContent $builder): JsonResponse|Response
    {
        /** @var DisplayDevice $device */
        $device = $request->attributes->get('display');
        $device->forceFill(['last_seen_at' => now()])->saveQuietly();

        $content = $builder->build($device->mosque) + ['device' => ['id' => $device->id, 'name' => $device->name, 'config' => $device->config ?: (object) []]];
        $etag = '"'.sha1(json_encode($content)).'"';

        if ($request->header('If-None-Match') === $etag) {
            return response('', 304)->header('ETag', $etag)->header('X-Server-Time', now()->toIso8601String());
        }

        return response()->json($content + ['server_time' => now()->toIso8601String()])
            ->header('ETag', $etag)->header('X-Server-Time', now()->toIso8601String());
    }

    private function guardLimit(Mosque $mosque): void
    {
        if ($mosque->displayDevices()->where('status', 'active')->count() >= Mosque::MAX_DISPLAYS) {
            throw new DomainRuleException('display_limit_reached', 'Batas 5 TV Display aktif tercapai. Cabut perangkat lama terlebih dahulu.');
        }
    }
}
