<?php

use App\Http\Controllers\Api\AuditLogController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\EventRegistrationController;
use App\Http\Controllers\Api\FamilyController;
use App\Http\Controllers\Api\MemberController;
use App\Http\Controllers\Api\MosqueController;
use App\Http\Controllers\Api\ServiceController;
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

    // Moeslim Family Cloud (opt-in bagi akun Personal; terpisah dari Mosque)
    Route::prefix('families')->group(function () {
        Route::get('/', [FamilyController::class, 'index']);
        Route::post('/', [FamilyController::class, 'store'])->middleware('throttle:10,1');
        Route::get('{family}', [FamilyController::class, 'show']);
        Route::patch('{family}', [FamilyController::class, 'update']);
        Route::delete('{family}', [FamilyController::class, 'destroy']);
        Route::post('{family}/invites', [FamilyController::class, 'invite'])->middleware('throttle:15,1');
        Route::delete('{family}/invites/{invite}', [FamilyController::class, 'revoke']);
        Route::put('{family}/events/{event}', [FamilyController::class, 'saveEvent']);
        Route::post('{family}/goals', [FamilyController::class, 'saveGoal']);
        Route::delete('{family}/goals/{goal}', [FamilyController::class, 'deleteGoal']);
        Route::delete('{family}/members/{memberUserId}', [FamilyController::class, 'removeMember']);
        Route::post('{family}/leave', [FamilyController::class, 'leave']);
    });
    Route::post('family-invites/accept', [FamilyController::class, 'accept'])->middleware('throttle:10,1');

    // Pendaftaran kegiatan Ramadan Local & Kelas Masjid + Moeslim Services (sisi Jamaah/Personal)
    Route::get('me/registrations', [EventRegistrationController::class, 'myRegistrations']);
    Route::post('events/{event}/registrations', [EventRegistrationController::class, 'register'])->middleware('throttle:20,1');
    Route::delete('events/{event}/registrations', [EventRegistrationController::class, 'cancel']);

    Route::post('public/mosques/{slug}/service-requests', [ServiceController::class, 'submit'])->middleware('throttle:20,1');
    Route::get('me/service-requests', [ServiceController::class, 'myRequests']);
    Route::get('me/service-requests/{serviceRequest}', [ServiceController::class, 'myShow']);
    Route::post('me/service-requests/{serviceRequest}/resubmit', [ServiceController::class, 'resubmit'])->middleware('throttle:20,1');
    Route::post('me/service-requests/{serviceRequest}/cancel', [ServiceController::class, 'cancelByApplicant']);
    Route::post('me/service-requests/{serviceRequest}/attachments', [ServiceController::class, 'uploadAttachment'])->middleware('throttle:15,1');
    Route::get('service-attachments/{attachmentId}', [ServiceController::class, 'downloadAttachment']);

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
