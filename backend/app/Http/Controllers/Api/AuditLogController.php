<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Mosque;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuditLogController extends Controller
{
    public function index(Request $request, Mosque $mosque): JsonResponse
    {
        $role = $request->attributes->get('membership')->role;
        $query = AuditLog::where('mosque_id', $mosque->id)->orderByDesc('id');

        if ($role !== 'admin') {
            $prefixes = config("permissions.audit_scopes.{$role}", []);
            $query->where(function ($q) use ($prefixes) {
                $q->whereRaw('1 = 0');
                foreach ($prefixes as $p) {
                    $q->orWhere('action', 'like', $p.'%');
                }
            });
        }

        return response()->json($query->paginate(50)->through(fn ($l) => [
            'id' => $l->id,
            'actor_type' => $l->actor_type,
            'actor_id' => $l->actor_id,
            'action' => $l->action,
            'resource_type' => $l->resource_type,
            'resource_id' => $l->resource_id,
            'summary' => $l->summary,
            'created_at' => $l->created_at,
        ]));
    }
}
