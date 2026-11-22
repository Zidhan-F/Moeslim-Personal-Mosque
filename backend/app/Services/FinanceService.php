<?php

namespace App\Services;

use App\Exceptions\DomainRuleException;
use App\Models\DonationBoxCount;
use App\Models\FinanceTransaction;
use App\Models\Fund;
use App\Models\Mosque;
use App\Models\User;
use App\Support\Audit;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

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

            $donorName = isset($data['donor_name']) && trim((string) $data['donor_name']) !== ''
                ? mb_substr(trim((string) $data['donor_name']), 0, 120)
                : null;

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
                'donor_name' => $data['flow'] === 'in' ? $donorName : null,
                'receipt_token' => $data['flow'] === 'in' ? Str::random(24) : null,
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

    /**
     * Hitung kotak amal multi-saksi -> entri buku kas immutable secara idempoten.
     *
     * @return array{0: DonationBoxCount, 1: bool}
     */
    public function recordDonationBoxCount(Mosque $mosque, User $by, array $data, string $idempotencyKey): array
    {
        $normalized = [];
        $total = 0;
        foreach (DonationBoxCount::ALLOWED_DENOMINATIONS as $denom) {
            $qty = (int) ($data['denominations'][(string) $denom] ?? $data['denominations'][$denom] ?? 0);
            if ($qty < 0) {
                throw new DomainRuleException('invalid_denomination', 'Jumlah lembar pecahan tidak boleh negatif.');
            }
            if ($qty > 0) {
                $normalized[(string) $denom] = $qty;
                $total += $denom * $qty;
            }
        }
        if ($total <= 0) {
            throw new DomainRuleException('empty_donation_box', 'Minimal satu pecahan uang harus diisi.');
        }

        $txData = [
            'flow' => 'in',
            'amount' => $total,
            'fund_id' => (int) $data['fund_id'],
            'cash_account_id' => (int) $data['cash_account_id'],
            'category_id' => $data['category_id'] ?? null,
            'date' => $data['date'],
            'description' => mb_substr("Hitung {$data['box_name']} (Saksi: {$data['witness_1_name']} & {$data['witness_2_name']})", 0, 255),
            'donor_name' => $data['box_name'],
        ];

        return DB::transaction(function () use ($mosque, $by, $data, $idempotencyKey, $txData, $normalized, $total) {
            [$tx, $created] = $this->record($mosque, $by, $txData, $idempotencyKey);
            if (! $created) {
                $existing = DonationBoxCount::where('mosque_id', $mosque->id)
                    ->where('transaction_id', $tx->id)
                    ->first();
                if ($existing) {
                    return [$existing, false];
                }
            }

            $count = DonationBoxCount::create([
                'mosque_id' => $mosque->id,
                'transaction_id' => $tx->id,
                'date' => $data['date'],
                'box_name' => $data['box_name'],
                'denominations' => $normalized,
                'total_amount' => $total,
                'witness_1_name' => $data['witness_1_name'],
                'witness_2_name' => $data['witness_2_name'],
                'notes' => $data['notes'] ?? null,
                'created_by' => $by->id,
            ]);
            Audit::log($mosque, 'finance.donation_box_counted', $count, [
                'box_name' => $count->box_name,
                'total_amount' => $total,
                'witnesses' => [$count->witness_1_name, $count->witness_2_name],
            ]);

            return [$count, true];
        });
    }

    /** Laporan Kas Jumat 7 hari (Sabtu..Jumat) siap PDF, Poster, dan WhatsApp. */
    public function fridayReport(Mosque $mosque, ?string $date = null): array
    {
        if ($date) {
            $toCarbon = Carbon::parse($date, $mosque->timezone)->startOfDay();
        } else {
            $now = now($mosque->timezone)->startOfDay();
            $toCarbon = $now->isFriday() ? $now : $now->copy()->previous(Carbon::FRIDAY);
        }
        $toDate = $toCarbon->toDateString();
        $fromCarbon = $toCarbon->copy()->subDays(6);
        $fromDate = $fromCarbon->toDateString();
        $prevDate = $fromCarbon->copy()->subDay()->toDateString();

        $openingFunds = $this->fundBalances($mosque, $prevDate);
        $closingFunds = $this->fundBalances($mosque, $toDate);
        $openingBalance = array_sum(array_column($openingFunds, 'balance'));
        $closingBalance = array_sum(array_column($closingFunds, 'balance'));

        $periodBase = FinanceTransaction::where('mosque_id', $mosque->id)
            ->where('date', '>=', $fromDate)
            ->where('date', '<=', $toDate);

        $totals = (clone $periodBase)->selectRaw(
            "coalesce(sum(case when flow='in' then amount end),0) as total_in, coalesce(sum(case when flow='out' then amount end),0) as total_out"
        )->first();
        $totalIn = (int) ($totals->total_in ?? 0);
        $totalOut = (int) ($totals->total_out ?? 0);

        $topIn = (clone $periodBase)->where('flow', 'in')->with('fund:id,name')
            ->orderByDesc('amount')->orderByDesc('id')->limit(5)->get()
            ->map(fn (FinanceTransaction $t) => [
                'date' => $t->date->toDateString(),
                'description' => $t->description,
                'amount' => $t->amount,
                'fund_name' => $t->fund?->name,
            ])->all();

        $topOut = (clone $periodBase)->where('flow', 'out')->with('fund:id,name')
            ->orderByDesc('amount')->orderByDesc('id')->limit(5)->get()
            ->map(fn (FinanceTransaction $t) => [
                'date' => $t->date->toDateString(),
                'description' => $t->description,
                'amount' => $t->amount,
                'fund_name' => $t->fund?->name,
            ])->all();

        $fmt = fn (int $n): string => number_format($n, 0, ',', '.');
        $fundLines = collect($closingFunds)
            ->map(fn ($f) => "- {$f['name']}: Rp{$fmt((int) $f['balance'])}")
            ->implode("\n");

        $waLines = [
            '*LAPORAN KAS JUMAT*',
            "*{$mosque->name}*",
            "Periode: {$fromDate} s.d. {$toDate}",
            '',
            "Saldo Awal: Rp{$fmt($openingBalance)}",
            "Pemasukan: +Rp{$fmt($totalIn)}",
            "Pengeluaran: -Rp{$fmt($totalOut)}",
            "*Saldo Akhir: Rp{$fmt($closingBalance)}*",
        ];
        if ($fundLines !== '') {
            $waLines[] = '';
            $waLines[] = 'Rincian Saldo Dana:';
            $waLines[] = $fundLines;
        }
        $waLines[] = '';
        $waLines[] = 'Jazakumullahu khairan katsiran atas infaq dan amanah jamaah.';

        return [
            'mosque_name' => $mosque->name,
            'mosque_city' => $mosque->city,
            'from' => $fromDate,
            'to' => $toDate,
            'opening_balance' => $openingBalance,
            'total_in' => $totalIn,
            'total_out' => $totalOut,
            'net' => $totalIn - $totalOut,
            'closing_balance' => $closingBalance,
            'funds' => $closingFunds,
            'top_in' => $topIn,
            'top_out' => $topOut,
            'whatsapp_text' => implode("\n", $waLines),
        ];
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
