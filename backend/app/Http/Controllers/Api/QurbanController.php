<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\DomainRuleException;
use App\Http\Controllers\Controller;
use App\Models\Mosque;
use App\Models\QurbanAnimal;
use App\Models\QurbanParticipant;
use App\Support\Audit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class QurbanController extends Controller
{
    public function index(Request $request, Mosque $mosque): JsonResponse
    {
        $f = $request->validate(['hijri_year' => ['nullable', 'integer', 'between:1400,1600']]);
        $animals = $mosque->qurbanAnimals()
            ->when($f['hijri_year'] ?? null, fn ($q, $y) => $q->where('hijri_year', $y))
            ->with('participants')
            ->orderBy('code')
            ->get();

        $presented = $animals->map(fn (QurbanAnimal $a) => $this->presentAnimal($a));

        return response()->json([
            'summary' => [
                'total_animals' => $animals->count(),
                'total_participants' => $animals->sum(fn ($a) => $a->participants->count()),
                'total_meat_packs' => (int) $animals->sum('meat_packs_count'),
                'slaughtered_count' => $animals->where('slaughter_status', '!=', 'registered')->count(),
                'by_species' => $animals->groupBy('species')->map->count()->all(),
            ],
            'data' => $presented->values(),
        ]);
    }

    public function storeAnimal(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate([
            'hijri_year' => ['required', 'integer', 'between:1400,1600'],
            'code' => [
                'required', 'string', 'max:24',
                Rule::unique('qurban_animals')
                    ->where('mosque_id', $mosque->id)
                    ->where('hijri_year', $request->input('hijri_year')),
            ],
            'species' => ['required', Rule::in(QurbanAnimal::SPECIES)],
            'capacity' => ['nullable', 'integer', 'min:1', 'max:7'],
            'weight_kg' => ['nullable', 'numeric', 'min:1', 'max:3000'],
            'price_idr' => ['nullable', 'integer', 'min:0'],
            'notes' => ['nullable', 'string', 'max:255'],
        ]);

        $animal = $mosque->qurbanAnimals()->create([
            'hijri_year' => $data['hijri_year'],
            'code' => strtoupper(trim($data['code'])),
            'species' => $data['species'],
            'capacity' => $data['capacity'] ?? QurbanAnimal::defaultCapacity($data['species']),
            'weight_kg' => $data['weight_kg'] ?? null,
            'price_idr' => (int) ($data['price_idr'] ?? 0),
            'slaughter_status' => 'registered',
            'notes' => $data['notes'] ?? null,
            'created_by' => $request->user()->id,
        ]);
        $animal->load('participants');
        Audit::log($mosque, 'qurban.animal_created', $animal, ['code' => $animal->code, 'species' => $animal->species]);

        return response()->json(['data' => $this->presentAnimal($animal)], 201);
    }

    public function updateAnimal(Request $request, Mosque $mosque, QurbanAnimal $qurbanAnimal): JsonResponse
    {
        $data = $request->validate([
            'slaughter_status' => ['sometimes', Rule::in(QurbanAnimal::SLAUGHTER_STATUSES)],
            'meat_packs_count' => ['sometimes', 'integer', 'min:0', 'max:100000'],
            'weight_kg' => ['sometimes', 'nullable', 'numeric', 'min:1', 'max:3000'],
            'notes' => ['sometimes', 'nullable', 'string', 'max:255'],
        ]);

        if (isset($data['slaughter_status']) && $data['slaughter_status'] !== 'registered' && $qurbanAnimal->slaughtered_at === null) {
            $data['slaughtered_at'] = now();
        }
        $qurbanAnimal->update($data);
        $qurbanAnimal->load('participants');
        Audit::log($mosque, 'qurban.animal_updated', $qurbanAnimal, ['code' => $qurbanAnimal->code, 'status' => $qurbanAnimal->slaughter_status]);

        return response()->json(['data' => $this->presentAnimal($qurbanAnimal)]);
    }

    public function storeParticipant(Request $request, Mosque $mosque, QurbanAnimal $qurbanAnimal): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'phone' => ['nullable', 'string', 'max:32'],
            'shares' => ['nullable', 'integer', 'min:1', 'max:7'],
            'amount_idr' => ['nullable', 'integer', 'min:0'],
            'payment_status' => ['nullable', Rule::in(QurbanParticipant::PAYMENT_STATUSES)],
            'notes' => ['nullable', 'string', 'max:255'],
        ]);

        $shares = (int) ($data['shares'] ?? 1);

        $participant = DB::transaction(function () use ($mosque, $qurbanAnimal, $data, $shares) {
            $locked = QurbanAnimal::whereKey($qurbanAnimal->id)->lockForUpdate()->firstOrFail();
            $used = (int) $locked->participants()->sum('shares');
            if ($used + $shares > $locked->capacity) {
                $rem = max(0, $locked->capacity - $used);
                throw new DomainRuleException(
                    'qurban_capacity_exceeded',
                    "Kuota patungan hewan {$locked->code} tidak mencukupi (tersisa {$rem} dari {$locked->capacity} bagian)."
                );
            }

            return $locked->participants()->create([
                'mosque_id' => $mosque->id,
                'name' => $data['name'],
                'phone' => $data['phone'] ?? null,
                'shares' => $shares,
                'amount_idr' => (int) ($data['amount_idr'] ?? 0),
                'payment_status' => $data['payment_status'] ?? 'unpaid',
                'notes' => $data['notes'] ?? null,
            ]);
        });

        Audit::log($mosque, 'qurban.participant_created', $participant, [
            'animal_code' => $qurbanAnimal->code,
            'name' => $participant->name,
            'shares' => $participant->shares,
        ]);

        return response()->json(['data' => $participant], 201);
    }

    public function updateParticipant(Request $request, Mosque $mosque, QurbanParticipant $qurbanParticipant): JsonResponse
    {
        $data = $request->validate([
            'payment_status' => ['sometimes', Rule::in(QurbanParticipant::PAYMENT_STATUSES)],
            'meat_taken' => ['sometimes', 'boolean'],
            'amount_idr' => ['sometimes', 'integer', 'min:0'],
            'notes' => ['sometimes', 'nullable', 'string', 'max:255'],
        ]);

        $qurbanParticipant->update($data);
        Audit::log($mosque, 'qurban.participant_updated', $qurbanParticipant, $data);

        return response()->json(['data' => $qurbanParticipant->fresh()]);
    }

    private function presentAnimal(QurbanAnimal $a): array
    {
        $used = (int) $a->participants->sum('shares');

        return [
            'id' => $a->id,
            'hijri_year' => $a->hijri_year,
            'code' => $a->code,
            'species' => $a->species,
            'capacity' => $a->capacity,
            'used_shares' => $used,
            'remaining_shares' => max(0, $a->capacity - $used),
            'weight_kg' => $a->weight_kg,
            'price_idr' => $a->price_idr,
            'slaughter_status' => $a->slaughter_status,
            'slaughtered_at' => $a->slaughtered_at?->toIso8601String(),
            'meat_packs_count' => $a->meat_packs_count,
            'notes' => $a->notes,
            'participants' => $a->participants->map(fn (QurbanParticipant $p) => [
                'id' => $p->id,
                'name' => $p->name,
                'phone' => $p->phone,
                'shares' => $p->shares,
                'amount_idr' => $p->amount_idr,
                'payment_status' => $p->payment_status,
                'meat_taken' => $p->meat_taken,
                'notes' => $p->notes,
            ])->values()->all(),
        ];
    }
}
