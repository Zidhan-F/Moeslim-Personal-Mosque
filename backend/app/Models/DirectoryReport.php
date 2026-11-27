<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DirectoryReport extends Model
{
    public const TYPES = ['wrong_location', 'not_exists', 'wrong_name', 'new_mosque'];

    protected $guarded = ['id'];

    protected function casts(): array
    {
        return ['latitude' => 'float', 'longitude' => 'float', 'resolved_at' => 'datetime'];
    }

    public function entry(): BelongsTo
    {
        return $this->belongsTo(DirectoryEntry::class, 'directory_id');
    }
}
