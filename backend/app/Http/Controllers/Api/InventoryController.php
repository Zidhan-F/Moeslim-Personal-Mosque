<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\DomainRuleException;
use App\Http\Controllers\Controller;
use App\Models\InventoryItem;
use App\Models\Mosque;
use App\Support\Audit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class InventoryController extends Controller
{
    public function index(Request $request, Mosque $mosque): JsonResponse
    {
        $q = $request->validate(['q' => ['nullable', 'string', 'max:100'], 'condition' => ['nullable', Rule::in(InventoryItem::CONDITIONS)]]);

        return response()->json($mosque->inventoryItems()
            ->when($q['q'] ?? null, fn ($w, $v) => $w->where('name', 'ilike', '%'.addcslashes($v, '%_\\').'%'))
            ->when($q['condition'] ?? null, fn ($w, $v) => $w->where('condition', $v))
            ->orderBy('name')->paginate(50));
    }

    public function show(Mosque $mosque, InventoryItem $inventoryItem): JsonResponse
    {
        return response()->json(['data' => $inventoryItem->load('maintenance')]);
    }

    public function store(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate($this->rules());
        $inventoryItem = DB::transaction(function () use ($mosque, $data) {
            $locked = Mosque::whereKey($mosque->id)->lockForUpdate()->first();
            if ($locked->inventoryItems()->count() >= Mosque::MAX_INVENTORY_ITEMS) {
                throw new DomainRuleException('inventory_limit_reached', 'Batas 5.000 item inventaris tercapai.');
            }

            return $mosque->inventoryItems()->create($data);
        });
        Audit::log($mosque, 'inventory.created', $inventoryItem, ['name' => $inventoryItem->name]);

        return response()->json(['data' => $inventoryItem], 201);
    }

    public function update(Request $request, Mosque $mosque, InventoryItem $inventoryItem): JsonResponse
    {
        $data = $request->validate(array_map(fn ($r) => array_merge(['sometimes'], array_diff($r, ['required'])), $this->rules()));
        $inventoryItem->update($data);
        Audit::log($mosque, 'inventory.updated', $inventoryItem, array_keys($data));

        return response()->json(['data' => $inventoryItem]);
    }

    public function destroy(Mosque $mosque, InventoryItem $inventoryItem): Response
    {
        $inventoryItem->delete();
        Audit::log($mosque, 'inventory.deleted', null, ['id' => $inventoryItem->id, 'name' => $inventoryItem->name]);

        return response()->noContent();
    }

    public function storeMaintenance(Request $request, Mosque $mosque, InventoryItem $inventoryItem): JsonResponse
    {
        $data = $request->validate([
            'date' => ['required', 'date'],
            'notes' => ['required', 'string', 'max:255'],
            'cost' => ['nullable', 'integer', 'min:0'],
        ]);
        $log = $inventoryItem->maintenance()->create($data + ['created_by' => $request->user()->id]);
        Audit::log($mosque, 'inventory.maintained', $inventoryItem, ['notes' => $data['notes']]);

        return response()->json(['data' => $log], 201);
    }

    private function rules(): array
    {
        return [
            'code' => ['nullable', 'string', 'max:50'],
            'name' => ['required', 'string', 'max:150'],
            'quantity' => ['required', 'integer', 'min:0', 'max:1000000'],
            'condition' => ['required', Rule::in(InventoryItem::CONDITIONS)],
            'location' => ['nullable', 'string', 'max:150'],
            'responsible' => ['nullable', 'string', 'max:150'],
            'notes' => ['nullable', 'string', 'max:2000'],
        ];
    }
}
