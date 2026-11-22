<?php

namespace App\Http\Controllers;

use App\Models\FinanceTransaction;
use Illuminate\Http\JsonResponse;
use Illuminate\View\View;

class PublicReceiptController extends Controller
{
    public function apiShow(string $token): JsonResponse
    {
        $tx = $this->findByToken($token);

        return response()->json(['data' => $this->payload($tx)]);
    }

    public function webShow(string $token): View
    {
        $tx = $this->findByToken($token);

        return view('public.receipt', ['receipt' => $this->payload($tx)]);
    }

    private function findByToken(string $token): FinanceTransaction
    {
        return FinanceTransaction::where('receipt_token', $token)
            ->with(['mosque:id,name,slug,city,address', 'fund:id,name', 'reversedBy:id,reversal_of_id,reference_no,date'])
            ->firstOrFail();
    }

    private function payload(FinanceTransaction $tx): array
    {
        $reversed = $tx->reversedBy !== null;

        return [
            'receipt_no' => $tx->reference_no,
            'receipt_token' => $tx->receipt_token,
            'status' => $reversed ? 'reversed' : 'valid',
            'reversed_reference' => $tx->reversedBy?->reference_no,
            'mosque_name' => $tx->mosque->name,
            'mosque_slug' => $tx->mosque->slug,
            'mosque_city' => $tx->mosque->city,
            'mosque_address' => $tx->mosque->address,
            'donor_name' => $tx->donor_name ?: 'Hamba Allah',
            'amount' => $tx->amount,
            'fund_name' => $tx->fund?->name,
            'date' => $tx->date->toDateString(),
            'description' => $tx->description,
            'issued_at' => $tx->created_at?->toIso8601String(),
        ];
    }
}
