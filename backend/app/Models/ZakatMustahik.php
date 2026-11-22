<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ZakatMustahik extends Model
{
    public const ASNAFS = ['fakir', 'miskin', 'amil', 'muallaf', 'riqab', 'gharimin', 'fisabilillah', 'ibnu_sabil'];

    public const STATUSES = ['planned', 'distributed'];

    protected $guarded = ['id'];

    protected function casts(): array
    {
        return [
            'hijri_year' => 'integer',
            'money_amount' => 'integer',
            'rice_kg' => 'float',
            'distributed_at' => 'datetime',
        ];
    }

    public function mosque(): BelongsTo
    {
        return $this->belongsTo(Mosque::class);
    }
}
