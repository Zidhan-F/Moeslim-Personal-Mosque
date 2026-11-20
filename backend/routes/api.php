<?php

use App\Http\Controllers\Api\AuditLogController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\MemberController;
use App\Http\Controllers\Api\MosqueController;
use App\Http\Controllers\Api\SubscriptionController;
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
    Route::delete('me', [AuthController::class, 'destroy'])->middleware('throttle:5,1');
    Route::get('mosques', [MosqueController::class, 'index']);
    Route::post('mosques', [MosqueController::class, 'store']);
    Route::post('invitations/accept', [MemberController::class, 'accept'])->middleware('throttle:10,1');

    Route::prefix('mosques/{mosque}')->middleware('tenant')->scopeBindings()->group(function () {
        // Billing tetap dapat diakses walau langganan berakhir.
        Route::get('subscription', [SubscriptionController::class, 'show'])->middleware('perm:dashboard.view');
        Route::post('subscription/verify', [SubscriptionController::class, 'verify'])->middleware(['perm:billing.manage', 'throttle:10,1']);
    });

    Route::prefix('mosques/{mosque}')->middleware(['tenant', 'entitled'])->scopeBindings()->group(function () {
        Route::get('/', [MosqueController::class, 'show']);
        Route::get('dashboard', DashboardController::class)->middleware('perm:dashboard.view');
        Route::patch('/', [MosqueController::class, 'update'])->middleware('perm:mosque.update');

        Route::get('members', [MemberController::class, 'index'])->middleware('perm:members.view');
        Route::middleware('perm:members.manage')->group(function () {
            Route::post('members/invite', [MemberController::class, 'invite']);
            Route::delete('invitations/{invitation}', [MemberController::class, 'revokeInvitation']);
            Route::patch('members/{member}', [MemberController::class, 'update']);
            Route::post('members/{member}/deactivate', [MemberController::class, 'deactivate']);
            Route::post('members/{member}/reactivate', [MemberController::class, 'reactivate']);
            Route::post('transfer-ownership', [MemberController::class, 'transferOwnership']);
        });

        Route::get('audit-logs', [AuditLogController::class, 'index'])->middleware('perm:audit.view');

        require __DIR__.'/tenant.php';
    });
});

require __DIR__.'/public.php';
