<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mosque;
use App\Services\MosqueRegistrar;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class MosqueController extends Controller
{
    public const METHODS = ['kemenag', 'muslimWorldLeague', 'ummAlQura', 'isna', 'egypt', 'jakim'];

    public function index(Request $request): JsonResponse
    {
        $memberships = $request->user()->memberships()->where('status', 'active')->with('mosque')->get();

        return response()->json([
            'data' => $memberships->map(fn ($m) => $this->present($m->mosque) + ['role' => $m->role]),
        ]);
    }

    public function store(Request $request, MosqueRegistrar $registrar): JsonResponse
    {
        abort_if($request->user()->email_verified_at === null, 403, 'Verifikasi email terlebih dahulu.');

        $data = $request->validate($this->rules());
        [$mosque, $duplicate] = $registrar->register($request->user(), $data);

        return response()->json([
            'data' => $this->present($mosque->fresh()) + ['role' => 'admin', 'duplicate_suspected' => $duplicate],
        ], 201);
    }

    public function show(Request $request, Mosque $mosque): JsonResponse
    {
        return response()->json(['data' => $this->present($mosque) + [
            'role' => $request->attributes->get('membership')->role,
        ]]);
    }

    public function update(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate(array_map(
            fn ($r) => array_values(array_diff($r, ['required'])) ?: ['sometimes'],
            $this->rules()
        ) + [
            'settings' => ['sometimes', 'array'],
            'settings.pengurus_can_view_finance' => ['sometimes', 'boolean'],
            'settings.display_show_finance' => ['sometimes', 'boolean'],
            'settings.iqamah_minutes' => ['sometimes', 'array'],
            'settings.iqamah_minutes.*' => ['integer', 'between:0,60'],
            'settings.prayer_adjustments' => ['sometimes', 'array'],
            'settings.prayer_adjustments.*' => ['integer', 'between:-30,30'],
            'settings.hijri_offset_days' => ['sometimes', 'integer', 'between:-2,2'],
        ]);

        if (isset($data['settings'])) {
            $allowed = array_keys(Mosque::DEFAULT_SETTINGS);
            $data['settings'] = array_replace_recursive(
                $mosque->settings ?? [],
                array_intersect_key($data['settings'], array_flip($allowed))
            );
        }
        $mosque->update($data);

        return $this->show($request, $mosque->fresh());
    }

    private function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:150'],
            'address' => ['nullable', 'string', 'max:255'],
            'city' => ['required', 'string', 'max:100'],
            'province' => ['nullable', 'string', 'max:100'],
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'timezone' => ['required', 'timezone:all'],
            'prayer_method' => ['nullable', Rule::in(self::METHODS)],
            'simas_id' => ['nullable', 'string', 'max:64'],
            'phone' => ['nullable', 'string', 'max:32'],
            'facilities' => ['nullable', 'string', 'max:2000'],
        ];
    }

    public function present(Mosque $m): array
    {
        return [
            'id' => $m->id,
            'name' => $m->name,
            'slug' => $m->slug,
            'address' => $m->address,
            'city' => $m->city,
            'province' => $m->province,
            'latitude' => $m->latitude,
            'longitude' => $m->longitude,
            'timezone' => $m->timezone,
            'prayer_method' => $m->prayer_method ?? 'kemenag',
            'simas_id' => $m->simas_id,
            'phone' => $m->phone,
            'facilities' => $m->facilities,
            'settings' => array_replace_recursive(Mosque::DEFAULT_SETTINGS, $m->settings ?? []),
            'needs_review' => $m->needs_review,
        ];
    }
}
