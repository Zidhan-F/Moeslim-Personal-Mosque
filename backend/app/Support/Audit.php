<?php

namespace App\Support;

use App\Models\AuditLog;
use App\Models\Mosque;
use Illuminate\Database\Eloquent\Model;

class Audit
{
    public static function log(?Mosque $mosque, string $action, ?Model $resource = null, ?array $summary = null, string $actorType = 'user', ?int $actorId = null): void
    {
        $request = request();
        AuditLog::create([
            'mosque_id' => $mosque?->id,
            'actor_type' => $actorType,
            'actor_id' => $actorId ?? ($actorType === 'user' ? $request?->user()?->id : null),
            'action' => $action,
            'resource_type' => $resource ? class_basename($resource) : null,
            'resource_id' => $resource ? (string) $resource->getKey() : null,
            'summary' => $summary,
            'ip' => $request?->ip(),
        ]);
    }
}
