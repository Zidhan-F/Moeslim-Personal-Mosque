<?php

namespace Tests\Feature\Api;

use App\Models\Mosque;
use App\Models\User;
use Illuminate\Support\Carbon;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ReviewFixesTest extends TestCase
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

    private function tx(string $key, array $over = [])
    {
        return $this->withHeader('Idempotency-Key', $key)->postJson("/api/mosques/{$this->mosque->id}/finance/transactions", $over + [
            'flow' => 'in', 'amount' => 1000, 'fund_id' => $this->mosque->funds()->value('id'),
            'cash_account_id' => $this->mosque->cashAccounts()->value('id'), 'date' => '2026-11-01', 'description' => 'Infaq',
        ]);
    }

    public function test_admin_cannot_demote_owner(): void
    {
        $b = $this->addMember($this->mosque, 'admin');
        $ownerMember = $this->mosque->members()->where('user_id', $this->owner->id)->value('id');
        Sanctum::actingAs($b);
        $this->patchJson("/api/mosques/{$this->mosque->id}/members/{$ownerMember}", ['role' => 'operator'])
            ->assertUnprocessable()->assertJsonPath('code', 'owner_role_locked');
    }

    public function test_reserved_idempotency_key_prefix_is_rejected(): void
    {
        $id = $this->tx('k-1')->assertCreated()->json('data.id');
        $this->tx('reversal:'.($id + 1))->assertUnprocessable()->assertJsonPath('code', 'idempotency_key_reserved');
        $this->postJson("/api/mosques/{$this->mosque->id}/finance/transactions/{$id}/reverse", ['reason' => 'x'])->assertCreated();
    }

    public function test_reversal_is_dated_in_mosque_timezone(): void
    {
        $id = $this->tx('k-2')->json('data.id');
        $this->travelTo(Carbon::parse('2026-11-30 23:30:00', 'UTC')); // 1 Des 06:30 WIB
        $this->postJson("/api/mosques/{$this->mosque->id}/finance/transactions/{$id}/reverse", ['reason' => 'x'])
            ->assertCreated()->assertJsonPath('data.date', '2026-12-01')
            ->assertJsonPath('data.reference_no', 'TRX-202612-00001');
    }

    public function test_explicit_nulls_do_not_cause_500(): void
    {
        $this->postJson("/api/mosques/{$this->mosque->id}/announcements", [
            'title' => 'a', 'body' => 'b', 'visibility' => 'public', 'priority' => null, 'show_on_display' => null,
        ])->assertCreated()->assertJsonPath('data.priority', 1)->assertJsonPath('data.show_on_display', true);
        $this->postJson("/api/mosques/{$this->mosque->id}/events", [
            'title' => 'e', 'category' => 'kajian', 'starts_at' => now()->addDay(), 'visibility' => 'public', 'show_on_display' => null,
        ])->assertCreated();
    }

    public function test_csv_neutralizes_formulas_in_all_text_cells(): void
    {
        $acc = $this->postJson("/api/mosques/{$this->mosque->id}/finance/accounts", ['name' => '=HYPERLINK("x")', 'type' => 'bank'])->json('data.id');
        $this->tx('k-3', ['cash_account_id' => $acc]);
        $csv = $this->get("/api/mosques/{$this->mosque->id}/finance/export?from=2026-11-01&to=2026-11-30")->streamedContent();
        $this->assertStringNotContainsString(',"=HYPERLINK', $csv);
        $this->assertStringContainsString("'=HYPERLINK", $csv);
    }
}
