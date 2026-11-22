<?php

namespace Tests\Feature\Api;

use App\Models\Mosque;
use App\Models\User;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ZakatQurbanTest extends TestCase
{
    private User $owner;

    private Mosque $mosque;

    protected function setUp(): void
    {
        parent::setUp();
        $this->owner = $this->verifiedUser();
        $this->mosque = $this->createMosque($this->owner, ['name' => 'Masjid Taqwa Nusantara']);
        Sanctum::actingAs($this->owner);
    }

    public function test_zakat_collection_auto_ledger_and_mustahik_distribution(): void
    {
        // Catat zakat fitrah uang + otomatis masuk buku kas
        $this->postJson("/api/mosques/{$this->mosque->id}/zakat/collections", [
            'type' => 'fitrah_money',
            'hijri_year' => 1447,
            'date' => '2026-03-19',
            'muzakki_name' => 'Keluarga Bpk. Hasan',
            'souls_count' => 4,
            'money_amount' => 180000,
            'record_to_finance' => true,
        ])->assertCreated()->assertJsonPath('data.souls_count', 4);

        // Catat zakat fitrah beras (tidak masuk buku kas)
        $this->postJson("/api/mosques/{$this->mosque->id}/zakat/collections", [
            'type' => 'fitrah_rice',
            'hijri_year' => 1447,
            'date' => '2026-03-19',
            'muzakki_name' => 'Ibu Aminah',
            'souls_count' => 2,
            'rice_kg' => 5.4,
        ])->assertCreated();

        $this->assertEquals(1, $this->mosque->transactions()->count());
        $this->assertEquals(180000, $this->mosque->transactions()->value('amount'));

        // Mustahik + distribusi
        $m = $this->postJson("/api/mosques/{$this->mosque->id}/zakat/mustahiks", [
            'hijri_year' => 1447,
            'name' => 'Mbah Suyono',
            'asnaf' => 'fakir',
            'address' => 'RT 03 RW 02',
            'money_amount' => 100000,
            'rice_kg' => 3.5,
        ])->assertCreated()->json('data');

        $this->postJson("/api/mosques/{$this->mosque->id}/zakat/mustahiks/{$m['id']}/distribute")
            ->assertOk()
            ->assertJsonPath('data.status', 'distributed');

        $this->getJson("/api/mosques/{$this->mosque->id}/zakat?hijri_year=1447")
            ->assertOk()
            ->assertJsonPath('summary.total_souls', 6)
            ->assertJsonPath('summary.total_money_in', 180000)
            ->assertJsonPath('summary.total_rice_in_kg', 5.4)
            ->assertJsonPath('summary.distributed_mustahik', 1);
    }

    public function test_qurban_patungan_capacity_guard_slaughter_progress_and_anti_double_qr_coupons(): void
    {
        // Daftarkan Sapi (kapasitas default 7 bagian)
        $sapi = $this->postJson("/api/mosques/{$this->mosque->id}/qurban/animals", [
            'hijri_year' => 1447,
            'code' => 'SAPI-01',
            'species' => 'sapi',
            'weight_kg' => 450,
            'price_idr' => 24500000,
        ])->assertCreated()->assertJsonPath('data.capacity', 7)->json('data');

        // 4 + 3 = 7 bagian (pas penuh!)
        $p1 = $this->postJson("/api/mosques/{$this->mosque->id}/qurban/animals/{$sapi['id']}/participants", [
            'name' => 'H. Rahman',
            'shares' => 4,
            'amount_idr' => 14000000,
            'payment_status' => 'paid',
        ])->assertCreated()->json('data');

        $this->postJson("/api/mosques/{$this->mosque->id}/qurban/animals/{$sapi['id']}/participants", [
            'name' => 'Ibu Siti',
            'shares' => 3,
            'amount_idr' => 10500000,
            'payment_status' => 'dp',
        ])->assertCreated();

        // Bagian ke-8 wajib ditolak 422!
        $this->postJson("/api/mosques/{$this->mosque->id}/qurban/animals/{$sapi['id']}/participants", [
            'name' => 'Peserta Berlebih',
            'shares' => 1,
        ])->assertStatus(422)->assertJsonPath('code', 'qurban_capacity_exceeded');

        // Update status penyembelihan & jumlah bungkus daging + tanda terima shohibul qurban
        $this->patchJson("/api/mosques/{$this->mosque->id}/qurban/animals/{$sapi['id']}", [
            'slaughter_status' => 'packaged',
            'meat_packs_count' => 120,
        ])->assertOk()->assertJsonPath('data.meat_packs_count', 120);

        $this->patchJson("/api/mosques/{$this->mosque->id}/qurban/participants/{$p1['id']}", [
            'meat_taken' => true,
        ])->assertOk()->assertJsonPath('data.meat_taken', true);

        // Terbitkan 3 kupon QR batch
        $coupons = $this->postJson("/api/mosques/{$this->mosque->id}/coupons", [
            'program' => 'qurban',
            'hijri_year' => 1447,
            'batch_count' => 3,
            'recipient_prefix' => 'Warga RW 05',
        ])->assertCreated()->assertJsonCount(3, 'data')->json('data');

        $code = $coupons[0]['code'];
        $this->assertStringStartsWith('QBN-', $code);

        // Redeem pertama sukses
        $this->postJson("/api/mosques/{$this->mosque->id}/coupons/redeem", ['code' => $code])
            ->assertOk()
            ->assertJsonPath('data.status', 'redeemed');

        // Redeem kedua dengan kode sama DITOLAK anti-dobel (422)!
        $this->postJson("/api/mosques/{$this->mosque->id}/coupons/redeem", ['code' => $code])
            ->assertStatus(422)
            ->assertJsonPath('code', 'coupon_already_redeemed');

        // Isolasi tenant: kupon tidak bisa di-redeem oleh masjid lain
        $otherUser = $this->verifiedUser();
        $otherMosque = $this->createMosque($otherUser, ['name' => 'Masjid Lain']);
        Sanctum::actingAs($otherUser);
        $this->postJson("/api/mosques/{$otherMosque->id}/coupons/redeem", ['code' => $code])
            ->assertStatus(404);
    }
}
