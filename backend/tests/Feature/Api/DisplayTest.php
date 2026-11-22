<?php

namespace Tests\Feature\Api;

use App\Models\DisplayDevice;
use App\Models\Mosque;
use App\Models\User;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DisplayTest extends TestCase
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

    private function newCode(): string
    {
        return $this->postJson("/api/mosques/{$this->mosque->id}/displays/pairing-codes", ['name' => 'TV Utama'])
            ->assertCreated()->json('data.code');
    }

    private function pair(?string $code = null): string
    {
        $code ??= $this->newCode();
        $this->app['auth']->forgetGuards();

        return $this->postJson('/api/display/pair', ['code' => $code, 'device_name' => 'Android TV'])
            ->assertCreated()->json('token');
    }

    public function test_pairing_code_is_single_use(): void
    {
        $code = $this->newCode();
        $this->assertMatchesRegularExpression('/^\d{6}$/', $code);
        $token = $this->pair($code);
        $this->assertNotEmpty($token);
        $this->postJson('/api/display/pair', ['code' => $code, 'device_name' => 'x'])->assertUnprocessable();
    }

    public function test_expired_code_is_rejected(): void
    {
        $code = $this->newCode();
        $this->travel(11)->minutes();
        $this->postJson('/api/display/pair', ['code' => $code, 'device_name' => 'x'])->assertUnprocessable();
    }

    public function test_max_five_active_displays(): void
    {
        for ($i = 0; $i < Mosque::MAX_DISPLAYS; $i++) {
            Sanctum::actingAs($this->owner);
            $this->pair();
        }
        Sanctum::actingAs($this->owner);
        $this->postJson("/api/mosques/{$this->mosque->id}/displays/pairing-codes")
            ->assertUnprocessable()->assertJsonPath('code', 'display_limit_reached');

        $id = DisplayDevice::first()->id;
        $this->postJson("/api/mosques/{$this->mosque->id}/displays/{$id}/revoke")->assertOk();
        $this->newCode();
    }

    public function test_revoked_device_gets_401(): void
    {
        $token = $this->pair();
        $this->withToken($token)->getJson('/api/display/content')->assertOk();

        Sanctum::actingAs($this->owner);
        $id = DisplayDevice::first()->id;
        $this->postJson("/api/mosques/{$this->mosque->id}/displays/{$id}/revoke")->assertOk();

        $this->app['auth']->forgetGuards();
        $this->withToken($token)->getJson('/api/display/content')->assertUnauthorized();
        $this->withToken('palsu')->getJson('/api/display/content')->assertUnauthorized();
    }

    public function test_content_contains_only_public_data(): void
    {
        $this->postJson("/api/mosques/{$this->mosque->id}/events", [
            'title' => 'Kajian Publik', 'category' => 'kajian', 'starts_at' => now()->addDay(), 'visibility' => 'public',
        ])->assertCreated();
        $this->postJson("/api/mosques/{$this->mosque->id}/events", [
            'title' => 'Rapat Internal', 'category' => 'lainnya', 'starts_at' => now()->addDay(), 'visibility' => 'internal',
        ])->assertCreated();
        $this->postJson("/api/mosques/{$this->mosque->id}/announcements", [
            'title' => 'Disembunyikan', 'body' => 'x', 'visibility' => 'public', 'show_on_display' => false,
        ])->assertCreated();
        $this->postJson("/api/mosques/{$this->mosque->id}/announcements", [
            'title' => 'Tayang', 'body' => 'y', 'visibility' => 'public',
        ])->assertCreated();
        $this->withHeader('Idempotency-Key', 'k1')->postJson("/api/mosques/{$this->mosque->id}/finance/transactions", [
            'flow' => 'in', 'amount' => 500000, 'fund_id' => $this->mosque->funds()->value('id'),
            'cash_account_id' => $this->mosque->cashAccounts()->value('id'), 'date' => now()->toDateString(), 'description' => 'Infaq',
        ])->assertCreated();

        $token = $this->pair();
        $res = $this->withToken($token)->getJson('/api/display/content')->assertOk()
            ->assertJsonPath('mosque.name', $this->mosque->name)
            ->assertJsonPath('mosque.settings.iqamah_minutes.maghrib', 5)
            ->assertJsonStructure(['server_time', 'mosque' => ['latitude', 'longitude', 'timezone', 'prayer_method']])
            ->assertJsonPath('finance', null);
        $body = json_encode($res->json());
        $this->assertStringContainsString('Kajian Publik', $body);
        $this->assertStringNotContainsString('Rapat Internal', $body);
        $this->assertStringNotContainsString('Disembunyikan', $body);
        $this->assertStringContainsString('Tayang', $body);
        $this->assertStringNotContainsString('email', $body);
        $this->assertStringNotContainsString('pengurus_can_view_finance', $body);
        $this->assertNotNull(DisplayDevice::first()->last_seen_at);

        Sanctum::actingAs($this->owner);
        $this->patchJson("/api/mosques/{$this->mosque->id}", ['settings' => ['display_show_finance' => true]])->assertOk();
        $this->app['auth']->forgetGuards();
        $this->withToken($token)->getJson('/api/display/content')->assertJsonPath('finance.balance', 500000);
    }

    public function test_etag_returns_304_when_unchanged(): void
    {
        $token = $this->pair();
        $etag = $this->withToken($token)->getJson('/api/display/content')->headers->get('ETag');
        $this->assertNotEmpty($etag);
        $this->withToken($token)->withHeader('If-None-Match', $etag)->getJson('/api/display/content')->assertStatus(304)
            ->assertHeader('X-Server-Time');
    }

    public function test_only_operator_or_admin_manage_displays(): void
    {
        $p = $this->addMember($this->mosque, 'pengurus');
        $op = $this->addMember($this->mosque, 'operator');
        Sanctum::actingAs($p);
        $this->getJson("/api/mosques/{$this->mosque->id}/displays")->assertOk();
        $this->postJson("/api/mosques/{$this->mosque->id}/displays/pairing-codes")->assertForbidden();
        Sanctum::actingAs($op);
        $this->postJson("/api/mosques/{$this->mosque->id}/displays/pairing-codes")->assertCreated();
    }

    public function test_device_of_other_mosque_cannot_be_revoked(): void
    {
        $this->pair();
        $id = DisplayDevice::first()->id;
        $other = $this->createMosque();
        Sanctum::actingAs($other->members()->first()->user);
        $this->postJson("/api/mosques/{$other->id}/displays/{$id}/revoke")->assertNotFound();
    }

    public function test_design_config_is_validated_saved_and_sent_to_tv(): void
    {
        $token = $this->pair();
        $id = DisplayDevice::first()->id;
        Sanctum::actingAs($this->owner);

        $this->patchJson("/api/mosques/{$this->mosque->id}/displays/{$id}", ['config' => [
            'theme' => 'custom', 'custom_background' => '#123456', 'custom_background_2' => '#000000',
            'custom_accent' => '#D9AB36', 'show_illustration' => false, 'show_ticker' => true,
            'info_seconds' => 30, 'large_clock' => true, 'ticker_text' => '  Kajian Ahad pagi  ',
            'tidak_dikenal' => 'dibuang',
        ]])->assertOk()
            ->assertJsonPath('data.config.theme', 'custom')
            ->assertJsonPath('data.config.ticker_text', 'Kajian Ahad pagi')
            ->assertJsonMissingPath('data.config.tidak_dikenal');

        // Perubahan sebagian mempertahankan kunci lain.
        $this->patchJson("/api/mosques/{$this->mosque->id}/displays/{$id}", ['config' => ['show_hijri' => false]])
            ->assertOk()->assertJsonPath('data.config.custom_background', '#123456')
            ->assertJsonPath('data.config.show_hijri', false);

        foreach ([['theme' => 'pink'], ['custom_accent' => 'merah'], ['info_seconds' => 15], ['ticker_text' => str_repeat('a', 161)]] as $bad) {
            $this->patchJson("/api/mosques/{$this->mosque->id}/displays/{$id}", ['config' => $bad])->assertUnprocessable();
        }

        $this->app['auth']->forgetGuards();
        $this->withToken($token)->getJson('/api/display/content')->assertOk()
            ->assertJsonPath('device.config.theme', 'custom')
            ->assertJsonPath('device.config.info_seconds', 30)
            ->assertJsonPath('device.config.large_clock', true);
    }

    public function test_preview_returns_display_content_for_members_only(): void
    {
        $this->pair();
        $id = DisplayDevice::first()->id;
        Sanctum::actingAs($this->owner);
        $this->postJson("/api/mosques/{$this->mosque->id}/announcements", [
            'title' => 'Tayang di TV', 'body' => 'y', 'visibility' => 'public',
        ])->assertCreated();

        $this->getJson("/api/mosques/{$this->mosque->id}/displays/preview")->assertOk()
            ->assertJsonPath('data.mosque.name', $this->mosque->name)
            ->assertJsonPath('data.announcements.0.title', 'Tayang di TV')
            ->assertJsonStructure(['server_time', 'data' => ['mosque' => ['settings'], 'events', 'staff_today']]);

        $p = $this->addMember($this->mosque, 'pengurus');
        Sanctum::actingAs($p);
        $this->getJson("/api/mosques/{$this->mosque->id}/displays/preview")->assertOk();
        $this->patchJson("/api/mosques/{$this->mosque->id}/displays/{$id}", ['config' => ['theme' => 'dark']])->assertForbidden();

        $outsider = $this->verifiedUser();
        Sanctum::actingAs($outsider);
        // Bukan anggota: tenant disembunyikan (404), sama seperti endpoint masjid lainnya.
        $this->getJson("/api/mosques/{$this->mosque->id}/displays/preview")->assertNotFound();
        $this->getJson("/api/mosques/{$this->mosque->id}/displays/qris-image")->assertNotFound();
    }
}
