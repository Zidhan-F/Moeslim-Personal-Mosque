<?php

namespace App\Models;

use App\Support\Geohash;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DirectoryEntry extends Model
{
    protected $table = 'mosque_directory';

    public const SOURCES = ['osm', 'simas', 'user', 'moeslim'];

    public const KINDS = ['masjid', 'musala'];

    protected $guarded = ['id'];

    protected function casts(): array
    {
        return ['latitude' => 'float', 'longitude' => 'float', 'verified' => 'boolean', 'locked' => 'boolean', 'last_seen_at' => 'datetime'];
    }

    protected static function booted(): void
    {
        static::saving(function (self $e) {
            $e->geohash = Geohash::encode($e->latitude, $e->longitude, 9);
            $e->cell = substr($e->geohash, 0, Geohash::CELL_PRECISION);
        });
    }

    public function mosque(): BelongsTo
    {
        return $this->belongsTo(Mosque::class);
    }
}
