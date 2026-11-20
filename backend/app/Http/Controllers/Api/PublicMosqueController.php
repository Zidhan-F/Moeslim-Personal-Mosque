<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mosque;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/** API publik untuk Moeslim Personal — hanya field allowlist, tanpa autentikasi. */
class PublicMosqueController extends Controller
{
    public function search(Request $request): JsonResponse
    {
        $f = $request->validate(['q' => ['nullable', 'string', 'max:100'], 'city' => ['nullable', 'string', 'max:100']]);
        $like = fn ($v) => '%'.addcslashes($v, '%_\\').'%';
        $rows = Mosque::query()
            ->when($f['q'] ?? null, fn ($q, $v) => $q->where('name', 'ilike', $like($v)))
            ->when($f['city'] ?? null, fn ($q, $v) => $q->where('city', 'ilike', $like($v)))
            ->orderBy('name')->limit(20)->get();

        return response()->json(['data' => $rows->map(fn ($m) => $this->summary($m))]);
    }

    public function show(string $slug): JsonResponse
    {
        $m = Mosque::where('slug', $slug)->firstOrFail();

        return response()->json(['data' => $this->summary($m) + [
            'facilities' => $m->facilities,
            'prayer_method' => $m->prayer_method ?? 'kemenag',
            'settings' => [
                'iqamah_minutes' => $m->setting('iqamah_minutes'),
                'prayer_adjustments' => $m->setting('prayer_adjustments'),
                'hijri_offset_days' => $m->setting('hijri_offset_days'),
            ],
        ]]);
    }

    public function events(string $slug): JsonResponse
    {
        $m = Mosque::where('slug', $slug)->firstOrFail();
        $rows = $m->events()->where('status', 'active')->where('visibility', 'public')
            ->where('starts_at', '>=', now()->subHours(6))->orderBy('starts_at')->limit(50)->get();

        return response()->json(['data' => $rows->map(fn ($e) => [
            'id' => $e->id, 'title' => $e->title, 'description' => $e->description, 'category' => $e->category,
            'location' => $e->location, 'speaker' => $e->speaker,
            'starts_at' => $e->starts_at?->toIso8601String(), 'ends_at' => $e->ends_at?->toIso8601String(),
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
