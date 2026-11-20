<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DisplayPairingCode extends Model
{
    public const TTL_MINUTES = 10;

    protected $guarded = ['id'];

    protected function casts(): array
    {
        return ['expires_at' => 'datetime', 'used_at' => 'datetime'];
    }

    public static function hashCode(string $code): string
    {
        return hash_hmac('sha256', 'pair:'.$code, (string) config('app.key'));
    }

    public function scopeUsable($q)
    {
        return $q->whereNull('used_at')->where('expires_at', '>', now());
    }
}
