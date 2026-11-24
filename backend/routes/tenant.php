<?php

use App\Http\Controllers\Api\AnnouncementController;
use App\Http\Controllers\Api\CouponController;
use App\Http\Controllers\Api\DisplayController;
use App\Http\Controllers\Api\EventController;
use App\Http\Controllers\Api\EventRegistrationController;
use App\Http\Controllers\Api\FinanceController;
use App\Http\Controllers\Api\InventoryController;
use App\Http\Controllers\Api\QurbanController;
use App\Http\Controllers\Api\ServiceController;
use App\Http\Controllers\Api\StaffAssignmentController;
use App\Http\Controllers\Api\ZakatController;
use Illuminate\Support\Facades\Route;

// Dimuat di dalam grup mosques/{mosque} (auth:sanctum + tenant + scopeBindings).

Route::prefix('finance')->group(function () {
    Route::middleware('perm:finance.view')->group(function () {
        Route::get('setup', [FinanceController::class, 'setup']);
        Route::get('transactions', [FinanceController::class, 'index']);
        Route::get('transactions/{transaction}', [FinanceController::class, 'show']);
        Route::get('transactions/{transaction}/receipt', [FinanceController::class, 'receipt']);
        Route::get('summary', [FinanceController::class, 'summary']);
        Route::get('reports/monthly', [FinanceController::class, 'monthly']);
        Route::get('friday-report', [FinanceController::class, 'fridayReport']);
        Route::get('donation-box-counts', [FinanceController::class, 'donationBoxCounts']);
        Route::get('attachments/{attachment}', [FinanceController::class, 'downloadAttachment']);
    });
    Route::get('export', [FinanceController::class, 'export'])->middleware(['perm:finance.export', 'throttle:20,1']);

    Route::middleware('perm:finance.write')->group(function () {
        Route::post('transactions', [FinanceController::class, 'store']);
        Route::post('transactions/{transaction}/reverse', [FinanceController::class, 'reverse']);
        Route::post('transactions/{transaction}/attachments', [FinanceController::class, 'storeAttachment']);
        Route::post('donation-box-counts', [FinanceController::class, 'storeDonationBoxCount']);
        Route::post('accounts', [FinanceController::class, 'storeAccount']);
        Route::post('funds', [FinanceController::class, 'storeFund']);
        Route::post('categories', [FinanceController::class, 'storeCategory']);
    });
});

Route::get('events', [EventController::class, 'index'])->middleware('perm:events.view');
Route::get('events/{event}/registrations', [EventRegistrationController::class, 'mosqueIndex'])->middleware('perm:events.view');
Route::patch('events/{event}/display', [EventController::class, 'toggleDisplay'])->middleware('perm:events.display');
Route::middleware('perm:events.write')->group(function () {
    Route::post('events', [EventController::class, 'store']);
    Route::patch('events/{event}', [EventController::class, 'update']);
    Route::post('events/{event}/archive', [EventController::class, 'archive']);
    Route::delete('events/{event}', [EventController::class, 'destroy']);
    Route::patch('events/{event}/registrations/{registration}', [EventRegistrationController::class, 'mosqueUpdateStatus']);
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
Route::get('displays/preview', [DisplayController::class, 'preview'])->middleware('perm:display.view');
Route::get('displays/qris-image', [DisplayController::class, 'adminQrisImage'])->middleware('perm:display.view');
Route::middleware('perm:display.manage')->group(function () {
    Route::patch('displays/settings', [DisplayController::class, 'updateSettings']);
    Route::post('displays/override', [DisplayController::class, 'setOverride']);
    Route::delete('displays/override', [DisplayController::class, 'clearOverride']);
    Route::post('displays/qris', [DisplayController::class, 'uploadQris']);
    Route::delete('displays/qris', [DisplayController::class, 'deleteQris']);
    Route::post('displays/pairing-codes', [DisplayController::class, 'createPairingCode']);
    Route::post('displays/approve-session', [DisplayController::class, 'approveSession']);
    Route::patch('displays/{displayDevice}', [DisplayController::class, 'update']);
    Route::post('displays/{displayDevice}/revoke', [DisplayController::class, 'revoke']);
});

Route::prefix('zakat')->group(function () {
    Route::get('/', [ZakatController::class, 'index'])->middleware('perm:zakat.view');
    Route::middleware('perm:zakat.write')->group(function () {
        Route::post('collections', [ZakatController::class, 'storeCollection']);
        Route::post('mustahiks', [ZakatController::class, 'storeMustahik']);
        Route::post('mustahiks/{zakatMustahik}/distribute', [ZakatController::class, 'distributeMustahik']);
    });
});

Route::prefix('qurban')->group(function () {
    Route::get('animals', [QurbanController::class, 'index'])->middleware('perm:qurban.view');
    Route::middleware('perm:qurban.write')->group(function () {
        Route::post('animals', [QurbanController::class, 'storeAnimal']);
        Route::patch('animals/{qurbanAnimal}', [QurbanController::class, 'updateAnimal']);
        Route::post('animals/{qurbanAnimal}/participants', [QurbanController::class, 'storeParticipant']);
        Route::patch('participants/{qurbanParticipant}', [QurbanController::class, 'updateParticipant']);
    });
});

Route::prefix('coupons')->group(function () {
    Route::get('/', [CouponController::class, 'index'])->middleware('perm:qurban.view');
    Route::middleware('perm:qurban.write')->group(function () {
        Route::post('/', [CouponController::class, 'store']);
        Route::post('redeem', [CouponController::class, 'redeem']);
        Route::post('{distributionCoupon}/void', [CouponController::class, 'void']);
    });
});

// Moeslim Services (pengelolaan layanan & permohonan jamaah)
Route::middleware('perm:services.view')->group(function () {
    Route::get('services', [ServiceController::class, 'mosqueDefinitions']);
    Route::get('service-requests', [ServiceController::class, 'mosqueInbox']);
    Route::get('service-requests/{serviceRequestId}', [ServiceController::class, 'mosqueShowRequest']);
});
Route::middleware('perm:services.manage')->group(function () {
    Route::post('services', [ServiceController::class, 'storeDefinition']);
    Route::patch('services/{definitionId}', [ServiceController::class, 'updateDefinition']);
    Route::patch('service-requests/{serviceRequestId}/status', [ServiceController::class, 'updateStatus']);
    Route::get('services/{definitionId}/export', [ServiceController::class, 'exportCsv'])->middleware('throttle:20,1');
});
