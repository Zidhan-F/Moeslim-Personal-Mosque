<?php

use App\Http\Controllers\Api\AnnouncementController;
use App\Http\Controllers\Api\DisplayController;
use App\Http\Controllers\Api\EventController;
use App\Http\Controllers\Api\FinanceController;
use App\Http\Controllers\Api\InventoryController;
use App\Http\Controllers\Api\StaffAssignmentController;
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

Route::get('events', [EventController::class, 'index'])->middleware('perm:events.view');
Route::patch('events/{event}/display', [EventController::class, 'toggleDisplay'])->middleware('perm:events.display');
Route::middleware('perm:events.write')->group(function () {
    Route::post('events', [EventController::class, 'store']);
    Route::patch('events/{event}', [EventController::class, 'update']);
    Route::post('events/{event}/archive', [EventController::class, 'archive']);
    Route::delete('events/{event}', [EventController::class, 'destroy']);
});

Route::get('announcements', [AnnouncementController::class, 'index'])->middleware('perm:events.view');
Route::patch('announcements/{announcement}/display', [AnnouncementController::class, 'toggleDisplay'])->middleware('perm:events.display');
Route::middleware('perm:events.write')->group(function () {
    Route::post('announcements', [AnnouncementController::class, 'store']);
    Route::patch('announcements/{announcement}', [AnnouncementController::class, 'update']);
    Route::post('announcements/{announcement}/archive', [AnnouncementController::class, 'archive']);
    Route::delete('announcements/{announcement}', [AnnouncementController::class, 'destroy']);
});

Route::get('staff-assignments', [StaffAssignmentController::class, 'index'])->middleware('perm:staff.view');
Route::middleware('perm:staff.write')->group(function () {
    Route::post('staff-assignments', [StaffAssignmentController::class, 'store']);
    Route::patch('staff-assignments/{staffAssignment}', [StaffAssignmentController::class, 'update']);
    Route::delete('staff-assignments/{staffAssignment}', [StaffAssignmentController::class, 'destroy']);
});

Route::middleware('perm:inventory.view')->group(function () {
    Route::get('inventory', [InventoryController::class, 'index']);
    Route::get('inventory/{inventoryItem}', [InventoryController::class, 'show']);
});
Route::middleware('perm:inventory.write')->group(function () {
    Route::post('inventory', [InventoryController::class, 'store']);
    Route::patch('inventory/{inventoryItem}', [InventoryController::class, 'update']);
    Route::delete('inventory/{inventoryItem}', [InventoryController::class, 'destroy']);
    Route::post('inventory/{inventoryItem}/maintenance', [InventoryController::class, 'storeMaintenance']);
});

Route::get('displays', [DisplayController::class, 'index'])->middleware('perm:display.view');
Route::middleware('perm:display.manage')->group(function () {
    Route::post('displays/pairing-codes', [DisplayController::class, 'createPairingCode']);
    Route::patch('displays/{displayDevice}', [DisplayController::class, 'update']);
    Route::post('displays/{displayDevice}/revoke', [DisplayController::class, 'revoke']);
});
