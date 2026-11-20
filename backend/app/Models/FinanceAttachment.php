<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FinanceAttachment extends Model
{
    protected $guarded = ['id'];

    protected function casts(): array
    {
        return ['bytes' => 'integer'];
    }
}
