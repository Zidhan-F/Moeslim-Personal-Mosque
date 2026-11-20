<?php

namespace App\Services;

use App\Exceptions\DomainRuleException;
use App\Models\FinanceTransaction;
use App\Models\Fund;
use App\Models\Mosque;
use App\Models\User;
use App\Support\Audit;
use Illuminate\Support\Facades\DB;

class FinanceService
{
    /** Awalan kunci idempoten internal (entri pembalik); ditolak bila dikirim klien. */
    public const INTERNAL_KEY_PREFIX = 'reversal:';

    /**
     * Catat transaksi secara idempoten.
     *
     * @return array{0: FinanceTransaction, 1: bool} transaksi dan apakah baru dibuat
     */
    public function record(Mosque $mosque, User $by, array $data, string $idempotencyKey): array
    {
        $hash = $this->hashPayload($data);

        return DB::transaction(function () use ($mosque, $by, $data, $idempotencyKey, $hash) {
            // Serialisasi penulisan keuangan per masjid (nomor referensi & cek saldo dana).
            Mosque::whereKey($mosque->id)->lockForUpdate()->first();

            $existing = FinanceTransaction::where('mosque_id', $mosque->id)
                ->where('idempotency_key', $idempotencyKey)->first();
            if ($existing) {
                if (! hash_equals($existing->request_hash, $hash)) {
                    throw new DomainRuleException('idempotency_conflict', 'Idempotency-Key sudah dipakai untuk data berbeda.', 409);
                }

                return [$existing, false];
            }

            if ($data['flow'] === 'out') {
                $this->guardRestrictedFund($mosque, (int) $data['fund_id'], (int) $data['amount']);
            }

            $tx = FinanceTransaction::create([
                'mosque_id' => $mosque->id,
                'reference_no' => $this->nextReference($mosque, $data['date']),
                'flow' => $data['flow'],
                'amount' => (int) $data['amount'],
                'fund_id' => $data['fund_id'],
                'cash_account_id' => $data['cash_account_id'],
                'to_cash_account_id' => $data['flow'] === 'transfer' ? $data['to_cash_account_id'] : null,
                'category_id' => $data['flow'] === 'transfer' ? null : ($data['category_id'] ?? null),
                'date' => $data['date'],
                'description' => $data['description'],
                'created_by' => $by->id,
                'idempotency_key' => $idempotencyKey,
                'request_hash' => $hash,
            ]);
            Audit::log($mosque, 'finance.transaction_created', $tx, [
                'reference_no' => $tx->reference_no, 'flow' => $tx->flow, 'amount' => $tx->amount,
            ]);

            return [$tx, true];
        });
    }

    public function reverse(Mosque $mosque, User $by, FinanceTransaction $original, string $reason): FinanceTransaction
    {
        return DB::transaction(function () use ($mosque, $by, $original, $reason) {
            Mosque::whereKey($mosque->id)->lockForUpdate()->first();
            $original = FinanceTransaction::whereKey($original->id)->lockForUpdate()->first();

            if ($original->reversal_of_id !== null) {
                throw new DomainRuleException('cannot_reverse_reversal', 'Entri pembalik tidak dapat dibalik lagi.');
            }
            if (FinanceTransaction::where('reversal_of_id', $original->id)->exists()) {
                throw new DomainRuleException('already_reversed', 'Transaksi ini sudah dibatalkan.');
            }

            $data = match ($original->flow) {
                'in' => ['flow' => 'out', 'cash_account_id' => $original->cash_account_id, 'to_cash_account_id' => null],
                'out' => ['flow' => 'in', 'cash_account_id' => $original->cash_account_id, 'to_cash_account_id' => null],
                'transfer' => ['flow' => 'transfer', 'cash_account_id' => $original->to_cash_account_id, 'to_cash_account_id' => $original->cash_account_id],
            };
            if ($data['flow'] === 'out') {
                $this->guardRestrictedFund($mosque, $original->fund_id, $original->amount);
            }

            $tx = FinanceTransaction::create($data + [
                'mosque_id' => $mosque->id,
                'reference_no' => $this->nextReference($mosque, $mosque->today()),
                'amount' => $original->amount,
                'fund_id' => $original->fund_id,
                'category_id' => $original->category_id,
                'date' => $mosque->today(),
                'description' => mb_substr("Pembatalan {$original->reference_no}: {$reason}", 0, 255),
                'reversal_of_id' => $original->id,
                'created_by' => $by->id,
                'idempotency_key' => "reversal:{$original->id}",
                'request_hash' => hash('sha256', "reversal:{$original->id}"),
            ]);
            Audit::log($mosque, 'finance.transaction_reversed', $tx, [
                'original' => $original->reference_no, 'reason' => $reason,
            ]);

            return $tx;
        });
    }

