<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DisplayPairingSession extends Model
{
    public const TTL_MINUTES = 10;

    protected $guarded = ['id'];

    protected $hidden = ['secret_hash', 'encrypted_token'];

    protected function casts(): array
    {
        return [
            'expires_at' => 'datetime',
            'approved_at' => 'datetime',
            'claimed_at' => 'datetime',
        ];
    }

    public static function hashSecret(string $secret): string
    {
        return hash_hmac('sha256', 'tvsess:'.$secret, (string) config('app.key'));
    }

    public function scopeActive($q)
    {
        return $q->whereNull('claimed_at')->where('expires_at', '>', now());
    }

    public function scopePendingApproval($q)
    {
        return $q->whereNull('approved_at')->whereNull('claimed_at')->where('expires_at', '>', now());
    }

    public function mosque(): BelongsTo
    {
        return $this->belongsTo(Mosque::class);
    }

    public function displayDevice(): BelongsTo
    {
        return $this->belongsTo(DisplayDevice::class);
    }
}
