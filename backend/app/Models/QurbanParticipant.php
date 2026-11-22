<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class QurbanParticipant extends Model
{
    public const PAYMENT_STATUSES = ['unpaid', 'dp', 'paid'];

    protected $guarded = ['id'];

    protected function casts(): array
    {
        return [
            'shares' => 'integer',
            'amount_idr' => 'integer',
            'meat_taken' => 'boolean',
        ];
    }

    public function mosque(): BelongsTo
    {
        return $this->belongsTo(Mosque::class);
    }

    public function animal(): BelongsTo
    {
        return $this->belongsTo(QurbanAnimal::class, 'animal_id');
    }
}
