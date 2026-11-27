<?php

use App\Http\Controllers\Api\DisplayController;
use App\Http\Controllers\Api\PublicDirectoryController;
use App\Http\Controllers\Api\PublicMosqueController;
use Illuminate\Support\Facades\Route;

// Perangkat TV Display
Route::post('display/pair', [DisplayController::class, 'pair'])->middleware('throttle:5,1');
Route::get('display/content', [DisplayController::class, 'content'])->middleware(['display.auth', 'throttle:120,1']);

// API publik untuk Moeslim Personal (ikuti masjid)
Route::prefix('public')->middleware('throttle:60,1')->group(function () {
    Route::get('mosques', [PublicMosqueController::class, 'search']);
    Route::get('mosques/{slug}', [PublicMosqueController::class, 'show']);
    Route::get('mosques/{slug}/events', [PublicMosqueController::class, 'events']);
    Route::get('mosques/{slug}/announcements', [PublicMosqueController::class, 'announcements']);
});

// Direktori Masjid Terdekat (tanpa akun): paket per sel wilayah + laporan koreksi.
Route::prefix('public/directory')->group(function () {
    Route::get('cells/{cell}', [PublicDirectoryController::class, 'cell'])->middleware('throttle:120,1');
    Route::post('reports', [PublicDirectoryController::class, 'report'])->middleware('throttle:10,60');
});
