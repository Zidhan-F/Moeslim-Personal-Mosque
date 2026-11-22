<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\DomainRuleException;
use App\Http\Controllers\Controller;
use App\Models\Mosque;
use App\Models\ZakatCollection;
use App\Models\ZakatMustahik;
use App\Services\FinanceService;
use App\Support\Audit;
use App\Support\Permissions;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class ZakatController extends Controller
{
    public function index(Request $request, Mosque $mosque): JsonResponse
    {
        $f = $request->validate(['hijri_year' => ['nullable', 'integer', 'between:1400,1600']]);
        $year = $f['hijri_year'] ?? null;

        $collections = $mosque->zakatCollections()
            ->when($year, fn ($q, $y) => $q->where('hijri_year', $y))
            ->orderByDesc('date')->orderByDesc('id')->limit(200)->get();

        $mustahiks = $mosque->zakatMustahiks()
            ->when($year, fn ($q, $y) => $q->where('hijri_year', $y))
            ->orderBy('status')->orderBy('id')->limit(300)->get();

        $distributed = $mustahiks->where('status', 'distributed');

        return response()->json([
            'summary' => [
                'total_collections' => $collections->count(),
                'total_souls' => (int) $collections->sum('souls_count'),
                'total_money_in' => (int) $collections->sum('money_amount'),
                'total_rice_in_kg' => round((float) $collections->sum('rice_kg'), 2),
                'total_mustahik' => $mustahiks->count(),
                'distributed_mustahik' => $distributed->count(),
                'distributed_money' => (int) $distributed->sum('money_amount'),
                'distributed_rice_kg' => round((float) $distributed->sum('rice_kg'), 2),
            ],
            'collections' => $collections->map(fn (ZakatCollection $c) => [
                'id' => $c->id,
                'type' => $c->type,
                'hijri_year' => $c->hijri_year,
                'date' => $c->date->toDateString(),
                'muzakki_name' => $c->muzakki_name,
                'muzakki_phone' => $c->muzakki_phone,
                'souls_count' => $c->souls_count,
                'money_amount' => $c->money_amount,
                'rice_kg' => $c->rice_kg,
                'transaction_id' => $c->transaction_id,
                'notes' => $c->notes,
            ])->values(),
            'mustahiks' => $mustahiks->map(fn (ZakatMustahik $m) => [
                'id' => $m->id,
                'hijri_year' => $m->hijri_year,
                'name' => $m->name,
                'asnaf' => $m->asnaf,
                'address' => $m->address,
                'money_amount' => $m->money_amount,
                'rice_kg' => $m->rice_kg,
                'status' => $m->status,
                'distributed_at' => $m->distributed_at?->toIso8601String(),
                'notes' => $m->notes,
            ])->values(),
        ]);
    }

    public function storeCollection(Request $request, Mosque $mosque, FinanceService $finance): JsonResponse
    {
        $data = $request->validate([
            'type' => ['required', Rule::in(ZakatCollection::TYPES)],
            'hijri_year' => ['required', 'integer', 'between:1400,1600'],
            'date' => ['required', 'date'],
            'muzakki_name' => ['required', 'string', 'max:120'],
            'muzakki_phone' => ['nullable', 'string', 'max:32'],
            'souls_count' => ['nullable', 'integer', 'min:1', 'max:100'],
            'money_amount' => ['nullable', 'integer', 'min:0', 'max:999999999999'],
            'rice_kg' => ['nullable', 'numeric', 'min:0', 'max:10000'],
            'notes' => ['nullable', 'string', 'max:255'],
            'record_to_finance' => ['nullable', 'boolean'],
            'fund_id' => ['nullable', 'integer', Rule::exists('funds', 'id')->where('mosque_id', $mosque->id)->where('is_active', true)],
            'cash_account_id' => ['nullable', 'integer', Rule::exists('cash_accounts', 'id')->where('mosque_id', $mosque->id)->where('is_active', true)],
        ]);

        $money = (int) ($data['money_amount'] ?? 0);
        $rice = (float) ($data['rice_kg'] ?? 0);
        if ($money <= 0 && $rice <= 0) {
            throw new DomainRuleException('zakat_amount_required', 'Nominal uang atau berat beras (kg) wajib diisi.');
        }

        $recordToFinance = (bool) ($data['record_to_finance'] ?? false) && $money > 0;
        if ($recordToFinance) {
            $membership = $request->attributes->get('membership');
            if (! Permissions::allows($membership, 'finance.write', $mosque)) {
                throw new DomainRuleException('forbidden_finance_write', 'Peran Anda tidak memiliki izin mencatat ke buku kas.', 403);
            }
        }

        $collection = DB::transaction(function () use ($request, $mosque, $finance, $data, $money, $rice, $recordToFinance) {
            $txId = null;
            if ($recordToFinance) {
                $fundId = $data['fund_id']
                    ?? $mosque->funds()->where('code', 'zakat')->where('is_active', true)->value('id')
                    ?? $mosque->funds()->where('is_active', true)->value('id');
                $accountId = $data['cash_account_id']
                    ?? $mosque->cashAccounts()->where('is_active', true)->value('id');
                if (! $fundId || ! $accountId) {
                    throw new DomainRuleException('finance_setup_missing', 'Dana atau akun kas aktif belum tersedia.');
                }
                [$tx] = $finance->record($mosque, $request->user(), [
                    'flow' => 'in',
                    'amount' => $money,
                    'fund_id' => $fundId,
                    'cash_account_id' => $accountId,
                    'date' => $data['date'],
                    'description' => mb_substr("Zakat ({$data['type']}) {$data['muzakki_name']}", 0, 255),
                    'donor_name' => $data['muzakki_name'],
                ], 'zakat:'.Str::ulid());
                $txId = $tx->id;
            }

            return $mosque->zakatCollections()->create([
                'type' => $data['type'],
                'hijri_year' => $data['hijri_year'],
                'date' => $data['date'],
                'muzakki_name' => $data['muzakki_name'],
                'muzakki_phone' => $data['muzakki_phone'] ?? null,
                'souls_count' => (int) ($data['souls_count'] ?? 1),
                'money_amount' => $money,
                'rice_kg' => $rice,
                'transaction_id' => $txId,
                'notes' => $data['notes'] ?? null,
                'created_by' => $request->user()->id,
            ]);
        });

        Audit::log($mosque, 'zakat.collection_created', $collection, [
            'type' => $collection->type,
            'muzakki' => $collection->muzakki_name,
            'money_amount' => $collection->money_amount,
            'rice_kg' => $collection->rice_kg,
        ]);

        return response()->json(['data' => $collection], 201);
    }

    public function storeMustahik(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate([
            'hijri_year' => ['required', 'integer', 'between:1400,1600'],
            'name' => ['required', 'string', 'max:120'],
            'asnaf' => ['required', Rule::in(ZakatMustahik::ASNAFS)],
            'address' => ['nullable', 'string', 'max:200'],
            'money_amount' => ['nullable', 'integer', 'min:0'],
            'rice_kg' => ['nullable', 'numeric', 'min:0', 'max:1000'],
            'notes' => ['nullable', 'string', 'max:255'],
        ]);

        $mustahik = $mosque->zakatMustahiks()->create([
            'hijri_year' => $data['hijri_year'],
            'name' => $data['name'],
            'asnaf' => $data['asnaf'],
            'address' => $data['address'] ?? null,
            'money_amount' => (int) ($data['money_amount'] ?? 0),
            'rice_kg' => (float) ($data['rice_kg'] ?? 0),
            'status' => 'planned',
            'notes' => $data['notes'] ?? null,
            'created_by' => $request->user()->id,
        ]);
        Audit::log($mosque, 'zakat.mustahik_created', $mustahik, ['name' => $mustahik->name, 'asnaf' => $mustahik->asnaf]);

        return response()->json(['data' => $mustahik], 201);
    }

    public function distributeMustahik(Request $request, Mosque $mosque, ZakatMustahik $zakatMustahik): JsonResponse
    {
        $data = $request->validate([
            'money_amount' => ['nullable', 'integer', 'min:0'],
            'rice_kg' => ['nullable', 'numeric', 'min:0', 'max:1000'],
        ]);

        $zakatMustahik->update([
            'money_amount' => array_key_exists('money_amount', $data) ? (int) $data['money_amount'] : $zakatMustahik->money_amount,
            'rice_kg' => array_key_exists('rice_kg', $data) ? (float) $data['rice_kg'] : $zakatMustahik->rice_kg,
            'status' => 'distributed',
            'distributed_at' => now(),
        ]);
        Audit::log($mosque, 'zakat.mustahik_distributed', $zakatMustahik, ['name' => $zakatMustahik->name]);

        return response()->json(['data' => $zakatMustahik->fresh()]);
    }
}
