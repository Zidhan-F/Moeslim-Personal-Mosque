<?php

namespace App\Console\Commands;

use App\Models\Mosque;
use App\Services\SubscriptionService;
use App\Support\Audit;
use Illuminate\Console\Command;

/** Aktivasi manual oleh operator platform (mis. pembayaran transfer yang sudah diverifikasi). */
class ActivateSubscription extends Command
{
    protected $signature = 'moeslim:subscription:activate {mosque : ID atau slug masjid} {--months=1} {--ref= : Nomor bukti pembayaran}';

    protected $description = 'Aktifkan/perpanjang langganan masjid secara manual';

    public function handle(SubscriptionService $subs): int
    {
        $key = $this->argument('mosque');
        $mosque = Mosque::where('slug', $key)->orWhere('id', $key)->first();
        if (! $mosque) {
            $this->error('Masjid tidak ditemukan.');

            return self::FAILURE;
        }
        $months = max(1, (int) $this->option('months'));
        $sub = $subs->activate($mosque, $months, 'manual', $this->option('ref'));
        Audit::log($mosque, 'billing.activated', null, ['provider' => 'manual', 'months' => $months, 'ref' => $this->option('ref')], 'system');
        $this->info("Langganan {$mosque->name} aktif sampai {$sub->current_period_ends_at->toDateString()}.");

        return self::SUCCESS;
    }
}
