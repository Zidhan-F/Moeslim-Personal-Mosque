<?php

namespace App\Http\Middleware;

use App\Support\Permissions;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RequirePermission
{
    public function handle(Request $request, Closure $next, string $permission): Response
    {
        $membership = $request->attributes->get('membership');
        $mosque = $request->attributes->get('mosque');
        abort_unless($membership && Permissions::allows($membership, $permission, $mosque), 403, 'Anda tidak memiliki izin untuk tindakan ini.');

        return $next($request);
    }
}
