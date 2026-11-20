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

Route::get('events', [\App\Http\Controllers\Api\EventController::class, 'index'])->middleware('perm:events.view');
Route::patch('events/{event}/display', [\App\Http\Controllers\Api\EventController::class, 'toggleDisplay'])->middleware('perm:events.display');
Route::middleware('perm:events.write')->group(function () {
    Route::post('events', [\App\Http\Controllers\Api\EventController::class, 'store']);
    Route::patch('events/{event}', [\App\Http\Controllers\Api\EventController::class, 'update']);
    Route::post('events/{event}/archive', [\App\Http\Controllers\Api\EventController::class, 'archive']);
    Route::delete('events/{event}', [\App\Http\Controllers\Api\EventController::class, 'destroy']);
});

Route::get('announcements', [\App\Http\Controllers\Api\AnnouncementController::class, 'index'])->middleware('perm:events.view');
Route::patch('announcements/{announcement}/display', [\App\Http\Controllers\Api\AnnouncementController::class, 'toggleDisplay'])->middleware('perm:events.display');
Route::middleware('perm:events.write')->group(function () {
    Route::post('announcements', [\App\Http\Controllers\Api\AnnouncementController::class, 'store']);
    Route::patch('announcements/{announcement}', [\App\Http\Controllers\Api\AnnouncementController::class, 'update']);
    Route::post('announcements/{announcement}/archive', [\App\Http\Controllers\Api\AnnouncementController::class, 'archive']);
    Route::delete('announcements/{announcement}', [\App\Http\Controllers\Api\AnnouncementController::class, 'destroy']);
});

Route::get('staff-assignments', [\App\Http\Controllers\Api\StaffAssignmentController::class, 'index'])->middleware('perm:staff.view');
Route::middleware('perm:staff.write')->group(function () {
    Route::post('staff-assignments', [\App\Http\Controllers\Api\StaffAssignmentController::class, 'store']);
    Route::patch('staff-assignments/{staffAssignment}', [\App\Http\Controllers\Api\StaffAssignmentController::class, 'update']);
    Route::delete('staff-assignments/{staffAssignment}', [\App\Http\Controllers\Api\StaffAssignmentController::class, 'destroy']);
});

Route::middleware('perm:inventory.view')->group(function () {
    Route::get('inventory', [\App\Http\Controllers\Api\InventoryController::class, 'index']);
    Route::get('inventory/{inventoryItem}', [\App\Http\Controllers\Api\InventoryController::class, 'show']);
});
Route::middleware('perm:inventory.write')->group(function () {
    Route::post('inventory', [\App\Http\Controllers\Api\InventoryController::class, 'store']);
    Route::patch('inventory/{inventoryItem}', [\App\Http\Controllers\Api\InventoryController::class, 'update']);
    Route::delete('inventory/{inventoryItem}', [\App\Http\Controllers\Api\InventoryController::class, 'destroy']);
    Route::post('inventory/{inventoryItem}/maintenance', [\App\Http\Controllers\Api\InventoryController::class, 'storeMaintenance']);
});
