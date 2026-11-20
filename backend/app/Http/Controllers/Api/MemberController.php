<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mosque;
use App\Models\MosqueInvitation;
use App\Models\MosqueMember;
use App\Services\MemberService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class MemberController extends Controller
{
    public function __construct(private readonly MemberService $service) {}

    public function index(Request $request, Mosque $mosque): JsonResponse
    {
        $members = $mosque->members()->with('user:id,name,email')->orderByDesc('status')->orderBy('id')->get();
        $isAdmin = $request->attributes->get('membership')->role === 'admin';
        $invitations = $isAdmin
            ? MosqueInvitation::where('mosque_id', $mosque->id)->pending()->get(['id', 'email', 'role', 'expires_at'])
            : [];

        return response()->json([
            'data' => $members->map(fn ($m) => $this->present($m, $isAdmin)),
            'invitations' => $invitations,
            'limit' => Mosque::MAX_ACTIVE_MEMBERS,
            'active_count' => $members->where('status', 'active')->count(),
        ]);
    }

    public function invite(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'role' => ['required', Rule::in(MosqueMember::ROLES)],
        ]);
        [$invitation, $token] = $this->service->invite($mosque, $request->user(), $data['email'], $data['role']);

        return response()->json(['data' => [
            'id' => $invitation->id,
            'email' => $invitation->email,
            'role' => $invitation->role,
            'expires_at' => $invitation->expires_at,
            'token' => $token,
        ]], 201);
    }

    public function revokeInvitation(Mosque $mosque, MosqueInvitation $invitation): JsonResponse
    {
        abort_unless($invitation->mosque_id === $mosque->id, 404);
        $invitation->delete();

        return response()->json(['ok' => true]);
    }

    public function accept(Request $request): JsonResponse
    {
        $data = $request->validate(['token' => ['required', 'string']]);
        $member = $this->service->accept($request->user(), $data['token']);

        return response()->json(['data' => ['mosque_id' => $member->mosque_id, 'role' => $member->role]]);
    }

    public function update(Request $request, Mosque $mosque, MosqueMember $member): JsonResponse
    {
        $data = $request->validate(['role' => ['required', Rule::in(MosqueMember::ROLES)]]);

        return response()->json(['data' => $this->present($this->service->changeRole($mosque, $member, $data['role'])->load('user'), true)]);
    }

    public function deactivate(Mosque $mosque, MosqueMember $member): JsonResponse
    {
        return response()->json(['data' => $this->present($this->service->deactivate($mosque, $member)->load('user'), true)]);
    }

    public function reactivate(Mosque $mosque, MosqueMember $member): JsonResponse
    {
        return response()->json(['data' => $this->present($this->service->reactivate($mosque, $member)->load('user'), true)]);
    }

    public function transferOwnership(Request $request, Mosque $mosque): JsonResponse
    {
        $data = $request->validate(['member_id' => ['required', 'integer']]);
        $to = $mosque->members()->findOrFail($data['member_id']);
        $this->service->transferOwnership($mosque, $request->attributes->get('membership'), $to);

        return response()->json(['ok' => true]);
    }

    private function present(MosqueMember $m, bool $withEmail): array
    {
        return [
            'id' => $m->id,
            'user_id' => $m->user_id,
            'name' => $m->user?->name,
            'email' => $withEmail ? $m->user?->email : null,
            'role' => $m->role,
            'status' => $m->status,
            'is_owner' => $m->is_owner,
            'activated_at' => $m->activated_at,
        ];
    }
}
