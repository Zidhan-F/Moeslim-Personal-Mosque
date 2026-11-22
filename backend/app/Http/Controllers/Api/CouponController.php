<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\DomainRuleException;
use App\Http\Controllers\Controller;
use App\Models\DistributionCoupon;
use App\Models\Mosque;
use App\Support\Audit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class CouponController extends Controller
{
    public function index(Request $request, Mosque $mosque): JsonResponse
    {
        $f = $request->validate([
            'program' => ['nullable', Rule::in(DistributionCoupon::PROGRAMS)],
            'hijri_year' => ['nullable', 'integer', 'between:1400,1600'],
            'status' => ['nullable', Rule::in(DistributionCoupon::STATUSES)],
        ]);

        $base = $mosque->distributionCoupons()
            ->when($f['program'] ?? null, fn ($q, $v) => $q->where('program', $v))
            ->when($f['hijri_year'] ?? null, fn ($q, $v) => $q->where('hijri_year', $v));

        $allForSummary = (clone $base)->get(['status']);
        $rows = (clone $base)
            ->when($f['status'] ?? null, fn ($q, $v) => $q->where('status', $v))
            ->with('redeemer:id,name')
            ->orderByDesc('id')
            ->limit(300)
            ->get();

        return response()->json([
            'summary' => [
                'total' => $allForSummary->count(),
                'issued' => $allForSummary->where('status', 'issued')->count(),
                'redeemed' => $allForSummary->where('status', 'redeemed')->count(),
                'void' => $allForSummary->where('status', 'void')->count(),
            ],
            'data' => $rows->map(fn (DistributionCoupon $c) => $this->present($c))->values(),
        ]);
    }

    public function store(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate([
            'program' => ['required', Rule::in(DistributionCoupon::PROGRAMS)],
            'hijri_year' => ['required', 'integer', 'between:1400,1600'],
            'recipient_name' => ['required_without:batch_count', 'nullable', 'string', 'max:120'],
            'recipient_address' => ['nullable', 'string', 'max:200'],
            'batch_count' => ['nullable', 'integer', 'min:1', 'max:200'],
            'recipient_prefix' => ['nullable', 'string', 'max:80'],
        ]);

        $count = (int) ($data['batch_count'] ?? 1);
        $prefix = trim((string) ($data['recipient_prefix'] ?? 'Penerima'));

        $created = DB::transaction(function () use ($request, $mosque, $data, $count, $prefix) {
            $list = [];
            for ($i = 1; $i <= $count; $i++) {
                $name = isset($data['batch_count'])
                    ? "{$prefix} #{$i}"
                    : $data['recipient_name'];
                $list[] = $mosque->distributionCoupons()->create([
                    'program' => $data['program'],
                    'hijri_year' => $data['hijri_year'],
                    'code' => $this->generateCode($data['program']),
                    'recipient_name' => $name,
                    'recipient_address' => $data['recipient_address'] ?? null,
                    'status' => 'issued',
                    'created_by' => $request->user()->id,
                ]);
            }

            return $list;
        });

        Audit::log($mosque, 'coupon.issued', null, [
            'program' => $data['program'],
            'count' => count($created),
        ]);

        return response()->json([
            'data' => collect($created)->map(fn (DistributionCoupon $c) => $this->present($c))->values(),
        ], 201);
    }

    public function redeem(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate(['code' => ['required', 'string', 'max:36']]);
        $code = strtoupper(trim($data['code']));

        $coupon = DB::transaction(function () use ($request, $mosque, $code) {
            $c = $mosque->distributionCoupons()->where('code', $code)->lockForUpdate()->first();
            if (! $c) {
                throw new DomainRuleException('coupon_not_found', 'Kode kupon tidak ditemukan di masjid ini.', 404);
            }
            if ($c->status === 'void') {
                throw new DomainRuleException('coupon_void', 'Kupon ini sudah dibatalkan.', 422);
            }
            if ($c->status === 'redeemed') {
                $when = $c->redeemed_at?->timezone($mosque->timezone)->format('d/m/Y H:i');
                throw new DomainRuleException(
                    'coupon_already_redeemed',
                    "Kupon {$c->code} ({$c->recipient_name}) sudah ditukarkan sebelumnya pada {$when}.",
                    422
                );
            }

            $c->update([
                'status' => 'redeemed',
                'redeemed_at' => now(),
                'redeemed_by' => $request->user()->id,
            ]);

            return $c->fresh('redeemer:id,name');
        });

        Audit::log($mosque, 'coupon.redeemed', $coupon, [
            'code' => $coupon->code,
            'recipient' => $coupon->recipient_name,
        ]);

        return response()->json(['data' => $this->present($coupon)]);
    }

    public function void(Mosque $mosque, DistributionCoupon $distributionCoupon): JsonResponse
    {
        if ($distributionCoupon->status === 'redeemed') {
            throw new DomainRuleException('coupon_already_redeemed', 'Kupon yang sudah ditukarkan tidak dapat dibatalkan.');
        }
        $distributionCoupon->update(['status' => 'void']);
        Audit::log($mosque, 'coupon.voided', $distributionCoupon, ['code' => $distributionCoupon->code]);

        return response()->json(['data' => $this->present($distributionCoupon->fresh())]);
    }

    private function generateCode(string $program): string
    {
        $prefix = match ($program) {
            'qurban' => 'QBN',
            'zakat' => 'ZKT',
            default => 'KPN',
        };
        do {
            $code = $prefix.'-'.strtoupper(Str::random(6));
        } while (DistributionCoupon::where('code', $code)->exists());

        return $code;
    }

    private function present(DistributionCoupon $c): array
    {
        return [
            'id' => $c->id,
            'program' => $c->program,
            'hijri_year' => $c->hijri_year,
            'code' => $c->code,
            'recipient_name' => $c->recipient_name,
            'recipient_address' => $c->recipient_address,
            'status' => $c->status,
            'redeemed_at' => $c->redeemed_at?->toIso8601String(),
            'redeemed_by_name' => $c->redeemer?->name,
        ];
    }
}
