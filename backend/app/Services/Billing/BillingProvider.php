<?php

namespace App\Services\Billing;

use App\Exceptions\DomainRuleException;
use App\Models\Mosque;

interface BillingProvider
{
    /**
     * Verifikasi bukti pembelian di sisi server.
     *
     * @return array{months: int, external_ref: string}
     *
     * @throws DomainRuleException bila tidak valid / belum dikonfigurasi
     */
    public function verify(Mosque $mosque, array $payload): array;
}
