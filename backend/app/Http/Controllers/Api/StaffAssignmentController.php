<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mosque;
use App\Models\StaffAssignment;
use App\Support\Audit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Validation\Rule;

class StaffAssignmentController extends Controller
{
    public function index(Request $request, Mosque $mosque): JsonResponse
    {
        $f = $request->validate(['from' => ['nullable', 'date'], 'to' => ['nullable', 'date']]);
        $from = $f['from'] ?? now()->startOfWeek()->toDateString();
        $to = $f['to'] ?? now()->addDays(30)->toDateString();

        $rows = $mosque->staffAssignments()->with('user:id,name')
            ->whereBetween('date', [$from, $to])->orderBy('date')->orderBy('id')->get();

        return response()->json(['data' => $rows->map(fn ($a) => $this->present($a))]);
    }

    public function store(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate($this->rules($mosque));
        $a = $mosque->staffAssignments()->create($data);
        Audit::log($mosque, 'staff.assigned', $a, ['duty' => $a->duty_type, 'date' => $a->date->toDateString()]);

        return response()->json(['data' => $this->present($a->load('user:id,name'))], 201);
    }

    public function update(Request $request, Mosque $mosque, StaffAssignment $staffAssignment): JsonResponse
    {
        $data = $request->validate(array_map(fn ($r) => array_merge(['sometimes'], array_diff($r, ['required'])), $this->rules($mosque)));
        $staffAssignment->update($data);
        Audit::log($mosque, 'staff.updated', $staffAssignment);

        return response()->json(['data' => $this->present($staffAssignment->load('user:id,name'))]);
    }

    public function destroy(Mosque $mosque, StaffAssignment $staffAssignment): Response
    {
        $staffAssignment->delete();
        Audit::log($mosque, 'staff.deleted', null, ['id' => $staffAssignment->id]);

        return response()->noContent();
    }

    private function rules(Mosque $mosque): array
    {
        return [
            'duty_type' => ['required', Rule::in(StaffAssignment::DUTIES)],
            'prayer' => ['nullable', Rule::in(StaffAssignment::PRAYERS)],
            'date' => ['required', 'date'],
            // Petugas: anggota aktif masjid ini, atau nama eksternal (imam tamu, khatib undangan).
            'user_id' => ['required_without:external_name', 'nullable', 'integer',
                Rule::exists('mosque_members', 'user_id')->where('mosque_id', $mosque->id)->where('status', 'active')],
            'external_name' => ['required_without:user_id', 'nullable', 'string', 'max:150'],
            'notes' => ['nullable', 'string', 'max:255'],
        ];
    }

    private function present(StaffAssignment $a): array
    {
        return [
            'id' => $a->id,
            'duty_type' => $a->duty_type,
            'prayer' => $a->prayer,
            'date' => $a->date->toDateString(),
            'user_id' => $a->user_id,
            'name' => $a->user?->name ?? $a->external_name,
            'notes' => $a->notes,
        ];
    }
}
