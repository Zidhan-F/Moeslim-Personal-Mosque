<?php

namespace App\Services\Billing;

use App\Exceptions\DomainRuleException;
use App\Models\Mosque;

/**
 * Verifikasi langganan Google Play (purchases.subscriptionsv2.get).
 *
 * Integrasi nyata membutuhkan service account Play Console
 * (services.google_play.service_account_json & package_name). Sampai itu
 * dikonfigurasi, provider menolak dengan 503 agar tidak ada aktivasi tanpa bukti.
 */
class GooglePlayBillingProvider implements BillingProvider
{
    public function verify(Mosque $mosque, array $payload): array
    {
        if (! config('services.google_play.service_account_json') || ! config('services.google_play.package_name')) {
            throw new DomainRuleException('billing_not_configured', 'Pembayaran Google Play belum dikonfigurasi di server.', 503);
        }

        throw new DomainRuleException('billing_not_implemented', 'Verifikasi Google Play belum diimplementasikan.', 501);
    }
}
