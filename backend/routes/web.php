<?php

use App\Http\Controllers\PublicMosqueWebController;
use App\Http\Controllers\PublicReceiptController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/m/{slug}', [PublicMosqueWebController::class, 'show']);
Route::get('/verify/receipt/{token}', [PublicReceiptController::class, 'webShow']);
