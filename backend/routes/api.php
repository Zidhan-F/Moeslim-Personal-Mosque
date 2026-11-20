<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MosqueController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register'])->middleware('throttle:10,1');
    Route::post('login', [AuthController::class, 'login'])->middleware('throttle:10,1');

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::post('email/send-code', [AuthController::class, 'sendVerificationCode'])->middleware('throttle:5,1');
        Route::post('email/verify', [AuthController::class, 'verifyEmail'])->middleware('throttle:10,1');
    });
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('me', [AuthController::class, 'me']);
    Route::get('mosques', [MosqueController::class, 'index']);
    Route::post('mosques', [MosqueController::class, 'store']);
});
