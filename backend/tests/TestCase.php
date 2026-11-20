<?php

namespace Tests;

use App\Models\Mosque;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Laravel\Sanctum\Sanctum;

abstract class TestCase extends BaseTestCase
{
    use RefreshDatabase;

    protected function verifiedUser(array $attrs = []): User
    {
        return User::factory()->create($attrs + ['email_verified_at' => now()]);
    }

    /** Buat masjid lewat API sehingga seluruh efek registrasi ikut terjadi. */
    protected function createMosque(?User $owner = null, array $attrs = []): Mosque
    {
        $owner ??= $this->verifiedUser();
        Sanctum::actingAs($owner);
        $res = $this->postJson('/api/mosques', $attrs + [
            'name' => 'Masjid '.fake()->unique()->lastName(),
            'address' => 'Jl. Contoh No. 1',
            'city' => 'Bandung',
            'province' => 'Jawa Barat',
            'latitude' => -6.9175,
            'longitude' => 107.6191,
            'timezone' => 'Asia/Jakarta',
        ])->assertCreated();

        return Mosque::findOrFail($res->json('data.id'));
    }

    /** Tambahkan anggota aktif dengan role tertentu langsung (tanpa alur undangan). */
    protected function addMember(Mosque $mosque, string $role, ?User $user = null): User
    {
        $user ??= $this->verifiedUser();
        $mosque->members()->create([
            'user_id' => $user->id,
            'role' => $role,
            'status' => 'active',
            'activated_at' => now(),
        ]);

        return $user;
    }
}
