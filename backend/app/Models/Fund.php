<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Fund extends Model
{
    protected $guarded = ['id', 'mosque_id'];

    protected function casts(): array
    {
        return ['restricted' => 'boolean', 'is_active' => 'boolean'];
    }
}
