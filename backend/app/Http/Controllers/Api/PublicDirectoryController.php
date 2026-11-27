<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DirectoryEntry;
use App\Models\DirectoryReport;
use App\Services\Directory\DirectoryService;
use App\Support\Geohash;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\Rule;

/**
 * Direktori Masjid Terdekat untuk Moeslim Personal (tanpa akun).
 * Privasi: aplikasi mengunduh SEL wilayah (geohash 4 ≈ 39×20 km) lalu menghitung jarak di perangkat,
 * sehingga server tidak pernah menerima koordinat persis pengguna untuk pencarian.
 */
class PublicDirectoryController extends Controller
{
    public function cell(Request $request, string $cell, DirectoryService $directory): JsonResponse|Response
    {
        abort_unless(Geohash::isValidCell($cell), 404);
        $payload = $directory->cell($cell);
        $etag = '"'.$payload['version'].'"';
        if ($request->header('If-None-Match') === $etag) {
            return response('', 304, ['ETag' => $etag]);
        }

        return response()->json($payload)->header('ETag', $etag)->header('Cache-Control', 'public, max-age=3600');
    }

    public function report(Request $request): JsonResponse
    {
        $data = $request->validate([
            'type' => ['required', Rule::in(DirectoryReport::TYPES)],
            'directory_id' => ['required_unless:type,new_mosque', 'nullable', 'integer', 'exists:mosque_directory,id'],
            'name' => ['required_if:type,new_mosque,wrong_name', 'nullable', 'string', 'min:3', 'max:200'],
            'kind' => ['nullable', Rule::in(DirectoryEntry::KINDS)],
            'latitude' => ['required_if:type,new_mosque,wrong_location', 'nullable', 'numeric', 'between:-90,90'],
            'longitude' => ['required_if:type,new_mosque,wrong_location', 'nullable', 'numeric', 'between:-180,180'],
            'note' => ['nullable', 'string', 'max:500'],
        ]);
        $report = DirectoryReport::create($data + [
            'status' => 'pending',
            'reporter_hash' => hash_hmac('sha256', (string) $request->ip(), (string) config('app.key')),
        ]);

        return response()->json(['data' => ['id' => $report->id, 'status' => 'pending']], 201);
    }
}
