<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DistributionCoupon extends Model
{
    public const PROGRAMS = ['qurban', 'zakat', 'baksos'];

    public const STATUSES = ['issued', 'redeemed', 'void'];

    protected $guarded = ['id'];

    protected function casts(): array
    {
        return [
            'hijri_year' => 'integer',
            'redeemed_at' => 'datetime',
        ];
    }

    public function mosque(): BelongsTo
    {
        return $this->belongsTo(Mosque::class);
    }

    public function redeemer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'redeemed_by');
    }
}
