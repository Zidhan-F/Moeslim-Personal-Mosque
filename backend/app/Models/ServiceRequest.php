<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ServiceRequest extends Model
{
    use HasUuids;

    public const STATUSES = [
        'submitted',
        'under_review',
        'need_revision',
        'resubmitted',
        'approved',
        'rejected',
        'cancelled',
        'completed',
        'closed',
    ];

    /** Transisi status yang diizinkan di server (§8.3). */
    public const STAFF_TRANSITIONS = [
        'submitted' => ['under_review', 'cancelled'],
        'under_review' => ['need_revision', 'approved', 'rejected'],
        'resubmitted' => ['under_review', 'need_revision', 'approved', 'rejected'],
        'approved' => ['completed', 'cancelled'],
        'rejected' => ['closed'],
        'completed' => ['closed'],
    ];

    public const APPLICANT_CANCELLABLE = ['submitted', 'need_revision'];

    protected $guarded = ['id'];

    protected function casts(): array
    {
        return [
            'answers' => 'array',
            'form_version' => 'integer',
        ];
    }

    public function definition(): BelongsTo
    {
        return $this->belongsTo(ServiceDefinition::class, 'service_definition_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function history(): HasMany
    {
        return $this->hasMany(ServiceRequestHistory::class)->orderBy('created_at');
    }

    public function attachments(): HasMany
    {
        return $this->hasMany(ServiceRequestAttachment::class);
    }
}
