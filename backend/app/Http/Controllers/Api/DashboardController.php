<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mosque;
use App\Services\FinanceService;
use App\Services\SubscriptionService;
use App\Support\Permissions;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function __invoke(Request $request, Mosque $mosque, FinanceService $finance, SubscriptionService $subs): JsonResponse
    {
        $membership = $request->attributes->get('membership');
        $tz = $mosque->timezone;
        $now = now($tz);

        $financeData = null;
        if (Permissions::allows($membership, 'finance.view', $mosque)) {
            $flows = $mosque->transactions()
                ->whereBetween('date', [$now->copy()->startOfMonth()->toDateString(), $now->copy()->endOfMonth()->toDateString()])
                ->selectRaw("coalesce(sum(case when flow='in' then amount end),0) as i, coalesce(sum(case when flow='out' then amount end),0) as o")
                ->first();
            $funds = $finance->fundBalances($mosque);
            $financeData = [
                'balance' => array_sum(array_column($funds, 'balance')),
                'month_in' => (int) $flows->i,
                'month_out' => (int) $flows->o,
                'funds' => $funds,
            ];
        }

        $usage = $subs->usage($mosque, $finance);
        $warnings = [];
        $level = $usage['storage']['level'];
        if ($level !== 'ok') {
            $warnings[] = 'storage_'.$level;
        }
        if ($usage['transactions_this_month']['used'] >= $usage['transactions_this_month']['limit']) {
            $warnings[] = 'transactions_soft_limit';
        }
        if ($usage['active_content']['used'] >= $usage['active_content']['limit'] * 0.9) {
            $warnings[] = 'content_near_limit';
        }
        $subscription = $subs->present($mosque);
        if (in_array($subscription['state'], ['grace', 'expired'], true)) {
            $warnings[] = 'subscription_'.$subscription['state'];
        }

        $displays = $mosque->displayDevices()->where('status', 'active')->get(['id', 'name', 'last_seen_at']);

        return response()->json([
            'mosque' => [
                'id' => $mosque->id,
                'slug' => $mosque->slug,
                'name' => $mosque->name,
                'city' => $mosque->city,
                'settings' => [
                    'public_show_finance' => (bool) $mosque->setting('public_show_finance'),
                ],
            ],
            'role' => $membership->role,
            'permissions' => Permissions::listFor($membership, $mosque),
            'finance' => $financeData,
            'upcoming_events' => $mosque->events()->where('status', 'active')->where('starts_at', '>=', now())
                ->orderBy('starts_at')->limit(5)->get(['id', 'title', 'category', 'starts_at', 'visibility']),
            'staff_today' => $mosque->staffAssignments()->with('user:id,name')->where('date', $now->toDateString())->get()
                ->map(fn ($a) => ['duty_type' => $a->duty_type, 'prayer' => $a->prayer, 'name' => $a->user?->name ?? $a->external_name]),
            'active_announcements' => $mosque->announcements()->live()->count(),
            'displays' => [
                'active' => $displays->count(),
                'online' => $displays->filter(fn ($d) => $d->last_seen_at?->gt(now()->subMinutes(5)))->count(),
                'devices' => $displays,
            ],
            'subscription' => $subscription,
            'usage' => $usage,
            'warnings' => $warnings,
        ]);
    }
}
