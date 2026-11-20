<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CashAccount extends Model
{
    public const TYPES = ['cash', 'bank', 'donation_box'];

    protected $guarded = ['id', 'mosque_id'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }
}
