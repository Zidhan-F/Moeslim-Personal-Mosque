<?php

namespace Tests\Feature\Api;

use App\Models\User;
use App\Notifications\EmailVerificationCode;
use Illuminate\Support\Facades\Notification;
use Laravel\Sanctum\PersonalAccessToken;
use Tests\TestCase;

class AuthTest extends TestCase
{
    public function test_register_returns_token(): void
    {
        Notification::fake();
        $res = $this->postJson('/api/auth/register', [
            'name' => 'Ahmad',
            'email' => 'ahmad@example.test',
            'password' => 'rahasia-panjang-123',
            'password_confirmation' => 'rahasia-panjang-123',
        ])->assertCreated()->assertJsonStructure(['token', 'user' => ['id', 'name', 'email']]);

        $this->assertNull(User::first()->email_verified_at);
        $this->assertArrayNotHasKey('password', $res->json('user'));
        Notification::assertSentTo(User::first(), EmailVerificationCode::class);
    }

    public function test_register_validates_password_and_unique_email(): void
    {
        User::factory()->create(['email' => 'ada@example.test']);
        $this->postJson('/api/auth/register', [
            'name' => 'X', 'email' => 'ada@example.test', 'password' => 'short', 'password_confirmation' => 'short',
        ])->assertUnprocessable()->assertJsonValidationErrors(['email', 'password']);
    }

    public function test_login_and_logout_revokes_token(): void
    {
        User::factory()->create(['email' => 'a@example.test', 'password' => 'rahasia-panjang-123']);

        $this->postJson('/api/auth/login', ['email' => 'a@example.test', 'password' => 'salah'])
            ->assertUnprocessable();

        $token = $this->postJson('/api/auth/login', [
            'email' => 'a@example.test', 'password' => 'rahasia-panjang-123', 'device_name' => 'hp',
        ])->assertOk()->json('token');

        $this->withToken($token)->getJson('/api/me')->assertOk()->assertJsonPath('user.email', 'a@example.test');
        $this->withToken($token)->postJson('/api/auth/logout')->assertNoContent();
        $this->assertSame(0, PersonalAccessToken::count());
    }

    public function test_email_verification_code_flow(): void
    {
        Notification::fake();
        $user = User::factory()->create(['email_verified_at' => null]);
        $this->actingAs($user, 'sanctum');

        $code = null;
        $this->postJson('/api/auth/email/send-code')->assertNoContent();
        Notification::assertSentTo($user, EmailVerificationCode::class, function ($n) use (&$code) {
            $code = $n->code;

            return true;
        });

        $this->postJson('/api/auth/email/verify', ['code' => '000000' === $code ? '111111' : '000000'])
            ->assertUnprocessable();
        $this->postJson('/api/auth/email/verify', ['code' => $code])->assertOk();
        $this->assertNotNull($user->fresh()->email_verified_at);
    }

    public function test_me_requires_auth(): void
    {
        $this->getJson('/api/me')->assertUnauthorized();
    }
}
