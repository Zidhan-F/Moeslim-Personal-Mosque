<?php

namespace Tests\Feature\Api;

use App\Models\Mosque;
use App\Models\User;
use Illuminate\Support\Carbon;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MicrositeTest extends TestCase
{
    private User $owner;

    private Mosque $mosque;

    protected function setUp(): void
    {
        parent::setUp();
        $this->owner = $this->verifiedUser(['email' => 'rahasia-admin@masjid.id']);
        $this->mosque = $this->createMosque($this->owner, [
            'name' => 'Masjid Raya Al-Hidayah',
            'city' => 'Bandung',
        ]);
        Sanctum::actingAs($this->owner);
    }

    public function test_microsite_renders_public_content_only_and_respects_finance_opt_in(): void
    {
        // Agenda publik vs internal
        $this->postJson("/api/mosques/{$this->mosque->id}/events", [
            'title' => 'Kajian Tafsir Subuh',
            'category' => 'kajian',
            'starts_at' => now()->addDay()->toIso8601String(),
            'visibility' => 'public',
        ])->assertCreated();

        $this->postJson("/api/mosques/{$this->mosque->id}/events", [
            'title' => 'Rapat Internal Bendahara Rahasia',
            'category' => 'lainnya',
            'starts_at' => now()->addDay()->toIso8601String(),
            'visibility' => 'internal',
        ])->assertCreated();

        // Petugas Jumat mendatang
        $now = now($this->mosque->timezone)->startOfDay();
        $nextFriday = ($now->isFriday() ? $now : $now->copy()->next(Carbon::FRIDAY))->toDateString();
        $this->postJson("/api/mosques/{$this->mosque->id}/staff-assignments", [
            'duty_type' => 'khatib',
            'prayer' => 'jumat',
            'date' => $nextFriday,
            'external_name' => 'KH. Abdullah Gymnastiar',
        ])->assertCreated();

        // Transaksi kas Rp 750.000
        $this->withHeader('Idempotency-Key', 'ms-kas-1')->postJson("/api/mosques/{$this->mosque->id}/finance/transactions", [
            'flow' => 'in',
            'amount' => 750000,
            'fund_id' => $this->mosque->funds()->value('id'),
            'cash_account_id' => $this->mosque->cashAccounts()->value('id'),
            'date' => $this->mosque->today(),
            'description' => 'Infaq Jamaah',
        ])->assertCreated();

        // Default: public_show_finance = false -> kas tidak ditampilkan; data internal & email tidak bocor!
        $this->app['auth']->forgetGuards();
        $this->get("/m/{$this->mosque->slug}")
            ->assertOk()
            ->assertSee('Masjid Raya Al-Hidayah')
            ->assertSee('Kajian Tafsir Subuh')
            ->assertSee('KH. Abdullah Gymnastiar')
            ->assertDontSee('Rapat Internal Bendahara Rahasia')
            ->assertDontSee('rahasia-admin@masjid.id')
            ->assertDontSee('750.000');

        $this->getJson("/api/public/mosques/{$this->mosque->slug}")
            ->assertOk()
            ->assertJsonPath('data.finance', null)
            ->assertJsonPath('data.friday_staff.items.0.name', 'KH. Abdullah Gymnastiar');

        // Aktifkan opt-in transparansi kas publik
        Sanctum::actingAs($this->owner);
        $this->patchJson("/api/mosques/{$this->mosque->id}", [
            'settings' => ['public_show_finance' => true],
        ])->assertOk();

        $this->app['auth']->forgetGuards();
        $this->get("/m/{$this->mosque->slug}")
            ->assertOk()
            ->assertSee('Transparansi Kas Jumat')
            ->assertSee('750.000');

        $this->getJson("/api/public/mosques/{$this->mosque->slug}")
            ->assertOk()
            ->assertJsonPath('data.finance.balance', 750000);

        $this->get('/m/slug-tidak-ada')->assertNotFound();
    }
}
