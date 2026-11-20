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
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class DisplayController extends Controller
{
    public function index(Mosque $mosque): JsonResponse
    {
        return response()->json([
            'data' => $mosque->displayDevices()->orderByDesc('status')->orderBy('id')->get(),
            'limit' => Mosque::MAX_DISPLAYS,
        ]);
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
            return response('', 304)->header('ETag', $etag);
        }

        return response()->json($content + ['server_time' => now()->toIso8601String()])->header('ETag', $etag);
    }

    private function guardLimit(Mosque $mosque): void
    {
        if ($mosque->displayDevices()->where('status', 'active')->count() >= Mosque::MAX_DISPLAYS) {
            throw new DomainRuleException('display_limit_reached', 'Batas 5 TV Display aktif tercapai. Cabut perangkat lama terlebih dahulu.');
        }
    }
}
