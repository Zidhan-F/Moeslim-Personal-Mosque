<?php

namespace App\Console\Commands;

use App\Models\DirectoryReport;
use App\Services\Directory\DirectoryService;
use Illuminate\Console\Command;

/**
 * Moderasi laporan pengguna (lokasi salah, tidak ada, nama salah, masjid baru). Contoh:
 *   php artisan directory:reports
 *   php artisan directory:reports --accept=12
 *   php artisan directory:reports --reject=13
 */
class DirectoryReports extends Command
{
    protected $signature = 'directory:reports {--status=pending} {--accept= : ID laporan} {--reject= : ID laporan}';

    protected $description = 'Tinjau dan putuskan laporan direktori masjid dari pengguna';

    public function handle(DirectoryService $directory): int
    {
        foreach (['accept', 'reject'] as $action) {
            if ($id = $this->option($action)) {
                $r = DirectoryReport::where('status', 'pending')->find($id);
                if (! $r) {
                    $this->error("Laporan #$id tidak ditemukan atau sudah diputuskan.");

                    return self::FAILURE;
                }
                if ($action === 'accept') {
                    $e = $directory->accept($r);
                    $this->info("Laporan #$id diterima".($e ? " (entri #{$e->id})" : '').'.');
                } else {
                    $r->update(['status' => 'rejected', 'resolved_at' => now()]);
                    $this->info("Laporan #$id ditolak.");
                }

                return self::SUCCESS;
            }
        }

        $rows = DirectoryReport::with('entry:id,name')->where('status', $this->option('status'))->latest()->limit(100)->get();
        $this->table(['ID', 'Jenis', 'Entri', 'Nama usulan', 'Koordinat', 'Catatan', 'Waktu'], $rows->map(fn ($r) => [
            $r->id, $r->type, $r->entry ? "#{$r->entry->id} {$r->entry->name}" : '-', $r->name ?? '-',
            $r->latitude !== null ? round($r->latitude, 6).','.round($r->longitude, 6) : '-',
            mb_strimwidth((string) $r->note, 0, 40, '…'), $r->created_at->toDateTimeString(),
        ]));

        return self::SUCCESS;
    }
}
