<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\DomainRuleException;
use App\Http\Controllers\Controller;
use App\Models\DisplayDevice;
use App\Models\DisplayPairingCode;
use App\Models\DisplayPairingSession;
use App\Models\Mosque;
use App\Services\DisplayContent;
use App\Support\Audit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Crypt;
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

    /** Reverse QR pairing: TV web (/tv) membuat sesi sementara sebelum dipindai pengurus. */
    public function createSession(): JsonResponse
    {
        $sessionId = (string) Str::ulid();
        $pollSecret = Str::random(40);

        do {
            $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        } while (DisplayPairingSession::active()->where('code', $code)->exists());

        $session = DisplayPairingSession::create([
            'session_id' => $sessionId,
            'secret_hash' => DisplayPairingSession::hashSecret($pollSecret),
            'code' => $code,
            'expires_at' => now()->addMinutes(DisplayPairingSession::TTL_MINUTES),
        ]);

        return response()->json([
            'session_id' => $session->session_id,
            'poll_secret' => $pollSecret,
            'code' => $session->code,
            'qr_payload' => 'MOESLIMTV:'.$session->session_id,
            'expires_at' => $session->expires_at->toIso8601String(),
        ], 201);
    }

    /** Pengurus memindai QR (atau mengetik kode 6 digit) dari layar TV untuk menghubungkannya ke masjid. */
    public function approveSession(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate([
            'session_id' => ['nullable', 'string', 'max:64'],
            'code' => ['nullable', 'digits:6'],
            'name' => ['nullable', 'string', 'max:100'],
        ]);

        $rawSessionId = isset($data['session_id']) ? trim($data['session_id']) : null;
        if ($rawSessionId !== null && Str::startsWith(strtoupper($rawSessionId), 'MOESLIMTV:')) {
            $rawSessionId = substr($rawSessionId, strlen('MOESLIMTV:'));
        }
        $code = $data['code'] ?? null;

        if (empty($rawSessionId) && empty($code)) {
            throw ValidationException::withMessages([
                'code' => 'Pindai QR di layar TV atau masukkan 6 digit kode sesi TV.',
            ]);
        }

        return DB::transaction(function () use ($request, $mosque, $rawSessionId, $code, $data) {
            $lockedMosque = Mosque::whereKey($mosque->id)->lockForUpdate()->firstOrFail();
            $this->guardLimit($lockedMosque);

            $query = DisplayPairingSession::pendingApproval()->lockForUpdate();
            if (! empty($rawSessionId)) {
                $query->where('session_id', $rawSessionId);
            } else {
                $query->where('code', $code);
            }

            $session = $query->first();
            if (! $session) {
                throw ValidationException::withMessages([
                    'code' => 'QR atau kode sesi TV tidak ditemukan, sudah terhubung, atau kedaluwarsa.',
                ]);
            }

            $token = Str::random(64);
            $name = trim((string) ($data['name'] ?? ''));
            $device = $lockedMosque->displayDevices()->create([
                'name' => $name !== '' ? $name : 'TV Display Web',
                'token_hash' => DisplayDevice::hashToken($token),
                'status' => 'active',
                'config' => [],
                'paired_at' => now(),
            ]);

            $session->forceFill([
                'mosque_id' => $lockedMosque->id,
                'display_device_id' => $device->id,
                'encrypted_token' => Crypt::encryptString($token),
                'approved_at' => now(),
                'approved_by' => $request->user()->id,
            ])->save();

            Audit::log($lockedMosque, 'display.paired_qr', $device, ['name' => $device->name], 'device', $device->id);

            return response()->json(['data' => $device], 201);
        });
    }

    /** TV web (/tv) polling status sesi QR; token hanya diserahkan sekali lalu dihapus dari sesi. */
    public function pollSession(Request $request, string $sessionId): JsonResponse
    {
        $data = $request->validate([
            'poll_secret' => ['required', 'string', 'max:80'],
        ]);

        return DB::transaction(function () use ($sessionId, $data) {
            $session = DisplayPairingSession::where('session_id', $sessionId)->lockForUpdate()->first();
            if (! $session) {
                return response()->json(['status' => 'not_found', 'message' => 'Sesi pairing tidak ditemukan.'], 404);
            }

            if (! hash_equals($session->secret_hash, DisplayPairingSession::hashSecret($data['poll_secret']))) {
                return response()->json(['status' => 'forbidden', 'message' => 'Rahasia sesi tidak valid.'], 403);
            }

            if ($session->claimed_at !== null || $session->expires_at->isPast()) {
                return response()->json(['status' => 'expired']);
            }

            if ($session->approved_at === null || $session->encrypted_token === null) {
                return response()->json([
                    'status' => 'pending',
                    'expires_at' => $session->expires_at->toIso8601String(),
                ]);
            }

            $token = Crypt::decryptString($session->encrypted_token);
            $session->forceFill([
                'encrypted_token' => null,
                'claimed_at' => now(),
            ])->save();

            $device = $session->displayDevice;
            $mosque = $session->mosque;

            return response()->json([
                'status' => 'paired',
                'token' => $token,
                'device' => ['id' => $device?->id, 'name' => $device?->name ?? 'TV Display Web'],
                'mosque' => ['id' => $mosque?->id, 'name' => $mosque?->name ?? 'Masjid'],
            ]);
        });
    }

    /** Kunci `device.config` yang boleh diatur pengurus (tema warna & widget TV Display). */
    public const CONFIG_KEYS = [
        'theme', 'rotation_seconds', 'show_staff', 'language',
        'custom_background', 'custom_background_2', 'custom_accent',
        'show_illustration', 'show_pattern', 'show_seconds', 'show_hijri', 'show_sunrise',
        'show_ticker', 'show_info_screen', 'info_seconds', 'large_clock', 'ticker_text',
    ];

    public function update(Request $request, Mosque $mosque, DisplayDevice $displayDevice): JsonResponse
    {
        $hex = ['sometimes', 'string', 'regex:/^#[0-9A-Fa-f]{6}$/'];
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:100'],
            'config' => ['sometimes', 'array'],
            'config.theme' => ['sometimes', 'in:auto,light,dark,navy,maroon,custom'],
            'config.rotation_seconds' => ['sometimes', 'integer', 'between:5,120'],
            'config.show_staff' => ['sometimes', 'boolean'],
            'config.language' => ['sometimes', 'in:id,en'],
            'config.custom_background' => $hex,
            'config.custom_background_2' => $hex,
            'config.custom_accent' => $hex,
            'config.show_illustration' => ['sometimes', 'boolean'],
            'config.show_pattern' => ['sometimes', 'boolean'],
            'config.show_seconds' => ['sometimes', 'boolean'],
            'config.show_hijri' => ['sometimes', 'boolean'],
            'config.show_sunrise' => ['sometimes', 'boolean'],
            'config.show_ticker' => ['sometimes', 'boolean'],
            'config.show_info_screen' => ['sometimes', 'boolean'],
            'config.info_seconds' => ['sometimes', 'integer', 'in:10,20,30'],
            'config.large_clock' => ['sometimes', 'boolean'],
            'config.ticker_text' => ['sometimes', 'nullable', 'string', 'max:160'],
        ]);
        if (isset($data['config'])) {
            $incoming = array_intersect_key($data['config'], array_flip(self::CONFIG_KEYS));
            if (array_key_exists('ticker_text', $incoming)) {
                $incoming['ticker_text'] = trim((string) $incoming['ticker_text']);
            }
            $data['config'] = $incoming + ($displayDevice->config ?? []);
        }
        $displayDevice->update($data);
        if (isset($data['config'])) {
            Audit::log($mosque, 'display.design_updated', $displayDevice, array_keys($data['config']));
        }

        return response()->json(['data' => $displayDevice]);
    }

    /** Pratinjau untuk pengurus: konten yang sama persis dengan yang diterima TV Display. */
    public function preview(Mosque $mosque, DisplayContent $builder): JsonResponse
    {
        return response()->json([
            'data' => $builder->build($mosque),
            'server_time' => now()->toIso8601String(),
        ]);
    }

    /** Gambar QRIS untuk pratinjau pengurus. */
    public function adminQrisImage(Mosque $mosque)
    {
        abort_unless($mosque->qris_image_path, 404);
        $disk = Storage::disk(config('filesystems.attachments_disk', 'local'));
        abort_unless($disk->exists($mosque->qris_image_path), 404);

        return $disk->response($mosque->qris_image_path);
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
