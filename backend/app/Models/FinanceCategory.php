<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FinanceCategory extends Model
{
    protected $guarded = ['id', 'mosque_id'];

    protected function casts(): array
    {
        return ['is_active' => 'boolean'];
    }
}
