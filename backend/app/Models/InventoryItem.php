<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class InventoryItem extends Model
{
    public const CONDITIONS = ['baik', 'rusak_ringan', 'rusak_berat', 'hilang'];

    protected $guarded = ['id', 'mosque_id'];

    protected function casts(): array
    {
        return ['quantity' => 'integer'];
    }

    public function maintenance(): HasMany
    {
        return $this->hasMany(InventoryMaintenance::class)->orderByDesc('date');
    }
}
