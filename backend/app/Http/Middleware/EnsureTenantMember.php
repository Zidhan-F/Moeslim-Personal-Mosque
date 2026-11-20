<?php

namespace App\Http\Middleware;

use App\Models\Mosque;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Resolve tenant dari parameter route {mosque} dan pastikan pengguna adalah
 * anggota aktif. Non-anggota mendapat 404 agar keberadaan tenant tidak bocor.
 */
class EnsureTenantMember
{
    public function handle(Request $request, Closure $next): Response
    {
        $mosque = $request->route('mosque');
        if (! $mosque instanceof Mosque) {
            $mosque = Mosque::find($mosque);
        }
        $membership = $mosque ? $request->user()?->activeMembershipFor($mosque->id) : null;
        abort_if($membership === null, 404);

        $request->route()->setParameter('mosque', $mosque);
        $request->attributes->set('mosque', $mosque);
        $request->attributes->set('membership', $membership);

        return $next($request);
    }
}
