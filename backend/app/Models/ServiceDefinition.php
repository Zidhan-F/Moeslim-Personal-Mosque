<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ServiceDefinition extends Model
{
    use HasUuids;

    public const FIELD_TYPES = ['text', 'textarea', 'select', 'date', 'number'];

    protected $guarded = ['id', 'mosque_id'];

    protected function casts(): array
    {
        return [
            'fields' => 'array',
            'form_version' => 'integer',
            'capacity' => 'integer',
            'closes_at' => 'datetime',
            'active' => 'boolean',
            'retention_days' => 'integer',
        ];
    }

    public function mosque(): BelongsTo
    {
        return $this->belongsTo(Mosque::class);
    }

    public function requests(): HasMany
    {
        return $this->hasMany(ServiceRequest::class);
    }
}
