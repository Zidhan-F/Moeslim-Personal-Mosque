<?php

namespace Tests\Feature\Api;

use App\Models\Mosque;
use App\Models\User;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MosqueRegistrationTest extends TestCase
{
    private array $payload = [
        'name' => 'Masjid Al-Ikhlas',
        'address' => 'Jl. Merdeka 10',
        'city' => 'Bandung',
        'province' => 'Jawa Barat',
        'latitude' => -6.9175,
        'longitude' => 107.6191,
        'timezone' => 'Asia/Jakarta',
    ];

    public function test_unverified_user_cannot_register_mosque(): void
    {
        Sanctum::actingAs(User::factory()->create(['email_verified_at' => null]));
        $this->postJson('/api/mosques', $this->payload)->assertForbidden();
    }

    public function test_register_mosque_creates_owner_admin_and_trial(): void
    {
        $user = $this->verifiedUser();
        Sanctum::actingAs($user);

        $res = $this->postJson('/api/mosques', $this->payload)->assertCreated();
        $mosque = Mosque::findOrFail($res->json('data.id'));

        $this->assertSame('masjid-al-ikhlas', $mosque->slug);
        $this->assertSame('kemenag', $mosque->prayer_method);
        $this->assertFalse($mosque->needs_review);
        $member = $mosque->members()->first();
        $this->assertSame($user->id, $member->user_id);
        $this->assertSame('admin', $member->role);
        $this->assertTrue($member->is_owner);
        $sub = $mosque->subscription;
        $this->assertSame('trialing', $sub->state);
        $this->assertEqualsWithDelta(30, now()->diffInDays($sub->trial_ends_at), 1);
        $res->assertJsonPath('data.role', 'admin');
    }

    public function test_slug_is_unique_and_duplicates_are_flagged(): void
    {
        Sanctum::actingAs($this->verifiedUser());
        $this->postJson('/api/mosques', $this->payload)->assertCreated();

        Sanctum::actingAs($this->verifiedUser());
        $res = $this->postJson('/api/mosques', ['name' => 'Masjid Al Ikhlas'] + $this->payload)->assertCreated();

        $this->assertSame('masjid-al-ikhlas-2', $res->json('data.slug'));
        $this->assertTrue($res->json('data.duplicate_suspected'));
        $this->assertTrue(Mosque::where('slug', 'masjid-al-ikhlas-2')->first()->needs_review);
    }

    public function test_validation(): void
    {
        Sanctum::actingAs($this->verifiedUser());
        $this->postJson('/api/mosques', ['name' => '', 'latitude' => 200, 'timezone' => 'Mars/Base'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['name', 'latitude', 'timezone', 'city']);
    }

    public function test_my_mosques_lists_only_memberships(): void
    {
        $user = $this->verifiedUser();
        $this->createMosque($user);
        $this->createMosque(); // milik orang lain
        Sanctum::actingAs($user);
        $this->getJson('/api/mosques')->assertOk()->assertJsonCount(1, 'data');
    }
}
