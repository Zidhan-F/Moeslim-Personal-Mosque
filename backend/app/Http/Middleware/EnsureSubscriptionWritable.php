<?php

namespace App\Http\Middleware;

use App\Services\SubscriptionService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/** Saat langganan berakhir: baca & ekspor tetap, tulis diblokir. */
class EnsureSubscriptionWritable
{
    public function __construct(private readonly SubscriptionService $subs) {}

    public function handle(Request $request, Closure $next): Response
    {
        $mosque = $request->attributes->get('mosque');
        if (! $request->isMethodSafe() && $mosque && ! $this->subs->isWritable($mosque)) {
            return response()->json([
                'code' => 'subscription_inactive',
                'message' => 'Langganan masjid telah berakhir. Data tetap dapat dilihat dan diekspor; perpanjang langganan untuk menambah atau mengubah data.',
            ], 403);
        }

        return $next($request);
    }
}
