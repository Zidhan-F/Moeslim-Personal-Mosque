<?php

namespace Database\Seeders;

use App\Models\User;
use App\Services\FinanceService;
use App\Services\MosqueRegistrar;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DemoMosqueSeeder extends Seeder
{
    public const DEMO_EMAIL = 'admin@masjid-demo.id';

    public const DEMO_PASSWORD = 'MoeslimDemo2026!';

    public function run(): void
    {
        $user = User::firstOrNew(['email' => self::DEMO_EMAIL]);
        $user->name = 'Admin Demo Masjid';
        $user->phone = '081234567890';
        $user->password = Hash::make(self::DEMO_PASSWORD);
        $user->email_verified_at ??= now();
        $user->save();

        $membership = $user->memberships()->where('status', 'active')->with('mosque')->first();
        if ($membership !== null && $membership->mosque !== null) {
            $mosque = $membership->mosque;
        } else {
            /** @var MosqueRegistrar $registrar */
            $registrar = app(MosqueRegistrar::class);
            [$mosque] = $registrar->register($user, [
                'name' => 'Masjid Al-Ikhlas Demo',
                'address' => 'Jl. Kebayoran Baru No. 12, Jakarta Selatan',
                'city' => 'Jakarta',
                'province' => 'DKI Jakarta',
                'latitude' => -6.2442,
                'longitude' => 106.7975,
                'timezone' => 'Asia/Jakarta',
                'prayer_method' => 'kemenag',
                'phone' => '081234567890',
                'facilities' => 'Tempat wudhu nyaman, parkir luas, ruang kajian, AC, karpet saf.',
            ]);
        }

        // Pastikan pengaturan tampilan & publik siap dicoba di aplikasi & TV Display.
        $mosque->update([
            'settings' => array_replace_recursive($mosque->settings ?? [], [
                'display_show_finance' => true,
                'public_show_finance' => true,
            ]),
        ]);

        // Seed transaksi keuangan contoh secara idempoten.
        $fund = $mosque->funds()->first();
        $cash = $mosque->cashAccounts()->first();
        $catIn = $mosque->financeCategories()->where('flow', 'in')->first();
        $catOut = $mosque->financeCategories()->where('flow', 'out')->first();

        if ($fund && $cash) {
            /** @var FinanceService $finance */
            $finance = app(FinanceService::class);
            $today = $mosque->today();
            $yesterday = now($mosque->timezone)->subDay()->toDateString();

            $finance->record($mosque, $user, [
                'flow' => 'in',
                'amount' => 2750000,
                'fund_id' => $fund->id,
                'cash_account_id' => $cash->id,
                'category_id' => $catIn?->id,
                'date' => $yesterday,
                'description' => 'Infaq Kotak Amal Jumat Pekan Ini',
                'donor_name' => 'Jamaah Jumat',
            ], 'demo-seed-tx-1');

            $finance->record($mosque, $user, [
                'flow' => 'in',
                'amount' => 1500000,
                'fund_id' => $fund->id,
                'cash_account_id' => $cash->id,
                'category_id' => $catIn?->id,
                'date' => $today,
                'description' => 'Donasi Operasional Bulanan Masjid',
                'donor_name' => 'Hamba Allah',
            ], 'demo-seed-tx-2');

            $finance->record($mosque, $user, [
                'flow' => 'out',
                'amount' => 650000,
                'fund_id' => $fund->id,
                'cash_account_id' => $cash->id,
                'category_id' => $catOut?->id,
                'date' => $today,
                'description' => 'Pembayaran Listrik & Kebersihan Masjid',
            ], 'demo-seed-tx-3');
        }

        // Seed agenda kegiatan bila belum ada.
        if ($mosque->events()->count() === 0) {
            $mosque->events()->create([
                'title' => 'Kajian Tafsir Ba\'da Maghrib',
                'description' => 'Kajian rutin pekanan membahas Tafsir Juz Amma terbuka untuk umum.',
                'category' => 'kajian',
                'location' => 'Ruang Utama Masjid Al-Ikhlas',
                'speaker' => 'Ustadz Ahmad Fauzi, Lc.',
                'starts_at' => now($mosque->timezone)->addDays(1)->setTime(18, 30),
                'ends_at' => now($mosque->timezone)->addDays(1)->setTime(20, 0),
                'visibility' => 'public',
                'status' => 'active',
                'show_on_display' => true,
                'created_by' => $user->id,
            ]);

            $mosque->events()->create([
                'title' => 'Kerja Bakti & Bersih Masjid',
                'description' => 'Gotong royong membersihkan karpet, tempat wudhu, dan halaman masjid.',
                'category' => 'sosial',
                'location' => 'Area Masjid & Halaman',
                'starts_at' => now($mosque->timezone)->addDays(3)->setTime(7, 30),
                'ends_at' => now($mosque->timezone)->addDays(3)->setTime(10, 0),
                'visibility' => 'public',
                'status' => 'active',
                'show_on_display' => true,
                'created_by' => $user->id,
            ]);
        }

        // Seed pengumuman aktif bila belum ada.
        if ($mosque->announcements()->count() === 0) {
            $mosque->announcements()->create([
                'title' => 'Penerimaan Infaq Renovasi Tempat Wudhu',
                'body' => 'Jamaah dapat menyalurkan infaq melalui kotak amal atau pengurus DKM setiap selesai salat fardhu.',
                'visibility' => 'public',
                'priority' => 2,
                'publish_at' => now()->subHour(),
                'expires_at' => now()->addDays(30),
                'status' => 'active',
                'show_on_display' => true,
                'created_by' => $user->id,
            ]);
        }

        // Seed jadwal petugas bila belum ada.
        if ($mosque->staffAssignments()->count() === 0) {
            $mosque->staffAssignments()->create([
                'duty_type' => 'imam',
                'prayer' => 'maghrib',
                'date' => $mosque->today(),
                'user_id' => $user->id,
                'notes' => 'Imam rawatib',
            ]);
            $mosque->staffAssignments()->create([
                'duty_type' => 'khatib',
                'prayer' => 'jumat',
                'date' => now($mosque->timezone)->next('Friday')->toDateString(),
                'external_name' => 'Ustadz Dr. Muhammad Hasan',
                'notes' => 'Khutbah Jumat pekan ini',
            ]);
        }

        // Seed inventaris masjid bila belum ada.
        if ($mosque->inventoryItems()->count() === 0) {
            $mosque->inventoryItems()->create([
                'code' => 'INV-001',
                'name' => 'Sound System & Mixer Utama',
                'quantity' => 1,
                'condition' => 'baik',
                'location' => 'Ruang Kontrol Mihrab',
                'responsible' => 'Bidang Sarana',
            ]);
            $mosque->inventoryItems()->create([
                'code' => 'INV-002',
                'name' => 'Karpet Saf Turki (Roll 6m)',
                'quantity' => 12,
                'condition' => 'baik',
                'location' => 'Ruang Salat Utama',
                'responsible' => 'Bidang Kebersihan',
            ]);
        }

        $this->command?->info('Akun demo siap: '.self::DEMO_EMAIL.' (Masjid: '.$mosque->name.')');
    }
}
