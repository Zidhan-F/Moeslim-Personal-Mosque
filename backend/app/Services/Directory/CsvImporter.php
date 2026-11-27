<?php

namespace App\Services\Directory;

use RuntimeException;

/**
 * Impor CSV generik (mis. data SIMAS Kemenag setelah ada izin/kerja sama resmi).
 * Kolom (header, urutan bebas): id, name, latitude, longitude, [kind, address, city, province, simas_id].
 */
class CsvImporter
{
    public function __construct(private DirectoryService $directory) {}

    /** @return array{imported:int, skipped:int} */
    public function import(string $path, string $source): array
    {
        $fh = fopen($path, 'r') ?: throw new RuntimeException("Tidak bisa membuka $path");
        $header = array_map(fn ($h) => strtolower(trim((string) $h, " \t\n\r\0\x0B\u{FEFF}")), fgetcsv($fh) ?: []);
        foreach (['id', 'name', 'latitude', 'longitude'] as $col) {
            if (! in_array($col, $header, true)) {
                throw new RuntimeException("Kolom wajib '$col' tidak ada.");
            }
        }
        $imported = $skipped = 0;
        while (($row = fgetcsv($fh)) !== false) {
            if (count($row) !== count($header)) {
                $skipped++;

                continue;
            }
            $r = array_combine($header, array_map('trim', $row));
            $lat = filter_var($r['latitude'], FILTER_VALIDATE_FLOAT);
            $lng = filter_var($r['longitude'], FILTER_VALIDATE_FLOAT);
            if ($r['id'] === '' || $r['name'] === '' || $lat === false || $lng === false || abs($lat) > 90 || abs($lng) > 180 || ($lat == 0 && $lng == 0)) {
                $skipped++;

                continue;
            }
            $kind = strtolower($r['kind'] ?? '');
            $this->directory->upsert($source, mb_substr($r['id'], 0, 64), [
                'name' => mb_substr($r['name'], 0, 200),
                'kind' => in_array($kind, ['masjid', 'musala'], true) ? $kind : DirectoryService::guessKind($r['name']),
                'latitude' => $lat,
                'longitude' => $lng,
                'address' => ($r['address'] ?? '') !== '' ? mb_substr($r['address'], 0, 255) : null,
                'city' => ($r['city'] ?? '') !== '' ? mb_substr($r['city'], 0, 100) : null,
                'province' => ($r['province'] ?? '') !== '' ? mb_substr($r['province'], 0, 100) : null,
                'simas_id' => ($r['simas_id'] ?? '') !== '' ? mb_substr($r['simas_id'], 0, 64) : ($source === 'simas' ? mb_substr($r['id'], 0, 64) : null),
            ]);
            $imported++;
        }
        fclose($fh);

        return compact('imported', 'skipped');
    }
}
