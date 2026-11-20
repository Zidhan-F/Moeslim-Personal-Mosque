<?php

namespace App\Http\Controllers\Api;

use App\Exceptions\DomainRuleException;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\EmailVerifier;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(private readonly EmailVerifier $verifier) {}

    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:32', 'unique:users,phone'],
            'password' => ['required', 'confirmed', Password::min(10)],
            'device_name' => ['nullable', 'string', 'max:100'],
        ]);

        $user = User::create($data);
        $this->verifier->send($user);

        return response()->json([
            'token' => $user->createToken($data['device_name'] ?? 'mobile')->plainTextToken,
            'user' => $user->toPublicArray(),
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ]);

        $user = User::where('email', $data['email'])->first();
        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages(['email' => 'Email atau kata sandi salah.']);
        }

        return response()->json([
            'token' => $user->createToken($data['device_name'] ?? 'mobile')->plainTextToken,
            'user' => $user->toPublicArray(),
        ]);
    }

    public function logout(Request $request): Response
    {
        $request->user()->currentAccessToken()->delete();

        return response()->noContent();
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        $memberships = $user->memberships()->where('status', 'active')->with('mosque:id,name,slug')->get()
            ->map(fn ($m) => [
                'mosque_id' => $m->mosque_id,
                'mosque_name' => $m->mosque->name,
                'role' => $m->role,
                'is_owner' => $m->is_owner,
            ]);

        return response()->json(['user' => $user->toPublicArray(), 'memberships' => $memberships]);
    }

    /** Hapus akun (UU PDP): data pribadi dianonimkan, riwayat audit & keuangan tetap utuh. */
    public function destroy(Request $request): Response
    {
        $data = $request->validate(['password' => ['required', 'string']]);
        $user = $request->user();
        if (! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages(['password' => 'Kata sandi salah.']);
        }
        if ($user->memberships()->where('is_owner', true)->where('status', 'active')->exists()) {
            throw new DomainRuleException('owner_must_transfer', 'Pindahkan kepemilikan masjid sebelum menghapus akun.');
        }

        DB::transaction(function () use ($user) {
            $user->memberships()->update(['status' => 'inactive', 'deactivated_at' => now()]);
            $user->tokens()->delete();
            $user->forceFill([
                'name' => 'Pengguna terhapus',
                'email' => 'deleted-'.$user->id.'-'.Str::random(8).'@deleted.invalid',
                'phone' => null,
                'password' => Str::random(40),
                'remember_token' => null,
            ])->save();
        });

        return response()->noContent();
    }

    public function sendVerificationCode(Request $request): Response
    {
        if ($request->user()->email_verified_at === null) {
            $this->verifier->send($request->user());
        }

        return response()->noContent();
    }

    public function verifyEmail(Request $request): JsonResponse
    {
        $data = $request->validate(['code' => ['required', 'digits:6']]);
        if (! $this->verifier->verify($request->user(), $data['code'])) {
            throw ValidationException::withMessages(['code' => 'Kode tidak valid atau kedaluwarsa.']);
        }

        return response()->json(['user' => $request->user()->fresh()->toPublicArray()]);
    }
}
