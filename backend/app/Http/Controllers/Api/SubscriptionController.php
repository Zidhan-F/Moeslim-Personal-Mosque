<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mosque;
use App\Services\Billing\GooglePlayBillingProvider;
use App\Services\FinanceService;
use App\Services\SubscriptionService;
use App\Support\Audit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class SubscriptionController extends Controller
{
    public function __construct(private readonly SubscriptionService $subs) {}

    public function show(Mosque $mosque, FinanceService $finance): JsonResponse
    {
        return response()->json([
            'data' => $this->subs->present($mosque),
            'usage' => $this->subs->usage($mosque, $finance),
        ]);
    }

    public function verify(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate([
            'provider' => ['required', Rule::in(['google_play'])],
            'purchase_token' => ['required', 'string', 'max:2000'],
            'product_id' => ['required', 'string', 'max:100'],
        ]);
        $result = app(GooglePlayBillingProvider::class)->verify($mosque, $data);
        $this->subs->activate($mosque, $result['months'], $data['provider'], $result['external_ref']);
        Audit::log($mosque, 'billing.activated', null, ['provider' => $data['provider'], 'months' => $result['months']]);

        return response()->json(['data' => $this->subs->present($mosque->fresh())]);
    }
}
