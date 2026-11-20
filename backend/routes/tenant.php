<?php

use App\Http\Controllers\Api\FinanceController;
use Illuminate\Support\Facades\Route;

// Dimuat di dalam grup mosques/{mosque} (auth:sanctum + tenant + scopeBindings).

Route::prefix('finance')->group(function () {
    Route::middleware('perm:finance.view')->group(function () {
        Route::get('setup', [FinanceController::class, 'setup']);
        Route::get('transactions', [FinanceController::class, 'index']);
        Route::get('transactions/{transaction}', [FinanceController::class, 'show']);
        Route::get('summary', [FinanceController::class, 'summary']);
        Route::get('reports/monthly', [FinanceController::class, 'monthly']);
        Route::get('attachments/{attachment}', [FinanceController::class, 'downloadAttachment']);
    });
    Route::get('export', [FinanceController::class, 'export'])->middleware(['perm:finance.export', 'throttle:20,1']);

    Route::middleware('perm:finance.write')->group(function () {
        Route::post('transactions', [FinanceController::class, 'store']);
        Route::post('transactions/{transaction}/reverse', [FinanceController::class, 'reverse']);
        Route::post('transactions/{transaction}/attachments', [FinanceController::class, 'storeAttachment']);
        Route::post('accounts', [FinanceController::class, 'storeAccount']);
        Route::post('funds', [FinanceController::class, 'storeFund']);
        Route::post('categories', [FinanceController::class, 'storeCategory']);
    });
});
