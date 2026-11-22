<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ZakatCollection extends Model
{
    public const TYPES = ['fitrah_money', 'fitrah_rice', 'maal', 'fidyah'];

    protected $guarded = ['id'];

    protected function casts(): array
    {
        return [
            'date' => 'date:Y-m-d',
            'hijri_year' => 'integer',
            'souls_count' => 'integer',
            'money_amount' => 'integer',
            'rice_kg' => 'float',
        ];
    }

    public function mosque(): BelongsTo
    {
        return $this->belongsTo(Mosque::class);
    }

    public function transaction(): BelongsTo
    {
        return $this->belongsTo(FinanceTransaction::class, 'transaction_id');
    }
}