    /** Saldo per dana (transfer antar-akun netral terhadap dana). */
    public function fundBalances(Mosque $mosque, ?string $until = null): array
    {
        $rows = FinanceTransaction::where('mosque_id', $mosque->id)
            ->when($until, fn ($q) => $q->where('date', '<=', $until))
            ->selectRaw("fund_id, sum(case when flow='in' then amount when flow='out' then -amount else 0 end) as balance")
            ->groupBy('fund_id')->pluck('balance', 'fund_id');

        return $mosque->funds()->get()->map(fn (Fund $f) => [
            'id' => $f->id,
            'code' => $f->code,
            'name' => $f->name,
            'restricted' => $f->restricted,
            'balance' => (int) ($rows[$f->id] ?? 0),
        ])->all();
    }

    public function accountBalances(Mosque $mosque, ?string $until = null): array
    {
        $base = FinanceTransaction::where('mosque_id', $mosque->id)
            ->when($until, fn ($q) => $q->where('date', '<=', $until));
        $from = (clone $base)
            ->selectRaw("cash_account_id as id, sum(case when flow='in' then amount else -amount end) as v")
            ->groupBy('cash_account_id')->pluck('v', 'id');
        $to = (clone $base)->where('flow', 'transfer')
            ->selectRaw('to_cash_account_id as id, sum(amount) as v')
            ->groupBy('to_cash_account_id')->pluck('v', 'id');

        return $mosque->cashAccounts()->get()->map(fn ($a) => [
            'id' => $a->id,
            'name' => $a->name,
            'type' => $a->type,
            'is_active' => $a->is_active,
            'balance' => (int) ($from[$a->id] ?? 0) + (int) ($to[$a->id] ?? 0),
        ])->all();
    }

    public function monthlyCount(Mosque $mosque): int
    {
        return FinanceTransaction::where('mosque_id', $mosque->id)
            ->where('created_at', '>=', now($mosque->timezone)->startOfMonth()->utc())->count();
    }

    private function guardRestrictedFund(Mosque $mosque, int $fundId, int $amount): void
    {
        $fund = Fund::where('mosque_id', $mosque->id)->findOrFail($fundId);
        if (! $fund->restricted) {
            return;
        }
        $balance = (int) FinanceTransaction::where('mosque_id', $mosque->id)->where('fund_id', $fundId)
            ->selectRaw("coalesce(sum(case when flow='in' then amount when flow='out' then -amount else 0 end),0) as b")
            ->value('b');
        if ($balance - $amount < 0) {
            throw new DomainRuleException('restricted_fund_insufficient', "Saldo {$fund->name} tidak mencukupi (sisa Rp".number_format($balance, 0, ',', '.').').');
        }
    }

    private function nextReference(Mosque $mosque, string $date): string
    {
        $period = date('Ym', strtotime($date));
        $prefix = "TRX-{$period}-";
        $last = FinanceTransaction::where('mosque_id', $mosque->id)
            ->where('reference_no', 'like', $prefix.'%')->max('reference_no');
        $n = $last ? ((int) substr($last, -5)) + 1 : 1;

        return $prefix.str_pad((string) $n, 5, '0', STR_PAD_LEFT);
    }

    private function hashPayload(array $data): string
    {
        ksort($data);

        return hash('sha256', json_encode(array_map(fn ($v) => is_numeric($v) ? (string) $v : $v, $data)));
    }
}
