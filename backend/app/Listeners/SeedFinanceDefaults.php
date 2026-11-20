<?php

namespace App\Listeners;

use App\Events\MosqueRegistered;

class SeedFinanceDefaults
{
    public const FUNDS = [
        ['code' => 'OPS', 'name' => 'Kas Operasional', 'restricted' => false],
        ['code' => 'ZAKAT', 'name' => 'Dana Zakat', 'restricted' => true],
        ['code' => 'WAKAF', 'name' => 'Dana Wakaf', 'restricted' => true],
        ['code' => 'PROGRAM', 'name' => 'Infaq Terikat Program', 'restricted' => true],
    ];

    public const CATEGORIES = [
        ['name' => 'Saldo Awal', 'flow' => 'in'],
        ['name' => 'Infaq Jumat', 'flow' => 'in'],
        ['name' => 'Kotak Amal', 'flow' => 'in'],
        ['name' => 'Donasi', 'flow' => 'in'],
        ['name' => 'Zakat', 'flow' => 'in'],
        ['name' => 'Listrik & Air', 'flow' => 'out'],
        ['name' => 'Kebersihan', 'flow' => 'out'],
        ['name' => 'Honor Petugas', 'flow' => 'out'],
        ['name' => 'Kegiatan', 'flow' => 'out'],
        ['name' => 'Perawatan', 'flow' => 'out'],
        ['name' => 'Penyaluran Zakat', 'flow' => 'out'],
    ];

    public function handle(MosqueRegistered $event): void
    {
        $m = $event->mosque;
        foreach (self::FUNDS as $i => $f) {
            $m->funds()->create($f + ['sort' => $i]);
        }
        $m->cashAccounts()->create(['name' => 'Kas Tunai', 'type' => 'cash']);
        foreach (self::CATEGORIES as $c) {
            $m->financeCategories()->create($c);
        }
    }
}
