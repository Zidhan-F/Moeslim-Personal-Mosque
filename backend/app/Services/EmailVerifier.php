<?php

namespace App\Services;

use App\Models\User;
use App\Notifications\EmailVerificationCode;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;

class EmailVerifier
{
    private const TTL_MINUTES = 15;
    private const MAX_ATTEMPTS = 5;

    public function send(User $user): void
    {
        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        Cache::put($this->key($user), ['hash' => Hash::make($code), 'attempts' => 0], now()->addMinutes(self::TTL_MINUTES));
        $user->notify(new EmailVerificationCode($code));
    }

    public function verify(User $user, string $code): bool
    {
        $entry = Cache::get($this->key($user));
        if (! $entry || $entry['attempts'] >= self::MAX_ATTEMPTS) {
            return false;
        }
        if (! Hash::check($code, $entry['hash'])) {
            $entry['attempts']++;
            Cache::put($this->key($user), $entry, now()->addMinutes(self::TTL_MINUTES));

            return false;
        }
        Cache::forget($this->key($user));
        $user->forceFill(['email_verified_at' => now()])->save();

        return true;
    }

    private function key(User $user): string
    {
        return "email-verify:{$user->id}";
    }
}
