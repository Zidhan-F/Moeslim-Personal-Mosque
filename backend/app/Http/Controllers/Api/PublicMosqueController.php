<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mosque;
use App\Services\FinanceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

/** API publik untuk Moeslim Personal dan Microsite: hanya field allowlist, tanpa autentikasi. */
class PublicMosqueController extends Controller
{
    public function search(Request $request): JsonResponse
    {
        $f = $request->validate(['q' => ['nullable', 'string', 'max:100'], 'city' => ['nullable', 'string', 'max:100']]);
        $like = fn ($v) => '%'.addcslashes($v, '%_\\').'%';
        $op = DB::connection()->getDriverName() === 'sqlite' ? 'like' : 'ilike';
        $rows = Mosque::query()
            ->when($f['q'] ?? null, fn ($q, $v) => $q->where('name', $op, $like($v)))
            ->when($f['city'] ?? null, fn ($q, $v) => $q->where('city', $op, $like($v)))
            ->orderBy('name')->limit(20)->get();

        return response()->json(['data' => $rows->map(fn ($m) => $this->summary($m))]);
    }

    public function show(string $slug, FinanceService $finance): JsonResponse
    {
        $m = Mosque::where('slug', $slug)->firstOrFail();
        $hasQris = (bool) ($m->setting('display_show_qris') && $m->qris_image_path);

        $publicFinance = null;
        if ($m->setting('public_show_finance')) {
            $friday = $finance->fridayReport($m, $m->today());
            $publicFinance = [
                'from' => $friday['from'],
                'to' => $friday['to'],
                'balance' => $friday['closing_balance'],
                'week_in' => $friday['total_in'],
                'week_out' => $friday['total_out'],
                'funds' => $friday['funds'],
            ];
        }

        return response()->json(['data' => $this->summary($m) + [
            'microsite_url' => url("/m/{$m->slug}"),
            'facilities' => $m->facilities,
            'prayer_method' => $m->prayer_method ?? 'kemenag',
            'settings' => [
                'iqamah_minutes' => $m->setting('iqamah_minutes'),
                'prayer_adjustments' => $m->setting('prayer_adjustments'),
                'hijri_offset_days' => $m->setting('hijri_offset_days'),
                'public_show_finance' => (bool) $m->setting('public_show_finance'),
            ],
            'friday_staff' => self::upcomingFridayStaff($m),
            'qris' => [
                'enabled' => $hasQris,
                'label' => $m->setting('qris_label'),
                'image_url' => $hasQris ? url("/api/public/mosques/{$m->slug}/qris") : null,
            ],
            'finance' => $publicFinance,
        ]]);
    }

    public function qrisImage(string $slug)
    {
        $m = Mosque::where('slug', $slug)->firstOrFail();
        abort_unless($m->setting('display_show_qris') && $m->qris_image_path, 404);
        $disk = Storage::disk(config('filesystems.attachments_disk', 'local'));
        abort_unless($disk->exists($m->qris_image_path), 404);

        return $disk->response($m->qris_image_path);
    }

    public function events(string $slug): JsonResponse
    {
        $m = Mosque::where('slug', $slug)->firstOrFail();
        $rows = $m->events()->where('status', 'active')->where('visibility', 'public')
            ->where('publication_status', '!=', 'draft')
            ->where('starts_at', '>=', now()->subHours(6))->orderBy('starts_at')->limit(50)->get();

        return response()->json(['data' => $rows->map(fn ($e) => [
            'id' => $e->id, 'title' => $e->title, 'description' => $e->description, 'category' => $e->category,
            'location' => $e->location, 'speaker' => $e->speaker,
            'starts_at' => $e->starts_at?->toIso8601String(), 'ends_at' => $e->ends_at?->toIso8601String(),
            'publication_status' => $e->publication_status ?? 'published',
            'hijri_year' => $e->hijri_year,
            'learning_path' => $e->learning_path,
            'registration_enabled' => (bool) $e->registration_enabled,
            'capacity' => $e->capacity,
            'version' => (int) ($e->version ?? 1),
            'updated_at' => $e->updated_at?->toIso8601String(),
        ])]);
    }

    public function announcements(string $slug): JsonResponse
    {
        $m = Mosque::where('slug', $slug)->firstOrFail();
        $rows = $m->announcements()->live()->where('visibility', 'public')
            ->orderByDesc('priority')->orderByDesc('id')->limit(50)->get();

        return response()->json(['data' => $rows->map(fn ($a) => [
            'id' => $a->id, 'title' => $a->title, 'body' => $a->body, 'priority' => $a->priority,
            'publish_at' => $a->publish_at?->toIso8601String(), 'updated_at' => $a->updated_at?->toIso8601String(),
        ])]);
    }

    public static function upcomingFridayStaff(Mosque $m): array
    {
        $now = now($m->timezone)->startOfDay();
        $friday = $now->isFriday() ? $now : $now->copy()->next(Carbon::FRIDAY);
        $rows = $m->staffAssignments()
            ->with('user:id,name')
            ->where('date', $friday->toDateString())
            ->orderBy('id')
            ->get();

        return [
            'date' => $friday->toDateString(),
            'items' => $rows->map(fn ($a) => [
                'duty_type' => $a->duty_type,
                'prayer' => $a->prayer,
                'name' => $a->user?->name ?? $a->external_name,
            ])->all(),
        ];
    }

    private function summary(Mosque $m): array
    {
        return [
            'slug' => $m->slug,
            'name' => $m->name,
            'address' => $m->address,
            'city' => $m->city,
            'province' => $m->province,
            'latitude' => $m->latitude,
            'longitude' => $m->longitude,
            'timezone' => $m->timezone,
        ];
    }
}
