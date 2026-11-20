<?php

use App\Http\Controllers\Api\DisplayController;
use Illuminate\Support\Facades\Route;

// Perangkat TV Display
Route::post('display/pair', [DisplayController::class, 'pair'])->middleware('throttle:5,1');
Route::get('display/content', [DisplayController::class, 'content'])->middleware(['display.auth', 'throttle:120,1']);
