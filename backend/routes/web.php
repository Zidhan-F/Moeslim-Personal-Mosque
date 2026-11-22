<?php

use App\Http\Controllers\PublicMosqueWebController;
use App\Http\Controllers\PublicReceiptController;
use App\Http\Controllers\WebDisplayController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/tv', [WebDisplayController::class, 'show']);
Route::get('/tv/manifest.json', [WebDisplayController::class, 'manifest']);
Route::get('/tv/sw.js', [WebDisplayController::class, 'serviceWorker']);
Route::get('/m/{slug}', [PublicMosqueWebController::class, 'show']);
Route::get('/verify/receipt/{token}', [PublicReceiptController::class, 'webShow']);
