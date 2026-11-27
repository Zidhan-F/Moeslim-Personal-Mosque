<?php

namespace App\Services\Directory;

use App\Models\DirectoryEntry;
use Illuminate\Support\Facades\Http;

/**
 * Impor masjid & musala dari OpenStreetMap (format JSON Overpass, `out center tags`).
 * Data OSM berlisensi ODbL 1.0: wajib atribusi "© OpenStreetMap contributors"; basis data turunan
 * yang dipublikasikan juga berlisensi ODbL.
 */
class OsmImporter
{
    public function __construct(private DirectoryService $directory) {}

    public static function overpassQuery(array $bbox): string
    {
        [$s, $w, $n, $e] = $bbox;

        return "[out:json][timeout:180];(nwr[\"amenity\"=\"place_of_worship\"][\"religion\"=\"muslim\"]($s,$w,$n,$e););out center tags;";
    }

    /** Unduh dari Overpass (dipanggil server secara berkala, bukan dari ponsel pengguna). */
    public function fetch(array $bbox): array
    {
        $res = Http::timeout(240)
            ->withHeaders(['User-Agent' => 'MoeslimPM-directory-import/1.0'])
            ->asForm()
            ->post(config('services.overpass.url'), ['data' => self::overpassQuery($bbox)]);
        $res->throw();

        return $res->json();
    }

    /** @return array{imported:int, skipped:int, hidden:int} */
    public function import(array $overpass, ?array $pruneBbox = null): array
    {
        $imported = $skipped = 0;
        $startedAt = now()->subSecond();
        foreach ($overpass['elements'] ?? [] as $el) {
            $tags = $el['tags'] ?? [];
            if (($tags['religion'] ?? null) !== 'muslim' || ($tags['amenity'] ?? null) !== 'place_of_worship') {
                $skipped++;

                continue;
            }
            $lat = $el['lat'] ?? $el['center']['lat'] ?? null;
            $lng = $el['lon'] ?? $el['center']['lon'] ?? null;
            if ($lat === null || $lng === null) {
                $skipped++;

                continue;
            }
            $name = trim($tags['name'] ?? $tags['name:id'] ?? '');
            $kind = DirectoryService::guessKind($name);
            $ref = $el['type'].'/'.$el['id'];
            $street = trim(($tags['addr:street'] ?? '').' '.($tags['addr:housenumber'] ?? ''));
            $this->directory->upsert('osm', $ref, [
                'name' => $name !== '' ? mb_substr($name, 0, 200) : ($kind === 'musala' ? 'Musala' : 'Masjid'),
                'kind' => $kind,
                'latitude' => (float) $lat,
                'longitude' => (float) $lng,
                'address' => $street !== '' ? mb_substr($street, 0, 255) : null,
                'city' => isset($tags['addr:city']) ? mb_substr($tags['addr:city'], 0, 100) : null,
                'province' => isset($tags['addr:province']) ? mb_substr($tags['addr:province'], 0, 100) : null,
            ]);
            $imported++;
        }

        $hidden = 0;
        if ($pruneBbox) {
            // Entri OSM di kotak ini yang sudah tidak ada di peta → disembunyikan (bukan dihapus).
            [$s, $w, $n, $e] = $pruneBbox;
            $hidden = DirectoryEntry::where('source', 'osm')->where('locked', false)->where('status', 'active')
                ->whereNull('mosque_id')
                ->whereBetween('latitude', [$s, $n])->whereBetween('longitude', [$w, $e])
                ->where(fn ($q) => $q->whereNull('last_seen_at')->orWhere('last_seen_at', '<', $startedAt))
                ->update(['status' => 'hidden']);
        }

        return compact('imported', 'skipped', 'hidden');
    }
}
