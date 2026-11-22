<?php

namespace Tests\Feature\Api;

use App\Models\Mosque;
use App\Models\User;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FinanceProTest extends TestCase
{
    private User $owner;

    private Mosque $mosque;

    protected function setUp(): void
    {
        parent::setUp();
        $this->owner = $this->verifiedUser();
        $this->mosque = $this->createMosque($this->owner, ['name' => 'Masjid Agung Al-Falah']);
        Sanctum::actingAs($this->owner);
    }

    public function test_donation_box_count_computes_denominations_and_records_immutable_ledger_entry(): void
    {
        $fundId = $this->mosque->funds()->value('id');
        $accId = $this->mosque->cashAccounts()->value('id');
        $catId = $this->mosque->financeCategories()->where('flow', 'in')->value('id');

        $payload = [
            'box_name' => 'Kotak Amal Utama Jumat',
            'date' => '2026-11-20',
            'fund_id' => $fundId,
            'cash_account_id' => $accId,
            'category_id' => $catId,
            'witness_1_name' => 'H. Budi',
            'witness_2_name' => 'Bpk. Slamet',
            'notes' => 'Dihitung setelah Salat Jumat',
            'denominations' => [
                '100000' => 2,
                '50000' => 3,
                '20000' => 1,
                '10000' => 5,
                '5000' => 4,
                '2000' => 5,
                '1000' => 10,
                '500' => 4,
            ],
        ];

        // Wajib Idempotency-Key
        $this->postJson("/api/mosques/{$this->mosque->id}/finance/donation-box-counts", $payload)->assertStatus(428);

        $res = $this->withHeader('Idempotency-Key', 'box-jumat-1')
            ->postJson("/api/mosques/{$this->mosque->id}/finance/donation-box-counts", $payload)
            ->assertCreated()
            ->assertJsonPath('data.total_amount', 462000)
            ->assertJsonPath('data.witness_1_name', 'H. Budi')
            ->assertJsonPath('data.witness_2_name', 'Bpk. Slamet')
            ->assertJsonPath('data.transaction.amount', 462000);

        // Retry dengan key yang sama idempoten (tidak menggandakan kas).
        $this->withHeader('Idempotency-Key', 'box-jumat-1')
            ->postJson("/api/mosques/{$this->mosque->id}/finance/donation-box-counts", $payload)
            ->assertOk()
            ->assertJsonPath('data.id', $res->json('data.id'));

        $this->assertEquals(1, $this->mosque->transactions()->count());
        $this->getJson("/api/mosques/{$this->mosque->id}/finance/donation-box-counts")
            ->assertOk()
            ->assertJsonCount(1, 'data');
    }

    public function test_friday_report_computes_opening_flows_closing_and_whatsapp_text(): void
    {
        $fundId = $this->mosque->funds()->value('id');
        $accId = $this->mosque->cashAccounts()->value('id');

        // Saldo awal sebelum periode Jumat (2026-11-10)
        $this->withHeader('Idempotency-Key', 'f-open')->postJson("/api/mosques/{$this->mosque->id}/finance/transactions", [
            'flow' => 'in', 'amount' => 1000000, 'fund_id' => $fundId, 'cash_account_id' => $accId,
            'date' => '2026-11-10', 'description' => 'Saldo awal',
        ])->assertCreated();

        // Pemasukan & pengeluaran dalam pekan Jumat (2026-11-14 .. 2026-11-20)
        $this->withHeader('Idempotency-Key', 'f-in')->postJson("/api/mosques/{$this->mosque->id}/finance/transactions", [
            'flow' => 'in', 'amount' => 500000, 'fund_id' => $fundId, 'cash_account_id' => $accId,
            'date' => '2026-11-20', 'description' => 'Infaq Kotak Jumat',
        ])->assertCreated();
        $this->withHeader('Idempotency-Key', 'f-out')->postJson("/api/mosques/{$this->mosque->id}/finance/transactions", [
            'flow' => 'out', 'amount' => 150000, 'fund_id' => $fundId, 'cash_account_id' => $accId,
            'date' => '2026-11-18', 'description' => 'Token Listrik',
        ])->assertCreated();

        $res = $this->getJson("/api/mosques/{$this->mosque->id}/finance/friday-report?date=2026-11-20")
            ->assertOk()
            ->assertJsonPath('from', '2026-11-14')
            ->assertJsonPath('to', '2026-11-20')
            ->assertJsonPath('opening_balance', 1000000)
            ->assertJsonPath('total_in', 500000)
            ->assertJsonPath('total_out', 150000)
            ->assertJsonPath('closing_balance', 1350000);

        $wa = $res->json('whatsapp_text');
        $this->assertStringContainsString('Masjid Agung Al-Falah', $wa);
        $this->assertStringContainsString('1.350.000', $wa);
    }

    public function test_digital_receipt_qr_and_public_verification_reflect_reversal(): void
    {
        $fundId = $this->mosque->funds()->value('id');
        $accId = $this->mosque->cashAccounts()->value('id');

        $tx = $this->withHeader('Idempotency-Key', 'rcpt-1')->postJson("/api/mosques/{$this->mosque->id}/finance/transactions", [
            'flow' => 'in',
            'amount' => 2500000,
            'fund_id' => $fundId,
            'cash_account_id' => $accId,
            'date' => '2026-11-20',
            'description' => 'Wakaf Renovasi Tempat Wudhu',
            'donor_name' => 'H. Ahmad Fauzi',
        ])->assertCreated()->json('data');

        $this->assertNotEmpty($tx['receipt_token']);

        $receipt = $this->getJson("/api/mosques/{$this->mosque->id}/finance/transactions/{$tx['id']}/receipt")
            ->assertOk()
            ->assertJsonPath('data.donor_name', 'H. Ahmad Fauzi')
            ->assertJsonPath('data.amount', 2500000)
            ->assertJsonPath('data.status', 'valid')
            ->json('data');

        // Verifikasi publik API & halaman web (tanpa login!)
        $this->app['auth']->forgetGuards();
        $this->getJson("/api/public/receipts/{$receipt['receipt_token']}")
            ->assertOk()
            ->assertJsonPath('data.status', 'valid')
            ->assertJsonPath('data.mosque_name', 'Masjid Agung Al-Falah')
            ->assertJsonPath('data.amount', 2500000);

        $this->get("/verify/receipt/{$receipt['receipt_token']}")
            ->assertOk()
            ->assertSee('Terverifikasi')
            ->assertSee('Masjid Agung Al-Falah')
            ->assertSee('2.500.000');

        // Setelah transaksi dibatalkan (reversal), status verifikasi QR otomatis berubah menjadi dibatalkan.
        Sanctum::actingAs($this->owner);
        $this->postJson("/api/mosques/{$this->mosque->id}/finance/transactions/{$tx['id']}/reverse", [
            'reason' => 'Salah nominal',
        ])->assertCreated();

        $this->app['auth']->forgetGuards();
        $this->getJson("/api/public/receipts/{$receipt['receipt_token']}")
            ->assertOk()
            ->assertJsonPath('data.status', 'reversed');
        $this->get("/verify/receipt/{$receipt['receipt_token']}")
            ->assertOk()
            ->assertSee('Dibatalkan');

        $this->getJson('/api/public/receipts/token-tidak-ada')->assertNotFound();
    }
}
