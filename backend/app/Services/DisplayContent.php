<?php

namespace App\Services;

use App\Models\Mosque;

/** Menyusun konten TV Display — hanya field yang diizinkan (allowlist). */
class DisplayContent
{
    public function __construct(private readonly FinanceService $finance) {}

    public function build(Mosque $mosque): array
    {
        $tz = $mosque->timezone;
        $today = now($tz)->toDateString();

        $events = $mosque->events()
            ->where('status', 'active')->where('visibility', 'public')->where('show_on_display', true)
            ->where('starts_at', '>=', now()->subHours(3))
            ->where('starts_at', '<=', now()->addDays(14))
            ->orderBy('starts_at')->limit(10)
            ->get(['id', 'title', 'category', 'location', 'speaker', 'starts_at', 'ends_at', 'updated_at']);

        $announcements = $mosque->announcements()->live()
            ->where('visibility', 'public')->where('show_on_display', true)
            ->orderByDesc('priority')->orderByDesc('id')->limit(10)
            ->get(['id', 'title', 'body', 'priority', 'updated_at']);

        $staff = $mosque->staffAssignments()->with('user:id,name')->where('date', $today)
            ->whereIn('duty_type', ['imam', 'muadzin', 'khatib', 'bilal'])->get()
            ->map(fn ($a) => ['duty_type' => $a->duty_type, 'prayer' => $a->prayer, 'name' => $a->user?->name ?? $a->external_name]);

        $finance = null;
        if ($mosque->setting('display_show_finance')) {
            $month = now($tz);
            $flows = $mosque->transactions()
                ->whereBetween('date', [$month->copy()->startOfMonth()->toDateString(), $month->copy()->endOfMonth()->toDateString()])
                ->selectRaw("coalesce(sum(case when flow='in' then amount end),0) as i, coalesce(sum(case when flow='out' then amount end),0) as o")
                ->first();
            $finance = [
                'balance' => array_sum(array_column($this->finance->fundBalances($mosque), 'balance')),
                'month_in' => (int) $flows->i,
                'month_out' => (int) $flows->o,
            ];
        }

        return [
            'mosque' => [
                'id' => $mosque->id,
                'name' => $mosque->name,
                'address' => $mosque->address,
                'city' => $mosque->city,
                'latitude' => $mosque->latitude,
                'longitude' => $mosque->longitude,
                'timezone' => $mosque->timezone,
                'prayer_method' => $mosque->prayer_method ?? 'kemenag',
                'settings' => [
                    'iqamah_minutes' => $mosque->setting('iqamah_minutes'),
                    'prayer_adjustments' => $mosque->setting('prayer_adjustments'),
                    'hijri_offset_days' => $mosque->setting('hijri_offset_days'),
                ],
            ],
            'events' => $events->map(fn ($e) => [
                'id' => $e->id, 'title' => $e->title, 'category' => $e->category, 'location' => $e->location,
                'speaker' => $e->speaker, 'starts_at' => $e->starts_at?->toIso8601String(), 'ends_at' => $e->ends_at?->toIso8601String(),
            ])->all(),
            'announcements' => $announcements->map(fn ($a) => [
                'id' => $a->id, 'title' => $a->title, 'body' => $a->body, 'priority' => $a->priority,
            ])->all(),
            'staff_today' => $staff->all(),
            'finance' => $finance,
        ];
    }
}
