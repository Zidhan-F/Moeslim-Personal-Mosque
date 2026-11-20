<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Announcement extends Model
{
    protected $guarded = ['id', 'mosque_id', 'created_by'];

    protected function casts(): array
    {
        return ['publish_at' => 'datetime', 'expires_at' => 'datetime', 'show_on_display' => 'boolean', 'priority' => 'integer'];
    }

    /** Pengumuman yang sedang tayang (aktif, sudah terbit, belum kedaluwarsa). */
    public function scopeLive($q)
    {
        return $q->where('status', 'active')
            ->where(fn ($w) => $w->whereNull('publish_at')->orWhere('publish_at', '<=', now()))
            ->where(fn ($w) => $w->whereNull('expires_at')->orWhere('expires_at', '>', now()));
    }
}
