<?php

namespace App\Console\Commands;

use App\Services\Directory\CsvImporter;
use App\Services\Directory\DirectoryService;
use Illuminate\Console\Command;

/** Impor CSV ke direktori (mis. data SIMAS Kemenag yang diperoleh secara resmi). */
class DirectoryImportCsv extends Command
{
    protected $signature = 'directory:import-csv {file} {--source=simas : simas | user}';

    protected $description = 'Impor masjid dari berkas CSV ke direktori Masjid Terdekat';

    public function handle(CsvImporter $importer, DirectoryService $directory): int
    {
        if (! in_array($this->option('source'), ['simas', 'user'], true)) {
            $this->error('Sumber harus simas atau user.');

            return self::FAILURE;
        }
        try {
            $r = $importer->import($this->argument('file'), $this->option('source'));
        } catch (\RuntimeException $e) {
            $this->error($e->getMessage());

            return self::FAILURE;
        }
        $this->info("Diimpor {$r['imported']}, dilewati {$r['skipped']}.");
        $this->info('Masjid terdaftar yang kini tertaut: '.$directory->relinkUnmatched());

        return self::SUCCESS;
    }
}
