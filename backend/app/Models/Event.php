<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Event extends Model
{
    public const CATEGORIES = ['kajian', 'jumat', 'ramadan', 'sosial', 'pendidikan', 'lainnya'];

    public const PUBLICATION_STATUSES = ['draft', 'published', 'updated', 'cancelled', 'completed'];

    protected $guarded = ['id', 'mosque_id', 'created_by'];

    protected function casts(): array
    {
        return [
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
            'registration_closes_at' => 'datetime',
            'show_on_display' => 'boolean',
            'registration_enabled' => 'boolean',
            'waitlist_enabled' => 'boolean',
            'hijri_year' => 'integer',
            'capacity' => 'integer',
            'version' => 'integer',
        ];
    }

    public function mosque(): BelongsTo
    {
        return $this->belongsTo(Mosque::class);
    }

    public function registrations(): HasMany
    {
        return $this->hasMany(EventRegistration::class);
    }
}
