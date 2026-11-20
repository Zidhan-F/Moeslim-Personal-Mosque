<?php

namespace Tests\Feature\Api;

use App\Models\Mosque;
use App\Models\User;
use Illuminate\Support\Facades\Artisan;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SubscriptionPublicDashboardTest extends TestCase
{
    private User $owner;

    private Mosque $mosque;

    protected function setUp(): void
    {
        parent::setUp();
        $this->owner = $this->verifiedUser();
        $this->mosque = $this->createMosque($this->owner, ['name' => 'Masjid Raya Contoh']);
        Sanctum::actingAs($this->owner);
    }

    public function test_subscription_status_and_usage(): void
    {
        $this->getJson("/api/mosques/{$this->mosque->id}/subscription")->assertOk()
            ->assertJsonPath('data.state', 'trialing')
            ->assertJsonPath('data.price_idr', 59000)
            ->assertJsonPath('usage.members.used', 1)
            ->assertJsonPath('usage.members.limit', 5)
            ->assertJsonPath('usage.storage.limit', 1073741824)
            ->assertJsonPath('usage.storage.level', 'ok');
    }

    public function test_grace_then_expired_blocks_writes_but_not_reads(): void
    {
        $this->travel(31)->days();
        $this->getJson("/api/mosques/{$this->mosque->id}/subscription")->assertJsonPath('data.state', 'grace');
        $this->postJson("/api/mosques/{$this->mosque->id}/events", [
            'title' => 'x', 'category' => 'kajian', 'starts_at' => now()->addDay(), 'visibility' => 'public',
        ])->assertCreated();

        $this->travel(8)->days();
        $this->getJson("/api/mosques/{$this->mosque->id}/subscription")->assertJsonPath('data.state', 'expired');
        $this->postJson("/api/mosques/{$this->mosque->id}/events", [
            'title' => 'y', 'category' => 'kajian', 'starts_at' => now()->addDay(), 'visibility' => 'public',
        ])->assertForbidden()->assertJsonPath('code', 'subscription_inactive');
        $this->getJson("/api/mosques/{$this->mosque->id}/events")->assertOk();
        $this->get("/api/mosques/{$this->mosque->id}/finance/export?from=2026-01-01&to=2027-12-31")->assertOk();

        // aktivasi oleh operator platform
        Artisan::call('moeslim:subscription:activate', ['mosque' => $this->mosque->slug, '--months' => 1]);
        $this->getJson("/api/mosques/{$this->mosque->id}/subscription")->assertJsonPath('data.state', 'active');
        $this->postJson("/api/mosques/{$this->mosque->id}/events", [
            'title' => 'z', 'category' => 'kajian', 'starts_at' => now()->addDay(), 'visibility' => 'public',
        ])->assertCreated();
    }

    public function test_google_play_verification_not_configured(): void
    {
        $this->postJson("/api/mosques/{$this->mosque->id}/subscription/verify", [
            'provider' => 'google_play', 'purchase_token' => 'abc', 'product_id' => 'masjid_monthly',
        ])->assertStatus(503)->assertJsonPath('code', 'billing_not_configured');
    }

    public function test_only_admin_can_access_billing(): void
    {
        $b = $this->addMember($this->mosque, 'bendahara');
        Sanctum::actingAs($b);
        $this->postJson("/api/mosques/{$this->mosque->id}/subscription/verify", ['provider' => 'google_play', 'purchase_token' => 'x', 'product_id' => 'y'])
            ->assertForbidden();
    }

    public function test_public_profile_uses_allowlist(): void
    {
        $this->patchJson("/api/mosques/{$this->mosque->id}", ['phone' => '0812-internal', 'simas_id' => '01.2.3'])->assertOk();
        $this->postJson("/api/mosques/{$this->mosque->id}/events", [
            'title' => 'Kajian Umum', 'category' => 'kajian', 'starts_at' => now()->addDay(), 'visibility' => 'public',
        ]);
        $this->postJson("/api/mosques/{$this->mosque->id}/events", [
            'title' => 'Rapat Pengurus', 'category' => 'lainnya', 'starts_at' => now()->addDay(), 'visibility' => 'internal',
        ]);
        $this->postJson("/api/mosques/{$this->mosque->id}/announcements", ['title' => 'Info Publik', 'body' => 'b', 'visibility' => 'public']);
        $this->app['auth']->forgetGuards();

        $res = $this->getJson("/api/public/mosques/{$this->mosque->slug}")->assertOk()
            ->assertJsonPath('data.name', 'Masjid Raya Contoh')
            ->assertJsonStructure(['data' => ['latitude', 'longitude', 'timezone', 'prayer_method', 'settings' => ['iqamah_minutes']]]);
        $body = json_encode($res->json());
        foreach (['0812-internal', 'simas', 'storage_used', 'needs_review', 'created_by', 'pengurus_can_view_finance', 'display_show_finance'] as $secret) {
            $this->assertStringNotContainsString($secret, $body);
        }

        $this->getJson("/api/public/mosques/{$this->mosque->slug}/events")->assertOk()
            ->assertJsonCount(1, 'data')->assertJsonPath('data.0.title', 'Kajian Umum')
            ->assertJsonMissingPath('data.0.created_by');
        $this->getJson("/api/public/mosques/{$this->mosque->slug}/announcements")->assertOk()->assertJsonCount(1, 'data');
        $this->getJson('/api/public/mosques?q=raya')->assertOk()->assertJsonPath('data.0.slug', $this->mosque->slug);
        $this->getJson('/api/public/mosques/tidak-ada')->assertNotFound();
    }

    public function test_dashboard_respects_finance_permission(): void
    {
        $this->withHeader('Idempotency-Key', 'd1')->postJson("/api/mosques/{$this->mosque->id}/finance/transactions", [
            'flow' => 'in', 'amount' => 250000, 'fund_id' => $this->mosque->funds()->value('id'),
            'cash_account_id' => $this->mosque->cashAccounts()->value('id'), 'date' => now()->toDateString(), 'description' => 'Infaq',
        ])->assertCreated();

        $this->getJson("/api/mosques/{$this->mosque->id}/dashboard")->assertOk()
            ->assertJsonPath('finance.balance', 250000)
            ->assertJsonPath('finance.month_in', 250000)
            ->assertJsonPath('subscription.state', 'trialing')
            ->assertJsonStructure(['upcoming_events', 'staff_today', 'displays' => ['active', 'online'], 'warnings', 'permissions']);

        $op = $this->addMember($this->mosque, 'operator');
        Sanctum::actingAs($op);
        $this->getJson("/api/mosques/{$this->mosque->id}/dashboard")->assertOk()->assertJsonPath('finance', null);
    }

    public function test_storage_warning_levels(): void
    {
        $this->mosque->forceFill(['storage_used_bytes' => (int) (Mosque::STORAGE_QUOTA_BYTES * 0.96)])->save();
        $this->getJson("/api/mosques/{$this->mosque->id}/subscription")->assertJsonPath('usage.storage.level', 'critical');
        $this->getJson("/api/mosques/{$this->mosque->id}/dashboard")->assertJsonFragment(['storage_critical']);
    }

    public function test_account_deletion_anonymizes_user(): void
    {
        // pemilik masjid tidak dapat menghapus akun sebelum memindahkan kepemilikan
        $this->deleteJson('/api/me', ['password' => 'password'])->assertUnprocessable()->assertJsonPath('code', 'owner_must_transfer');

        $p = $this->addMember($this->mosque, 'pengurus', User::factory()->create(['password' => 'rahasia-panjang-123', 'email_verified_at' => now()]));
        $p->createToken('hp');
        Sanctum::actingAs($p);
        $this->deleteJson('/api/me', ['password' => 'salah'])->assertUnprocessable();
        $this->deleteJson('/api/me', ['password' => 'rahasia-panjang-123'])->assertNoContent();

        $p->refresh();
        $this->assertSame('Pengguna terhapus', $p->name);
        $this->assertStringEndsWith('@deleted.invalid', $p->email);
        $this->assertSame(0, $p->tokens()->count());
        $this->assertSame('inactive', $this->mosque->members()->where('user_id', $p->id)->value('status'));
    }
}
