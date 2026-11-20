<?php

namespace Tests\Feature\Api;

use App\Models\FinanceTransaction;
use App\Models\Mosque;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FinanceTest extends TestCase
{
    private User $owner;

    private Mosque $mosque;

    protected function setUp(): void
    {
        parent::setUp();
        $this->owner = $this->verifiedUser();
        $this->mosque = $this->createMosque($this->owner);
        Sanctum::actingAs($this->owner);
    }

    private function url(string $p = ''): string
    {
        return "/api/mosques/{$this->mosque->id}/finance{$p}";
    }

    private function fund(string $code): int
    {
        return $this->mosque->funds()->where('code', $code)->value('id');
    }

    private function account(): int
    {
        return $this->mosque->cashAccounts()->value('id');
    }

    private function tx(array $over = [], ?string $key = null)
    {
        return $this->withHeader('Idempotency-Key', $key ?? fake()->uuid())->postJson($this->url('/transactions'), $over + [
            'flow' => 'in',
            'amount' => 150000,
            'fund_id' => $this->fund('OPS'),
            'cash_account_id' => $this->account(),
            'date' => '2026-11-01',
            'description' => 'Infaq Jumat',
        ]);
    }

    public function test_defaults_seeded_on_registration(): void
    {
        $this->getJson($this->url('/setup'))->assertOk()
            ->assertJsonPath('funds.0.code', 'OPS')
            ->assertJsonCount(4, 'funds')
            ->assertJsonPath('accounts.0.type', 'cash');
        $this->assertTrue($this->mosque->funds()->where('code', 'ZAKAT')->value('restricted'));
    }

    public function test_create_transaction_and_balances(): void
    {
        $this->tx()->assertCreated()->assertJsonPath('data.amount', 150000)
            ->assertJsonPath('data.reference_no', 'TRX-202611-00001');
        $this->tx(['flow' => 'out', 'amount' => 50000, 'description' => 'Listrik'])->assertCreated();

        $this->getJson($this->url('/summary?from=2026-11-01&to=2026-11-30'))->assertOk()
            ->assertJsonPath('total_in', 150000)
            ->assertJsonPath('total_out', 50000)
            ->assertJsonPath('balance', 100000)
            ->assertJsonPath('funds.0.balance', 100000);
    }

    public function test_amount_must_be_positive_integer(): void
    {
        $this->tx(['amount' => -5])->assertUnprocessable()->assertJsonValidationErrors('amount');
        $this->tx(['amount' => 10.5])->assertUnprocessable();
    }

    public function test_idempotency_key_prevents_duplicates(): void
    {
        $first = $this->tx([], 'abc-123')->assertCreated();
        $again = $this->tx([], 'abc-123')->assertOk();
        $this->assertSame($first->json('data.id'), $again->json('data.id'));
        $this->assertSame(1, FinanceTransaction::count());

        $this->tx(['amount' => 999], 'abc-123')->assertStatus(409);
    }

    public function test_idempotency_key_required(): void
    {
        $this->postJson($this->url('/transactions'), [])->assertStatus(428);
    }

    public function test_transactions_are_immutable_and_reversal_works_once(): void
    {
        $id = $this->tx()->json('data.id');
        $this->patchJson($this->url("/transactions/{$id}"), ['amount' => 1])->assertStatus(405);
        $this->deleteJson($this->url("/transactions/{$id}"))->assertStatus(405);

        $this->postJson($this->url("/transactions/{$id}/reverse"), ['reason' => 'Salah input'])
            ->assertCreated()->assertJsonPath('data.flow', 'out')->assertJsonPath('data.reversal_of_id', $id);
        $this->postJson($this->url("/transactions/{$id}/reverse"), ['reason' => 'lagi'])
            ->assertUnprocessable()->assertJsonPath('code', 'already_reversed');

        $this->getJson($this->url('/summary?from=2026-11-01&to=2026-11-30'))->assertJsonPath('balance', 0);
    }

    public function test_restricted_fund_cannot_go_negative(): void
    {
        $this->tx(['fund_id' => $this->fund('ZAKAT'), 'amount' => 100000])->assertCreated();
        $this->tx(['fund_id' => $this->fund('ZAKAT'), 'flow' => 'out', 'amount' => 100001])
            ->assertUnprocessable()->assertJsonPath('code', 'restricted_fund_insufficient');
        $this->tx(['fund_id' => $this->fund('ZAKAT'), 'flow' => 'out', 'amount' => 100000])->assertCreated();
    }

    public function test_transfer_between_accounts(): void
    {
        $bank = $this->postJson($this->url('/accounts'), ['name' => 'Rekening BSI', 'type' => 'bank'])
            ->assertCreated()->json('data.id');
        $this->tx(['amount' => 300000])->assertCreated();
        $this->tx(['flow' => 'transfer', 'amount' => 200000, 'to_cash_account_id' => $bank])->assertCreated();
        $this->tx(['flow' => 'transfer', 'amount' => 1, 'to_cash_account_id' => $this->account()])
            ->assertUnprocessable();

        $res = $this->getJson($this->url('/summary?from=2026-11-01&to=2026-11-30'))->assertOk();
        $balances = collect($res->json('accounts'))->pluck('balance', 'id');
        $this->assertSame(100000, $balances[$this->account()]);
        $this->assertSame(200000, $balances[$bank]);
        $res->assertJsonPath('total_in', 300000)->assertJsonPath('total_out', 0);
    }

    public function test_cannot_use_other_tenants_fund_or_account(): void
    {
        $other = $this->createMosque();
        Sanctum::actingAs($this->owner);
        $foreignFund = $other->funds()->value('id');
        $this->tx(['fund_id' => $foreignFund])->assertUnprocessable()->assertJsonValidationErrors('fund_id');

        $otherOwner = $other->members()->first()->user;
        $id = $this->tx()->json('data.id');
        Sanctum::actingAs($otherOwner);
        $this->postJson("/api/mosques/{$other->id}/finance/transactions/{$id}/reverse", ['reason' => 'x'])->assertNotFound();
    }

    public function test_permissions_by_role(): void
    {
        $pengurus = $this->addMember($this->mosque, 'pengurus');
        $bendahara = $this->addMember($this->mosque, 'bendahara');
        $operator = $this->addMember($this->mosque, 'operator');

        Sanctum::actingAs($pengurus);
        $this->getJson($this->url('/transactions'))->assertForbidden();
        Sanctum::actingAs($operator);
        $this->getJson($this->url('/transactions'))->assertForbidden();
        Sanctum::actingAs($bendahara);
        $this->tx()->assertCreated();

        $this->mosque->update(['settings' => ['pengurus_can_view_finance' => true]]);
        Sanctum::actingAs($pengurus);
        $this->getJson($this->url('/transactions'))->assertOk()->assertJsonCount(1, 'data');
        $this->tx()->assertForbidden();
    }

    public function test_list_filters_and_csv_export(): void
    {
        $this->tx(['date' => '2026-10-15', 'description' => 'Oktober']);
        $this->tx(['date' => '2026-11-02', 'description' => 'November']);
        $this->getJson($this->url('/transactions?from=2026-11-01&to=2026-11-30'))->assertOk()
            ->assertJsonCount(1, 'data')->assertJsonPath('data.0.description', 'November');

        $res = $this->get($this->url('/export?from=2026-10-01&to=2026-11-30'))->assertOk();
        $this->assertStringContainsString('text/csv', $res->headers->get('Content-Type'));
        $csv = $res->streamedContent();
        $this->assertStringContainsString('Oktober', $csv);
        $this->assertStringContainsString('November', $csv);
    }

    public function test_monthly_report(): void
    {
        $this->tx(['date' => '2026-03-05', 'amount' => 1000]);
        $this->tx(['date' => '2026-03-06', 'amount' => 400, 'flow' => 'out']);
        $res = $this->getJson($this->url('/reports/monthly?year=2026'))->assertOk();
        $this->assertSame(['month' => 3, 'in' => 1000, 'out' => 400], $res->json('months.2'));
        $this->assertCount(12, $res->json('months'));
    }

    public function test_attachment_upload_and_quota(): void
    {
        Storage::fake('local');
        $id = $this->tx()->json('data.id');

        $this->post($this->url("/transactions/{$id}/attachments"), [
            'file' => UploadedFile::fake()->image('nota.jpg')->size(200),
        ], ['Accept' => 'application/json'])->assertCreated();
        $this->assertGreaterThan(0, $this->mosque->fresh()->storage_used_bytes);
        $attId = $this->getJson($this->url("/transactions/{$id}"))->assertOk()->json('data.attachments.0.id');
        $this->get($this->url("/attachments/{$attId}"))->assertOk()->assertDownload('nota.jpg');

        $this->post($this->url("/transactions/{$id}/attachments"), [
            'file' => UploadedFile::fake()->create('virus.exe', 10, 'application/x-msdownload'),
        ], ['Accept' => 'application/json'])->assertUnprocessable();

        // Kuota penuh: upload ditolak, transaksi teks tetap berjalan
        $this->mosque->forceFill(['storage_used_bytes' => Mosque::STORAGE_QUOTA_BYTES - 1000])->save();
        $this->post($this->url("/transactions/{$id}/attachments"), [
            'file' => UploadedFile::fake()->image('nota2.jpg')->size(50),
        ], ['Accept' => 'application/json'])->assertUnprocessable()->assertJsonPath('code', 'storage_quota_exceeded');
        $this->tx()->assertCreated();
    }

    public function test_categories_crud_scoped(): void
    {
        $this->postJson($this->url('/categories'), ['name' => 'Parkir', 'flow' => 'in'])->assertCreated();
        $this->getJson($this->url('/setup'))->assertJsonFragment(['name' => 'Parkir']);
    }

    public function test_finance_writes_are_audited(): void
    {
        $id = $this->tx()->json('data.id');
        $this->postJson($this->url("/transactions/{$id}/reverse"), ['reason' => 'x']);
        $this->getJson("/api/mosques/{$this->mosque->id}/audit-logs")
            ->assertJsonFragment(['action' => 'finance.transaction_created'])
            ->assertJsonFragment(['action' => 'finance.transaction_reversed']);
    }
}
