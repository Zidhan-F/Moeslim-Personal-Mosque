<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MosqueMember extends Model
{
    public const ROLES = ['admin', 'bendahara', 'pengurus', 'operator'];

    protected $guarded = ['id'];

    protected function casts(): array
    {
        return [
            'is_owner' => 'boolean',
            'activated_at' => 'datetime',
            'deactivated_at' => 'datetime',
        ];
    }

    public function mosque(): BelongsTo
    {
        return $this->belongsTo(Mosque::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
