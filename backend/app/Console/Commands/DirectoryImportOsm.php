<?php

namespace App\Console\Commands;

use App\Services\Directory\DirectoryService;
use App\Services\Directory\OsmImporter;
use Illuminate\Console\Command;

/**
 * Impor masjid dari OpenStreetMap ke direktori. Contoh:
 *   php artisan directory:import-osm --region=indonesia          (unduh per ubin 2°, jeda sopan)
 *   php artisan directory:import-osm --bbox=-6.4,106.6,-6.0,107.1 --prune
 *   php artisan directory:import-osm storage/app/osm-jakarta.json --bbox=-6.4,106.6,-6.0,107.1 --prune
 */
class DirectoryImportOsm extends Command
{
    protected $signature = 'directory:import-osm {file? : Berkas JSON Overpass (opsional)}
        {--bbox= : selatan,barat,utara,timur}
        {--region= : indonesia}
        {--tile=2 : Ukuran ubin (derajat) saat mengunduh wilayah besar}
        {--pause=5 : Jeda antar unduhan (detik) agar sopan terhadap server Overpass}
        {--prune : Sembunyikan entri OSM di kotak yang tidak ada lagi di peta}';

    protected $description = 'Impor masjid & musala dari OpenStreetMap (ODbL) ke direktori Masjid Terdekat';

    public const REGIONS = ['indonesia' => [-11.2, 94.7, 6.3, 141.1]];

    public function handle(OsmImporter $importer, DirectoryService $directory): int
    {
        $bbox = $this->option('region')
            ? (self::REGIONS[$this->option('region')] ?? null)
            : ($this->option('bbox') ? array_map('floatval', explode(',', $this->option('bbox'))) : null);
        if ($this->option('region') && ! $bbox) {
            $this->error('Wilayah tidak dikenal.');

            return self::FAILURE;
        }
        if ($bbox && count($bbox) !== 4) {
            $this->error('Format --bbox: selatan,barat,utara,timur');

            return self::FAILURE;
        }

        if ($file = $this->argument('file')) {
            $json = json_decode((string) file_get_contents($file), true);
            if (! is_array($json)) {
                $this->error('Berkas bukan JSON Overpass yang valid.');

                return self::FAILURE;
            }
            $this->report($importer->import($json, $this->option('prune') ? $bbox : null));
        } else {
            if (! $bbox) {
                $this->error('Tentukan --bbox atau --region untuk mengunduh dari Overpass.');

                return self::FAILURE;
            }
            $step = max(0.25, (float) $this->option('tile'));
            [$s, $w, $n, $e] = $bbox;
            for ($lat = $s; $lat < $n; $lat += $step) {
                for ($lng = $w; $lng < $e; $lng += $step) {
                    $tile = [$lat, $lng, min($lat + $step, $n), min($lng + $step, $e)];
                    $this->line('Ubin '.implode(',', $tile));
                    try {
                        $this->report($importer->import($importer->fetch($tile), $this->option('prune') ? $tile : null));
                    } catch (\Throwable $ex) {
                        $this->warn('  gagal: '.$ex->getMessage());
                    }
                    sleep((int) $this->option('pause'));
                }
            }
        }

        $linked = $directory->relinkUnmatched();
        $this->info("Masjid terdaftar yang kini tertaut ke data peta: $linked");

        return self::SUCCESS;
    }

    private function report(array $r): void
    {
        $this->info("  diimpor {$r['imported']}, dilewati {$r['skipped']}, disembunyikan {$r['hidden']}");
    }
}
