<?php

namespace App\Services;

use App\Models\Mosque;
use Illuminate\Support\Carbon;

/** Menyusun konten TV Display, hanya field yang diizinkan (allowlist). */
class DisplayContent
{
    public function __construct(private readonly FinanceService $finance) {}

    public function build(Mosque $mosque): array
    {
        $tz = $mosque->timezone;
        $nowLocal = now($tz);
        $today = $nowLocal->toDateString();

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

        // Papan Petugas Salat Jumat otomatis untuk Jumat terdekat (hari ini jika Jumat, atau Jumat mendatang).
        $fridayDate = $this->upcomingFridayDate($nowLocal);
        $fridayItems = $mosque->staffAssignments()->with('user:id,name')
            ->where('date', $fridayDate)
            ->whereIn('duty_type', ['khatib', 'imam', 'bilal', 'muadzin'])
            ->get()
            ->map(fn ($a) => ['duty_type' => $a->duty_type, 'prayer' => $a->prayer, 'name' => $a->user?->name ?? $a->external_name])
            ->values();
        $fridayStaff = $fridayItems->isEmpty() ? null : [
            'date' => $fridayDate,
            'items' => $fridayItems->all(),
        ];

        $finance = null;
        if ($mosque->setting('display_show_finance')) {
            $month = $nowLocal->copy();
            $flows = $mosque->transactions()
                ->whereBetween('date', [$month->copy()->startOfMonth()->toDateString(), $month->copy()->endOfMonth()->toDateString()])
                ->selectRaw("coalesce(sum(case when flow='in' then amount end),0) as i, coalesce(sum(case when flow='out' then amount end),0) as o")
                ->first();

            // Ringkasan Kas Jumat (7 hari terakhir hingga hari ini).
            $weekFrom = $nowLocal->copy()->subDays(6)->toDateString();
            $weekFlows = $mosque->transactions()
                ->whereBetween('date', [$weekFrom, $today])
                ->selectRaw("coalesce(sum(case when flow='in' then amount end),0) as i, coalesce(sum(case when flow='out' then amount end),0) as o")
                ->first();

            $balance = array_sum(array_column($this->finance->fundBalances($mosque), 'balance'));
            $weekIn = (int) $weekFlows->i;
            $weekOut = (int) $weekFlows->o;

            $finance = [
                'balance' => $balance,
                'month_in' => (int) $flows->i,
                'month_out' => (int) $flows->o,
                'week_from' => $weekFrom,
                'week_to' => $today,
                'week_in' => $weekIn,
                'week_out' => $weekOut,
                'opening_balance' => $balance - $weekIn + $weekOut,
            ];
        }

        $qris = null;
        if ($mosque->setting('display_show_qris') && $mosque->qris_image_path) {
            $qris = [
                'enabled' => true,
                'label' => (string) $mosque->setting('qris_label'),
                'url' => '/api/display/qris',
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
                    'praying_minutes' => $mosque->setting('praying_minutes'),
                    'silent_prayer_screen' => (bool) $mosque->setting('silent_prayer_screen'),
                    'silent_prayer_message' => (string) $mosque->setting('silent_prayer_message'),
                    'iqamah_beep' => (bool) $mosque->setting('iqamah_beep'),
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
            'friday_staff' => $fridayStaff,
            'finance' => $finance,
            'qris' => $qris,
            'override' => $mosque->activeDisplayOverride(),
        ];
    }

    private function upcomingFridayDate(Carbon $nowLocal): string
    {
        if ($nowLocal->isFriday()) {
            return $nowLocal->toDateString();
        }

        return $nowLocal->copy()->next(Carbon::FRIDAY)->toDateString();
    }
}
