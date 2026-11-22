<?php

namespace Tests\Feature\Api;

use App\Models\DisplayPairingSession;
use App\Models\Mosque;
use App\Models\User;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class WebDisplayQrPairingTest extends TestCase
{
    private User $ownerA;

    private Mosque $mosqueA;

    private User $ownerB;

    private Mosque $mosqueB;

    protected function setUp(): void
    {
        parent::setUp();
        $this->ownerA = $this->verifiedUser();
        $this->mosqueA = $this->createMosque($this->ownerA, ['name' => 'Masjid Al-Ikhlas']);
        $this->ownerB = $this->verifiedUser();
        $this->mosqueB = $this->createMosque($this->ownerB, ['name' => 'Masjid Nurul Iman']);
    }

    public function test_web_tv_shell_manifest_and_sw_are_public_and_leak_no_mosque_data(): void
    {
        $this->get('/tv')
            ->assertOk()
            ->assertSee('Moeslim Mosque TV')
            ->assertSee('/api/display/sessions', false)
            ->assertDontSee('Masjid Al-Ikhlas')
            ->assertDontSee('Masjid Nurul Iman');

        $this->get('/tv/manifest.json')
            ->assertOk()
            ->assertJsonPath('start_url', '/tv')
            ->assertJsonPath('display', 'fullscreen');

        $this->get('/tv/sw.js')
            ->assertOk()
            ->assertHeader('Service-Worker-Allowed', '/tv');
    }

    public function test_reverse_qr_pairing_lifecycle_and_one_time_token_claim(): void
    {
        // 1. TV membuka /tv -> membuat sesi QR tanpa login.
        $created = $this->postJson('/api/display/sessions')
            ->assertCreated()
            ->assertJsonStructure(['session_id', 'poll_secret', 'code', 'qr_payload', 'expires_at'])
            ->json();

        $this->assertSame('MOESLIMTV:'.$created['session_id'], $created['qr_payload']);
        $this->assertMatchesRegularExpression('/^\d{6}$/', $created['code']);

        // 2. Poll sebelum di-scan -> pending.
        $this->postJson("/api/display/sessions/{$created['session_id']}/poll", [
            'poll_secret' => $created['poll_secret'],
        ])->assertOk()->assertJsonPath('status', 'pending');

        // 3. Poll dengan secret salah -> 403 forbidden.
        $this->postJson("/api/display/sessions/{$created['session_id']}/poll", [
            'poll_secret' => 'rahasia-salah',
        ])->assertForbidden();

        // 4. Pengurus Masjid A memindai QR (kirim payload lengkap MOESLIMTV:...).
        Sanctum::actingAs($this->ownerA);
        $deviceId = $this->postJson("/api/mosques/{$this->mosqueA->id}/displays/approve-session", [
            'session_id' => $created['qr_payload'],
            'name' => 'TV Ruang Utama Web',
        ])->assertCreated()
            ->assertJsonPath('data.name', 'TV Ruang Utama Web')
            ->assertJsonPath('data.status', 'active')
            ->json('data.id');

        // 5. TV poll lagi -> menerima token sekali pakai.
        $this->app['auth']->forgetGuards();
        $paired = $this->postJson("/api/display/sessions/{$created['session_id']}/poll", [
            'poll_secret' => $created['poll_secret'],
        ])->assertOk()
            ->assertJsonPath('status', 'paired')
            ->assertJsonPath('device.id', $deviceId)
            ->assertJsonPath('mosque.id', $this->mosqueA->id)
            ->json();

        $token = $paired['token'];
        $this->assertNotEmpty($token);

        // 6. Token di DB sesi langsung dihapus dan poll ulang tidak membocorkan token lagi.
        $sessionRow = DisplayPairingSession::where('session_id', $created['session_id'])->firstOrFail();
        $this->assertNull($sessionRow->encrypted_token);
        $this->assertNotNull($sessionRow->claimed_at);

        $this->postJson("/api/display/sessions/{$created['session_id']}/poll", [
            'poll_secret' => $created['poll_secret'],
        ])->assertOk()->assertJsonPath('status', 'expired');

        // 7. Token hanya mengakses konten Masjid A (isolasi multi-tenant).
        $this->withToken($token)->getJson('/api/display/content')
            ->assertOk()
            ->assertJsonPath('mosque.id', $this->mosqueA->id)
            ->assertJsonPath('mosque.name', 'Masjid Al-Ikhlas')
            ->assertJsonPath('device.name', 'TV Ruang Utama Web');

        // 8. Pengurus bisa memperbarui bahasa & tema perangkat TV, lalu mencabutnya.
        Sanctum::actingAs($this->ownerA);
        $this->patchJson("/api/mosques/{$this->mosqueA->id}/displays/{$deviceId}", [
            'config' => ['theme' => 'dark', 'language' => 'en', 'rotation_seconds' => 20],
        ])->assertOk()
            ->assertJsonPath('data.config.language', 'en')
            ->assertJsonPath('data.config.theme', 'dark');

        $this->postJson("/api/mosques/{$this->mosqueA->id}/displays/{$deviceId}/revoke")->assertOk();

        $this->app['auth']->forgetGuards();
        $this->withToken($token)->getJson('/api/display/content')->assertUnauthorized();
    }

    public function test_approve_session_by_6_digit_code_and_multi_tenant_isolation(): void
    {
        $sessA = $this->postJson('/api/display/sessions')->assertCreated()->json();
        $sessB = $this->postJson('/api/display/sessions')->assertCreated()->json();

        // Masjid A approve via 6 digit code.
        Sanctum::actingAs($this->ownerA);
        $this->postJson("/api/mosques/{$this->mosqueA->id}/displays/approve-session", [
            'code' => $sessA['code'],
            'name' => 'TV Serambi A',
        ])->assertCreated();

        // Sesi yang sudah di-approve tidak bisa dibajak Masjid B.
        Sanctum::actingAs($this->ownerB);
        $this->postJson("/api/mosques/{$this->mosqueB->id}/displays/approve-session", [
            'code' => $sessA['code'],
        ])->assertUnprocessable();

        // Masjid B approve sesi miliknya sendiri.
        $this->postJson("/api/mosques/{$this->mosqueB->id}/displays/approve-session", [
            'session_id' => $sessB['session_id'],
            'name' => 'TV Utama B',
        ])->assertCreated();

        $this->app['auth']->forgetGuards();
        $tokA = $this->postJson("/api/display/sessions/{$sessA['session_id']}/poll", ['poll_secret' => $sessA['poll_secret']])
            ->assertOk()->json('token');
        $tokB = $this->postJson("/api/display/sessions/{$sessB['session_id']}/poll", ['poll_secret' => $sessB['poll_secret']])
            ->assertOk()->json('token');

        $this->withToken($tokA)->getJson('/api/display/content')->assertOk()
            ->assertJsonPath('mosque.name', 'Masjid Al-Ikhlas');
        $this->withToken($tokB)->getJson('/api/display/content')->assertOk()
            ->assertJsonPath('mosque.name', 'Masjid Nurul Iman');
    }

    public function test_expired_session_and_permission_and_5_device_limit_enforced(): void
    {
        $expired = $this->postJson('/api/display/sessions')->assertCreated()->json();
        $this->travel(11)->minutes();

        Sanctum::actingAs($this->ownerA);
        $this->postJson("/api/mosques/{$this->mosqueA->id}/displays/approve-session", [
            'session_id' => $expired['session_id'],
        ])->assertUnprocessable();

        // Bendahara tanpa izin display.manage ditolak.
        $fresh = $this->postJson('/api/display/sessions')->assertCreated()->json();
        $bendahara = $this->addMember($this->mosqueA, 'bendahara');
        Sanctum::actingAs($bendahara);
        $this->postJson("/api/mosques/{$this->mosqueA->id}/displays/approve-session", [
            'session_id' => $fresh['session_id'],
        ])->assertForbidden();

        // Batas maksimal 5 TV aktif tetap berlaku untuk QR pairing.
        Sanctum::actingAs($this->ownerA);
        for ($i = 1; $i <= 5; $i++) {
            $s = $this->postJson('/api/display/sessions')->assertCreated()->json();
            $this->postJson("/api/mosques/{$this->mosqueA->id}/displays/approve-session", [
                'session_id' => $s['session_id'],
                'name' => "TV $i",
            ])->assertCreated();
        }
        $sixth = $this->postJson('/api/display/sessions')->assertCreated()->json();
        $this->postJson("/api/mosques/{$this->mosqueA->id}/displays/approve-session", [
            'session_id' => $sixth['session_id'],
            'name' => 'TV 6',
        ])->assertUnprocessable()->assertJsonPath('code', 'display_limit_reached');
    }
}
