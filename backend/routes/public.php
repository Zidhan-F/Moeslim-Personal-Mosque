<?php

use App\Http\Controllers\Api\DisplayController;
use App\Http\Controllers\Api\EventRegistrationController;
use App\Http\Controllers\Api\PublicMosqueController;
use App\Http\Controllers\Api\ServiceController;
use App\Http\Controllers\PublicReceiptController;
use Illuminate\Support\Facades\Route;

// Perangkat TV Display
Route::post('display/pair', [DisplayController::class, 'pair'])->middleware('throttle:5,1');
Route::post('display/sessions', [DisplayController::class, 'createSession'])->middleware('throttle:20,1');
Route::post('display/sessions/{sessionId}/poll', [DisplayController::class, 'pollSession'])->middleware('throttle:60,1');
Route::get('display/content', [DisplayController::class, 'content'])->middleware(['display.auth', 'throttle:120,1']);
Route::get('display/qris', [DisplayController::class, 'qrisImage'])->middleware(['display.auth', 'throttle:60,1']);

// API publik untuk Moeslim Personal (ikuti masjid, Ramadan Local, kelas masjid, katalog layanan)
Route::prefix('public')->middleware('throttle:60,1')->group(function () {
    Route::get('mosques', [PublicMosqueController::class, 'search']);
    Route::get('mosques/{slug}', [PublicMosqueController::class, 'show']);
    Route::get('mosques/{slug}/qris', [PublicMosqueController::class, 'qrisImage']);
    Route::get('mosques/{slug}/events', [PublicMosqueController::class, 'events']);
    Route::get('mosques/{slug}/announcements', [PublicMosqueController::class, 'announcements']);
    Route::get('mosques/{slug}/ramadan/events', [EventRegistrationController::class, 'publicRamadan']);
    Route::get('mosques/{slug}/classes', [EventRegistrationController::class, 'publicClasses']);
    Route::get('mosques/{slug}/services', [ServiceController::class, 'publicCatalog']);
    Route::get('receipts/{token}', [PublicReceiptController::class, 'apiShow']);
});
