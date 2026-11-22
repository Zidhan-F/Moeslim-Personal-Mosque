<?php

namespace Tests\Feature\Api;

use App\Models\Mosque;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DisplayProTest extends TestCase
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

    private function pair(): string
    {
        $code = $this->postJson("/api/mosques/{$this->mosque->id}/displays/pairing-codes", ['name' => 'TV Utama'])
            ->assertCreated()->json('data.code');
        $this->app['auth']->forgetGuards();

        return $this->postJson('/api/display/pair', ['code' => $code, 'device_name' => 'Android TV'])
            ->assertCreated()->json('token');
    }

    public function test_prayer_silent_mode_and_iqamah_settings_sync_to_display(): void
    {
        $this->patchJson("/api/mosques/{$this->mosque->id}", [
            'settings' => [
                'iqamah_minutes' => ['fajr' => 12, 'dhuhr' => 8, 'asr' => 9, 'maghrib' => 6, 'isha' => 11],
                'praying_minutes' => ['fajr' => 15, 'dhuhr' => 15, 'asr' => 15, 'maghrib' => 12, 'isha' => 15, 'jumuah' => 50],
                'silent_prayer_screen' => true,
                'silent_prayer_message' => 'Harap matikan ponsel dan rapatkan shaf',
                'iqamah_beep' => true,
            ],
        ])->assertOk()
            ->assertJsonPath('data.settings.praying_minutes.jumuah', 50)
            ->assertJsonPath('data.settings.silent_prayer_message', 'Harap matikan ponsel dan rapatkan shaf');

        $token = $this->pair();
        $this->withToken($token)->getJson('/api/display/content')->assertOk()
            ->assertJsonPath('mosque.settings.iqamah_minutes.fajr', 12)
            ->assertJsonPath('mosque.settings.praying_minutes.jumuah', 50)
            ->assertJsonPath('mosque.settings.silent_prayer_screen', true)
            ->assertJsonPath('mosque.settings.silent_prayer_message', 'Harap matikan ponsel dan rapatkan shaf')
            ->assertJsonPath('mosque.settings.iqamah_beep', true);
    }

    public function test_emergency_duka_override_lifecycle_and_expiry(): void
    {
        $token = $this->pair();
        Sanctum::actingAs($this->owner);

        $this->postJson("/api/mosques/{$this->mosque->id}/displays/override", [
            'type' => 'duka',
            'title' => 'Berita Duka',
            'body' => 'Telah berpulang ke rahmatullah Bapak H. Budi Santoso. Jenazah disalatkan bakda Dzuhur.',
            'duration_minutes' => 60,
        ])->assertOk()
            ->assertJsonPath('data.type', 'duka')
            ->assertJsonPath('data.title', 'Berita Duka');

        $this->app['auth']->forgetGuards();
        $this->withToken($token)->getJson('/api/display/content')->assertOk()
            ->assertJsonPath('override.type', 'duka')
            ->assertJsonPath('override.title', 'Berita Duka');

        // Saat sudah lewat durasi, override otomatis tidak lagi dikirim ke TV.
        $this->travel(61)->minutes();
        $this->withToken($token)->getJson('/api/display/content')->assertOk()
            ->assertJsonPath('override', null);

        // Set lagi lalu hentikan manual.
        Sanctum::actingAs($this->owner);
        $this->postJson("/api/mosques/{$this->mosque->id}/displays/override", [
            'type' => 'darurat',
            'title' => 'Info Parkir',
            'body' => 'Mohon pemilik mobil B 1234 XY menggeser kendaraan.',
            'duration_minutes' => 30,
        ])->assertOk();
        $this->deleteJson("/api/mosques/{$this->mosque->id}/displays/override")->assertOk();

        $this->app['auth']->forgetGuards();
        $this->withToken($token)->getJson('/api/display/content')->assertOk()
            ->assertJsonPath('override', null);
    }

    public function test_qris_upload_display_serving_and_friday_finance_summary(): void
    {
        Storage::fake('local');
        config(['filesystems.attachments_disk' => 'local']);

        $fundId = $this->mosque->funds()->value('id');
        $accId = $this->mosque->cashAccounts()->value('id');
        $this->withHeader('Idempotency-Key', 'k-qris-1')->postJson("/api/mosques/{$this->mosque->id}/finance/transactions", [
            'flow' => 'in',
            'amount' => 750000,
            'fund_id' => $fundId,
            'cash_account_id' => $accId,
            'date' => now($this->mosque->timezone)->toDateString(),
            'description' => 'Kotak Amal Jumat',
        ])->assertCreated();

        $this->patchJson("/api/mosques/{$this->mosque->id}", [
            'settings' => [
                'display_show_finance' => true,
                'qris_label' => 'QRIS Infaq Masjid Al-Ikhlas',
            ],
        ])->assertOk();

        $png = UploadedFile::fake()->createWithContent(
            'qris.png',
            base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aK1kAAAAASUVORK5CYII=')
        );
        $this->post("/api/mosques/{$this->mosque->id}/displays/qris", [
            'file' => $png,
            'label' => 'QRIS Infaq Masjid Al-Ikhlas',
        ])->assertCreated()
            ->assertJsonPath('data.enabled', true);

        $token = $this->pair();
        $this->withToken($token)->getJson('/api/display/content')->assertOk()
            ->assertJsonPath('qris.enabled', true)
            ->assertJsonPath('qris.label', 'QRIS Infaq Masjid Al-Ikhlas')
            ->assertJsonPath('finance.balance', 750000)
            ->assertJsonPath('finance.week_in', 750000);

        $this->withToken($token)->get('/api/display/qris')->assertOk();

        // Hapus QRIS
        Sanctum::actingAs($this->owner);
        $this->deleteJson("/api/mosques/{$this->mosque->id}/displays/qris")->assertOk();
        $this->app['auth']->forgetGuards();
        $this->withToken($token)->getJson('/api/display/content')->assertOk()
            ->assertJsonPath('qris', null);
    }

    public function test_friday_staff_board_appears_automatically_for_upcoming_friday(): void
    {
        // Set ke hari Kamis 2026-11-19 -> Jumat terdekat 2026-11-20.
        $this->travelTo(Carbon::parse('2026-11-19 10:00:00', 'Asia/Jakarta'));

        $this->postJson("/api/mosques/{$this->mosque->id}/staff-assignments", [
            'duty_type' => 'khatib',
            'prayer' => 'dhuhr',
            'date' => '2026-11-20',
            'external_name' => 'Ust. Dr. Ahmad Fauzan',
        ])->assertCreated();
        $this->postJson("/api/mosques/{$this->mosque->id}/staff-assignments", [
            'duty_type' => 'imam',
            'prayer' => 'dhuhr',
            'date' => '2026-11-20',
            'external_name' => 'Ust. Hafidz Rahman',
        ])->assertCreated();
        $this->postJson("/api/mosques/{$this->mosque->id}/staff-assignments", [
            'duty_type' => 'bilal',
            'prayer' => 'dhuhr',
            'date' => '2026-11-20',
            'external_name' => 'Bpk. Ridwan',
        ])->assertCreated();

        $token = $this->pair();
        $this->withToken($token)->getJson('/api/display/content')->assertOk()
            ->assertJsonPath('friday_staff.date', '2026-11-20')
            ->assertJsonCount(3, 'friday_staff.items');
    }

    public function test_only_display_manager_can_trigger_override_or_upload_qris(): void
    {
        $bendahara = $this->addMember($this->mosque, 'bendahara');
        Sanctum::actingAs($bendahara);
        $this->postJson("/api/mosques/{$this->mosque->id}/displays/override", [
            'type' => 'darurat', 'title' => 'x', 'body' => 'y', 'duration_minutes' => 15,
        ])->assertForbidden();
    }
}
