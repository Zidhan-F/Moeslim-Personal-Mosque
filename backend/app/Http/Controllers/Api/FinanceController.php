<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\DomainRuleException;
use App\Http\Controllers\Controller;
use App\Models\CashAccount;
use App\Models\FinanceAttachment;
use App\Models\FinanceTransaction;
use App\Models\Mosque;
use App\Services\FinanceService;
use App\Support\Audit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Symfony\Component\HttpFoundation\StreamedResponse;

class FinanceController extends Controller
{
    public function __construct(private readonly FinanceService $finance) {}

    public function setup(Mosque $mosque): JsonResponse
    {
        return response()->json([
            'funds' => $mosque->funds()->get(['id', 'code', 'name', 'restricted', 'is_active']),
            'accounts' => $mosque->cashAccounts()->get(['id', 'name', 'type', 'is_active']),
            'categories' => $mosque->financeCategories()->get(['id', 'name', 'flow', 'is_active']),
        ]);
    }

    public function storeAccount(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'type' => ['required', Rule::in(CashAccount::TYPES)],
        ]);
        $account = $mosque->cashAccounts()->create($data);
        Audit::log($mosque, 'finance.account_created', $account, $data);

        return response()->json(['data' => $account], 201);
    }

    public function storeFund(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate([
            'code' => ['required', 'alpha_dash', 'max:24', Rule::unique('funds')->where('mosque_id', $mosque->id)],
            'name' => ['required', 'string', 'max:100'],
            'restricted' => ['required', 'boolean'],
        ]);
        $fund = $mosque->funds()->create($data + ['sort' => 100]);
        Audit::log($mosque, 'finance.fund_created', $fund, $data);

        return response()->json(['data' => $fund], 201);
    }

    public function storeCategory(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'flow' => ['required', Rule::in(['in', 'out'])],
        ]);
        $cat = $mosque->financeCategories()->create($data);

        return response()->json(['data' => $cat], 201);
    }

    public function index(Request $request, Mosque $mosque): JsonResponse
    {
        $f = $request->validate([
            'from' => ['nullable', 'date'], 'to' => ['nullable', 'date'],
            'fund_id' => ['nullable', 'integer'], 'cash_account_id' => ['nullable', 'integer'],
            'flow' => ['nullable', Rule::in(FinanceTransaction::FLOWS)], 'q' => ['nullable', 'string', 'max:100'],
        ]);
        $page = $this->filtered($mosque, $f)->with(['fund:id,code,name', 'account:id,name', 'toAccount:id,name', 'category:id,name'])
            ->withCount('attachments')->orderByDesc('date')->orderByDesc('id')->paginate(50);

        return response()->json($page->through(fn ($t) => $this->present($t)));
    }

    public function show(Mosque $mosque, FinanceTransaction $transaction): JsonResponse
    {
        $transaction->load(['fund:id,code,name', 'account:id,name', 'toAccount:id,name', 'category:id,name', 'attachments', 'reversedBy:id,reversal_of_id,reference_no']);

        return response()->json(['data' => $this->present($transaction) + [
            'attachments' => $transaction->attachments->map(fn ($a) => [
                'id' => $a->id, 'name' => $a->original_name, 'mime' => $a->mime, 'bytes' => $a->bytes,
            ]),
            'reversed_by' => $transaction->reversedBy?->reference_no,
        ]]);
    }

    public function store(Request $request, Mosque $mosque): JsonResponse
    {
        $key = $request->header('Idempotency-Key');
        if (! $key || strlen($key) > 100) {
            throw new DomainRuleException('idempotency_key_required', 'Header Idempotency-Key wajib diisi.', 428);
        }

        $data = $request->validate([
            'flow' => ['required', Rule::in(FinanceTransaction::FLOWS)],
            'amount' => ['required', 'integer', 'min:1', 'max:999999999999'],
            'fund_id' => ['required', 'integer', Rule::exists('funds', 'id')->where('mosque_id', $mosque->id)->where('is_active', true)],
            'cash_account_id' => ['required', 'integer', Rule::exists('cash_accounts', 'id')->where('mosque_id', $mosque->id)->where('is_active', true)],
            'to_cash_account_id' => ['required_if:flow,transfer', 'nullable', 'integer', 'different:cash_account_id', Rule::exists('cash_accounts', 'id')->where('mosque_id', $mosque->id)->where('is_active', true)],
            'category_id' => ['nullable', 'integer', Rule::exists('finance_categories', 'id')->where('mosque_id', $mosque->id)],
            'date' => ['required', 'date', 'before_or_equal:'.now()->addDay()->toDateString()],
            'description' => ['required', 'string', 'max:255'],
        ]);

        [$tx, $created] = $this->finance->record($mosque, $request->user(), $data, $key);
        $tx->load(['fund:id,code,name', 'account:id,name', 'toAccount:id,name', 'category:id,name']);

        $count = $this->finance->monthlyCount($mosque);

        return response()->json([
            'data' => $this->present($tx),
            'warnings' => $count >= Mosque::MONTHLY_TRANSACTION_SOFT_LIMIT
                ? ['monthly_transaction_soft_limit' => "Penggunaan bulan ini {$count} transaksi melebihi batas wajar ".Mosque::MONTHLY_TRANSACTION_SOFT_LIMIT.'; tim kami akan meninjau.']
                : [],
        ], $created ? 201 : 200);
    }

    public function reverse(Request $request, Mosque $mosque, FinanceTransaction $transaction): JsonResponse
    {
        $data = $request->validate(['reason' => ['required', 'string', 'max:150']]);
        $tx = $this->finance->reverse($mosque, $request->user(), $transaction, $data['reason']);
        $tx->load(['fund:id,code,name', 'account:id,name', 'toAccount:id,name', 'category:id,name']);

        return response()->json(['data' => $this->present($tx)], 201);
    }

    public function summary(Request $request, Mosque $mosque): JsonResponse
    {
        $f = $request->validate(['from' => ['required', 'date'], 'to' => ['required', 'date', 'after_or_equal:from']]);
        $period = $this->filtered($mosque, $f);
        $totals = (clone $period)->selectRaw(
            "coalesce(sum(case when flow='in' then amount end),0) as total_in, coalesce(sum(case when flow='out' then amount end),0) as total_out"
        )->first();
        $byCategory = (clone $period)->whereIn('finance_transactions.flow', ['in', 'out'])
            ->leftJoin('finance_categories as c', 'c.id', '=', 'finance_transactions.category_id')
            ->selectRaw("finance_transactions.flow, coalesce(c.name, 'Tanpa kategori') as category, sum(finance_transactions.amount) as total")
            ->groupBy('finance_transactions.flow', 'c.name')->orderByDesc('total')->get()
            ->map(fn ($r) => ['flow' => $r->flow, 'category' => $r->category, 'total' => (int) $r->total]);

        return response()->json([
            'from' => $f['from'],
            'to' => $f['to'],
            'total_in' => (int) $totals->total_in,
            'total_out' => (int) $totals->total_out,
            'net' => (int) $totals->total_in - (int) $totals->total_out,
            'balance' => array_sum(array_column($this->finance->fundBalances($mosque, $f['to']), 'balance')),
            'funds' => $this->finance->fundBalances($mosque, $f['to']),
            'accounts' => $this->finance->accountBalances($mosque, $f['to']),
            'by_category' => $byCategory,
        ]);
    }

    public function monthly(Request $request, Mosque $mosque): JsonResponse
    {
        $year = (int) $request->validate(['year' => ['required', 'integer', 'between:2000,2100']])['year'];
        $rows = FinanceTransaction::where('mosque_id', $mosque->id)->whereYear('date', $year)
            ->selectRaw("extract(month from date)::int as m, coalesce(sum(case when flow='in' then amount end),0) as i, coalesce(sum(case when flow='out' then amount end),0) as o")
            ->groupBy('m')->get()->keyBy('m');

        return response()->json([
            'year' => $year,
            'months' => collect(range(1, 12))->map(fn ($m) => [
                'month' => $m, 'in' => (int) ($rows[$m]->i ?? 0), 'out' => (int) ($rows[$m]->o ?? 0),
            ])->all(),
        ]);
    }

    public function export(Request $request, Mosque $mosque): StreamedResponse
    {
        $f = $request->validate(['from' => ['required', 'date'], 'to' => ['required', 'date', 'after_or_equal:from']]);
        Audit::log($mosque, 'finance.exported', null, $f);
        $query = $this->filtered($mosque, $f)->with(['fund:id,name', 'account:id,name', 'toAccount:id,name', 'category:id,name'])
            ->orderBy('date')->orderBy('id');
        $filename = "kas-{$mosque->slug}-{$f['from']}-{$f['to']}.csv";

        return response()->streamDownload(function () use ($query) {
            $out = fopen('php://output', 'w');
            fwrite($out, "\xEF\xBB\xBF"); // BOM agar Excel membaca UTF-8
            fputcsv($out, ['Tanggal', 'No. Referensi', 'Jenis', 'Dana', 'Akun', 'Akun Tujuan', 'Kategori', 'Keterangan', 'Masuk', 'Keluar']);
            $query->chunk(500, function ($rows) use ($out) {
                foreach ($rows as $t) {
                    fputcsv($out, [
                        $t->date->toDateString(), $t->reference_no,
                        ['in' => 'Masuk', 'out' => 'Keluar', 'transfer' => 'Transfer'][$t->flow],
                        $t->fund?->name, $t->account?->name, $t->toAccount?->name, $t->category?->name,
                        $this->csvSafe($t->description),
                        $t->flow === 'in' ? $t->amount : '', $t->flow === 'out' ? $t->amount : '',
                    ]);
                }
            });
            fclose($out);
        }, $filename, ['Content-Type' => 'text/csv; charset=UTF-8']);
    }

    public function storeAttachment(Request $request, Mosque $mosque, FinanceTransaction $transaction): JsonResponse
    {
        $request->validate(['file' => ['required', 'file', 'max:5120', 'mimes:jpg,jpeg,png,webp,pdf']]);
        $file = $request->file('file');
        $bytes = $file->getSize();

        $attachment = DB::transaction(function () use ($request, $mosque, $transaction, $file, $bytes) {
            $locked = Mosque::whereKey($mosque->id)->lockForUpdate()->first();
            if ($locked->storage_used_bytes + $bytes > Mosque::STORAGE_QUOTA_BYTES) {
                throw new DomainRuleException('storage_quota_exceeded', 'Kuota penyimpanan 1 GB penuh. Pencatatan transaksi tetap dapat dilakukan tanpa lampiran.');
            }
            $disk = config('filesystems.attachments_disk', 'local');
            $path = Storage::disk($disk)->putFileAs(
                "mosques/{$mosque->id}/attachments",
                $file,
                Str::ulid().'.'.$file->extension()
            );
            $locked->increment('storage_used_bytes', $bytes);

            return FinanceAttachment::create([
                'mosque_id' => $mosque->id,
                'transaction_id' => $transaction->id,
                'disk' => $disk,
                'path' => $path,
                'original_name' => mb_substr($file->getClientOriginalName(), 0, 200),
                'mime' => $file->getMimeType(),
                'bytes' => $bytes,
                'uploaded_by' => $request->user()->id,
            ]);
        });
        Audit::log($mosque, 'finance.attachment_uploaded', $attachment, ['transaction' => $transaction->reference_no, 'bytes' => $bytes]);

        return response()->json(['data' => ['id' => $attachment->id, 'name' => $attachment->original_name, 'bytes' => $bytes]], 201);
    }

    public function downloadAttachment(Mosque $mosque, FinanceAttachment $attachment)
    {
        abort_unless($attachment->mosque_id === $mosque->id, 404);
        $disk = Storage::disk($attachment->disk);
        if (method_exists($disk, 'temporaryUrl') && config("filesystems.disks.{$attachment->disk}.driver") === 's3') {
            return response()->json(['url' => $disk->temporaryUrl($attachment->path, now()->addMinutes(5))]);
        }

        return $disk->download($attachment->path, $attachment->original_name);
    }

    private function filtered(Mosque $mosque, array $f)
    {
        $t = 'finance_transactions';

        return FinanceTransaction::where("{$t}.mosque_id", $mosque->id)
            ->when($f['from'] ?? null, fn ($q, $v) => $q->where("{$t}.date", '>=', $v))
            ->when($f['to'] ?? null, fn ($q, $v) => $q->where("{$t}.date", '<=', $v))
            ->when($f['fund_id'] ?? null, fn ($q, $v) => $q->where("{$t}.fund_id", $v))
            ->when($f['cash_account_id'] ?? null, fn ($q, $v) => $q->where(fn ($w) => $w->where("{$t}.cash_account_id", $v)->orWhere("{$t}.to_cash_account_id", $v)))
            ->when($f['flow'] ?? null, fn ($q, $v) => $q->where("{$t}.flow", $v))
            ->when($f['q'] ?? null, fn ($q, $v) => $q->where(fn ($w) => $w->where("{$t}.description", 'ilike', '%'.addcslashes($v, '%_\\').'%')->orWhere("{$t}.reference_no", $v)));
    }

    /** Cegah CSV/formula injection saat dibuka di Excel. */
    private function csvSafe(?string $v): ?string
    {
        return $v !== null && preg_match('/^[=+\-@\t\r]/', $v) ? "'".$v : $v;
    }

    private function present(FinanceTransaction $t): array
    {
        return [
            'id' => $t->id,
            'reference_no' => $t->reference_no,
            'flow' => $t->flow,
            'amount' => $t->amount,
            'date' => $t->date->toDateString(),
            'description' => $t->description,
            'fund' => $t->fund ? ['id' => $t->fund->id, 'code' => $t->fund->code, 'name' => $t->fund->name] : null,
            'account' => $t->account ? ['id' => $t->account->id, 'name' => $t->account->name] : null,
            'to_account' => $t->toAccount ? ['id' => $t->toAccount->id, 'name' => $t->toAccount->name] : null,
            'category' => $t->category ? ['id' => $t->category->id, 'name' => $t->category->name] : null,
            'reversal_of_id' => $t->reversal_of_id,
            'attachments_count' => $t->attachments_count ?? null,
            'created_by' => $t->created_by,
            'created_at' => $t->created_at,
        ];
    }
}
