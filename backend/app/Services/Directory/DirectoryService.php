<?php

namespace App\Services\Directory;

use App\Models\DirectoryEntry;
use App\Models\DirectoryReport;
use App\Models\Mosque;
use App\Support\Geohash;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class DirectoryService
{
    /** Radius & ambang pencocokan masjid terdaftar dengan entri direktori. */
    public const MATCH_RADIUS_M = 75.0;

    public const SURE_MATCH_M = 25.0;

    public const MIN_NAME_SIMILARITY = 0.5;

    /**
     * Sisipkan/perbarui entri dari sumber eksternal. Entri `locked` (sudah dikoreksi moderator)
     * hanya diperbarui atribut non-inti.
     */
    public function upsert(string $source, string $ref, array $attrs): DirectoryEntry
    {
        $entry = DirectoryEntry::firstOrNew(['source' => $source, 'source_ref' => $ref]);
        if ($entry->exists && $entry->locked) {
            $attrs = array_intersect_key($attrs, array_flip(['address', 'city', 'province', 'simas_id']));
        }
        $entry->fill($attrs);
        $entry->last_seen_at = now();
        if (! $entry->exists) {
            $entry->status = 'active';
        }
        $entry->save();

        return $entry;
    }

    /** Entri aktif di sekitar titik (kotak batas + haversine), terurut jarak. */
    public function near(float $lat, float $lng, float $radiusM, int $limit = 50): Collection
    {
        $dLat = $radiusM / 111320;
        $dLng = $radiusM / (111320 * max(cos(deg2rad($lat)), 0.01));

        return DirectoryEntry::where('status', 'active')
            ->whereBetween('latitude', [$lat - $dLat, $lat + $dLat])
            ->whereBetween('longitude', [$lng - $dLng, $lng + $dLng])
            ->get()
            ->map(function (DirectoryEntry $e) use ($lat, $lng) {
                $e->setAttribute('distance_m', Geohash::distanceMeters($lat, $lng, $e->latitude, $e->longitude));

                return $e;
            })
            ->filter(fn ($e) => $e->distance_m <= $radiusM)
            ->sortBy('distance_m')
            ->take($limit)
            ->values();
    }

    /** Hubungkan masjid terdaftar Moeslim Mosque ke entri direktori (atau buat entri baru). */
    public function linkMosque(Mosque $mosque): DirectoryEntry
    {
        return DB::transaction(function () use ($mosque) {
            // Lepas tautan lama (koordinat/nama bisa berubah).
            DirectoryEntry::where('mosque_id', $mosque->id)->where('source', '!=', 'moeslim')
                ->update(['mosque_id' => null, 'verified' => false]);

            $match = $this->near($mosque->latitude, $mosque->longitude, self::MATCH_RADIUS_M, 20)
                ->filter(fn ($e) => $e->source !== 'moeslim' && $e->mosque_id === null)
                ->map(function ($e) use ($mosque) {
                    $e->setAttribute('similarity', self::nameSimilarity($mosque->name, $e->name));

                    return $e;
                })
                ->filter(fn ($e) => $e->distance_m <= self::SURE_MATCH_M || $e->similarity >= self::MIN_NAME_SIMILARITY)
                ->sortBy([['similarity', 'desc'], ['distance_m', 'asc']])
                ->first();

            $own = DirectoryEntry::where('source', 'moeslim')->where('source_ref', $mosque->id)->first();
            if ($match) {
                $own?->delete();
                $match->fill([
                    'mosque_id' => $mosque->id,
                    'verified' => true,
                    'status' => 'active',
                    // Nama & alamat resmi dari pengurus; koordinat peta dipertahankan bila sangat dekat.
                    'name' => $mosque->name,
                    'address' => $mosque->address ?? $match->address,
                    'city' => $mosque->city,
                    'province' => $mosque->province ?? $match->province,
                ]);
                unset($match->distance_m, $match->similarity);
                $match->save();

                return $match;
            }

            return $this->upsert('moeslim', $mosque->id, [
                'name' => $mosque->name,
                'kind' => 'masjid',
                'latitude' => $mosque->latitude,
                'longitude' => $mosque->longitude,
                'address' => $mosque->address,
                'city' => $mosque->city,
                'province' => $mosque->province,
                'simas_id' => $mosque->simas_id,
                'mosque_id' => $mosque->id,
                'verified' => true,
            ]);
        });
    }

    /** Setelah impor: coba cocokkan ulang masjid terdaftar yang belum tertaut ke data peta. */
    public function relinkUnmatched(): int
    {
        $ids = DirectoryEntry::where('source', 'moeslim')->pluck('source_ref');
        $n = 0;
        Mosque::whereIn('id', $ids)->each(function (Mosque $m) use (&$n) {
            if ($this->linkMosque($m)->source !== 'moeslim') {
                $n++;
            }
        });

        return $n;
    }

    /** Isi satu sel wilayah untuk diunduh aplikasi (tanpa koordinat pengguna). */
    public function cell(string $cell): array
    {
        $rows = DirectoryEntry::with('mosque:id,slug')->where('cell', $cell)->where('status', 'active')
            ->orderBy('id')->get();

        return [
            'cell' => $cell,
            'version' => md5($rows->max('updated_at').'|'.$rows->count()),
            'attribution' => $rows->contains('source', 'osm') ? ['© OpenStreetMap contributors (ODbL 1.0)'] : [],
            'data' => $rows->map(fn (DirectoryEntry $e) => [
                'id' => $e->id,
                'name' => $e->name,
                'kind' => $e->kind,
                'lat' => round($e->latitude, 6),
                'lng' => round($e->longitude, 6),
                'address' => $e->address,
                'city' => $e->city,
                'verified' => $e->verified,
                'mosque_slug' => $e->mosque?->slug,
                'source' => $e->source,
            ])->values(),
        ];
    }

    /** Terapkan laporan yang disetujui moderator. */
    public function accept(DirectoryReport $r): ?DirectoryEntry
    {
        return DB::transaction(function () use ($r) {
            $entry = $r->entry;
            switch ($r->type) {
                case 'wrong_location':
                    $entry?->fill(['latitude' => $r->latitude, 'longitude' => $r->longitude, 'locked' => true])->save();
                    break;
                case 'wrong_name':
                    $entry?->fill(['name' => $r->name, 'kind' => $r->kind ?? $entry->kind, 'locked' => true])->save();
                    break;
                case 'not_exists':
                    $entry?->fill(['status' => 'hidden', 'locked' => true])->save();
                    break;
                case 'new_mosque':
                    $entry = $this->upsert('user', 'report-'.$r->id, [
                        'name' => $r->name,
                        'kind' => $r->kind ?? self::guessKind($r->name),
                        'latitude' => $r->latitude,
                        'longitude' => $r->longitude,
                    ]);
                    $r->directory_id = $entry->id;
                    break;
            }
            $r->status = 'accepted';
            $r->resolved_at = now();
            $r->save();

            return $entry;
        });
    }

    public static function guessKind(?string $name): string
    {
        return preg_match('/\b(mus?h?al+a|mus?hol+a|mus?holla|musala|langgar|surau|meunasah)\b/i', (string) $name) ? 'musala' : 'masjid';
    }

    /** Kemiripan nama 0..1 setelah membuang kata umum (masjid, musala, jami', al-, dll.). */
    public static function nameSimilarity(string $a, string $b): float
    {
        $norm = function (string $s): string {
            $s = Str::lower(Str::ascii($s));
            $s = preg_replace('/\b(masjid|mesjid|masjed|jami|jamik|raya|agung|besar|mus?h?al+a|mus?hol+a|musala|langgar|surau|al|an|ar|as|at|ad|ash|asy)\b/', ' ', $s);

            return trim(preg_replace('/[^a-z0-9]+/', '', $s));
        };
        [$x, $y] = [$norm($a), $norm($b)];
        if ($x === '' || $y === '') {
            return 0.5;
        }
        if (str_contains($x, $y) || str_contains($y, $x)) {
            return 0.9;
        }
        similar_text($x, $y, $pct);

        return $pct / 100;
    }
}
