<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StaffAssignment extends Model
{
    public const DUTIES = ['imam', 'muadzin', 'khatib', 'bilal', 'operator', 'lainnya'];

    public const PRAYERS = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha', 'jumat', 'tarawih', 'ied'];

    protected $guarded = ['id', 'mosque_id'];

    protected function casts(): array
    {
        return ['date' => 'date:Y-m-d'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
