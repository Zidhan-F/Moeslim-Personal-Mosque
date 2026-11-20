<?php

namespace App\Services;

use App\Models\Mosque;
use App\Models\Subscription;
use Illuminate\Support\Carbon;

class SubscriptionService
{
    /** Status efektif dihitung dari tanggal sehingga tidak bergantung pada cron. */
    public function effectiveState(?Subscription $s): string
    {
        if (! $s) {
            return 'expired';
        }
        $end = $s->state === 'trialing' ? $s->trial_ends_at : $s->current_period_ends_at;
        if ($end === null) {
            return 'expired';
        }
        if ($end->isFuture()) {
            return $s->state === 'trialing' ? 'trialing' : 'active';
        }
        if ($end->copy()->addDays(Subscription::GRACE_DAYS)->isFuture()) {
            return 'grace';
        }

        return 'expired';
    }

    public function isWritable(Mosque $mosque): bool
    {
        return $this->effectiveState($mosque->subscription) !== 'expired';
    }

    public function activate(Mosque $mosque, int $months, string $provider = 'manual', ?string $externalRef = null): Subscription
    {
        $sub = $mosque->subscription ?? $mosque->subscription()->make();
        $current = $sub->state === 'active' && $sub->current_period_ends_at?->isFuture()
            ? $sub->current_period_ends_at
            : Carbon::now();
        $sub->fill([
            'provider' => $provider,
            'state' => 'active',
            'current_period_ends_at' => $current->copy()->addMonthsNoOverflow($months),
            'external_ref' => $externalRef ?? $sub->external_ref,
        ])->save();

        return $sub;
    }

    public function present(Mosque $mosque): array
    {
        $s = $mosque->subscription;
        $state = $this->effectiveState($s);
        $end = $s?->state === 'trialing' ? $s?->trial_ends_at : $s?->current_period_ends_at;

        return [
            'state' => $state,
            'provider' => $s?->provider,
            'plan_key' => $s?->plan_key,
            'price_idr' => $s?->price_idr ?? 59000,
            'trial_ends_at' => $s?->trial_ends_at,
            'current_period_ends_at' => $s?->current_period_ends_at,
            'grace_ends_at' => $end?->copy()->addDays(Subscription::GRACE_DAYS),
            'writable' => $state !== 'expired',
        ];
    }

    public function usage(Mosque $mosque, FinanceService $finance): array
    {
        $storageUsed = $mosque->storage_used_bytes;
        $ratio = $storageUsed / Mosque::STORAGE_QUOTA_BYTES;

        return [
            'members' => ['used' => $mosque->activeMembers()->count(), 'limit' => Mosque::MAX_ACTIVE_MEMBERS],
            'displays' => ['used' => $mosque->displayDevices()->where('status', 'active')->count(), 'limit' => Mosque::MAX_DISPLAYS],
            'storage' => [
                'used' => $storageUsed,
                'limit' => Mosque::STORAGE_QUOTA_BYTES,
                'level' => $ratio >= 1 ? 'full' : ($ratio >= 0.95 ? 'critical' : ($ratio >= 0.80 ? 'warning' : 'ok')),
            ],
            'active_content' => ['used' => $mosque->activeContentCount(), 'limit' => Mosque::MAX_ACTIVE_CONTENT],
            'inventory' => ['used' => $mosque->inventoryItems()->count(), 'limit' => Mosque::MAX_INVENTORY_ITEMS],
            'transactions_this_month' => ['used' => $finance->monthlyCount($mosque), 'limit' => Mosque::MONTHLY_TRANSACTION_SOFT_LIMIT],
        ];
    }
}
