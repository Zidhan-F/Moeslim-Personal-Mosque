<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    public const CATEGORIES = ['kajian', 'jumat', 'ramadan', 'sosial', 'pendidikan', 'lainnya'];

    protected $guarded = ['id', 'mosque_id', 'created_by'];

    protected function casts(): array
    {
        return ['starts_at' => 'datetime', 'ends_at' => 'datetime', 'show_on_display' => 'boolean'];
    }
}
