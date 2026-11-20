<?php

namespace App\Http\Middleware;

use App\Models\DisplayDevice;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AuthenticateDisplay
{
    public function handle(Request $request, Closure $next): Response
    {
        $token = $request->bearerToken();
        $device = $token
            ? DisplayDevice::where('token_hash', DisplayDevice::hashToken($token))->where('status', 'active')->first()
            : null;
        abort_if($device === null, 401, 'Perangkat display tidak terdaftar atau telah dicabut.');

        $request->attributes->set('display', $device);

        return $next($request);
    }
}
