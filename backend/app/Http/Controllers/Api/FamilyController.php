<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class FamilyController extends Controller
{
    private function member(Request $r, string $id, bool $admin = false): object
    {
        $m = DB::table('family_members')->where('family_id', $id)->where('user_id', $r->user()->id)->first();
        abort_unless($m, 404);
        abort_if($admin && $m->role !== 'admin', 403);
        return $m;
    }

    private function audit(Request $r, string $id, string $action): void
    {
        DB::table('family_audits')->insert(['family_id' => $id, 'actor_id' => $r->user()->id, 'action' => $action, 'created_at' => now()]);
    }

    public function index(Request $r)
    {
        return response()->json(['data' => DB::table('families')->whereIn('id', DB::table('family_members')->where('user_id', $r->user()->id)->select('family_id'))->get()]);
    }

    public function store(Request $r)
    {
        abort_unless($r->user()->email_verified_at, 403, 'Verifikasi email sebelum menghubungkan keluarga.');
        $data = $r->validate(['name' => 'required|string|max:100', 'timezone' => 'required|timezone']);
        $id = (string) Str::uuid();
        DB::transaction(function () use ($r, $data, $id) {
            DB::table('users')->where('id', $r->user()->id)->lockForUpdate()->first();
            abort_if(DB::table('families')->where('owner_user_id', $r->user()->id)->count() >= 5, 422, 'Batas ruang keluarga tercapai.');
            DB::table('families')->insert($data + ['id' => $id, 'owner_user_id' => $r->user()->id, 'created_at' => now(), 'updated_at' => now()]);
            DB::table('family_members')->insert(['family_id' => $id, 'user_id' => $r->user()->id, 'role' => 'admin', 'created_at' => now(), 'updated_at' => now()]);
            $this->audit($r, $id, 'family.created');
        });
        return response()->json(['data' => DB::table('families')->find($id)], 201);
    }

    public function show(Request $r, string $family)
    {
        $member = $this->member($r, $family);
        $eventsQuery = DB::table('family_events')->where('family_id', $family)->orderBy('starts_at');
        if (! $r->boolean('include_deleted')) {
            $eventsQuery->whereNull('deleted_at');
        }

        return response()->json(['data' => [
            'family' => DB::table('families')->find($family),
            'role' => $member->role,
            'members' => DB::table('family_members')
                ->join('users', 'users.id', '=', 'family_members.user_id')
                ->where('family_id', $family)
                ->get(['user_id', 'users.name', 'role', 'family_members.created_at as joined_at']),
            'events' => $eventsQuery->get(),
            'goals' => DB::table('family_shared_goals')->where('family_id', $family)->orderBy('deadline')->get(),
            'invitations' => $member->role === 'admin'
                ? DB::table('family_invitations')
                    ->where('family_id', $family)
                    ->whereNull('revoked_at')
                    ->where('expires_at', '>', now())
                    ->get(['id', 'expires_at', 'max_uses', 'used_count', 'created_at'])
                : [],
        ]]);
    }

    public function saveGoal(Request $r, string $family)
    {
        $this->member($r, $family, true);
        $data = $r->validate([
            'id' => 'nullable|uuid',
            'learning_path' => 'required|string|max:80',
            'title' => 'required|string|max:150',
            'target_description' => 'nullable|string|max:255',
            'deadline' => 'nullable|date',
            'completed' => 'sometimes|boolean',
        ]);
        $id = $data['id'] ?? (string) Str::uuid();
        $existing = DB::table('family_shared_goals')->where('id', $id)->first();
        abort_if($existing && $existing->family_id !== $family, 404);

        $row = [
            'learning_path' => $data['learning_path'],
            'title' => $data['title'],
            'target_description' => $data['target_description'] ?? null,
            'deadline' => $data['deadline'] ?? null,
            'completed_at' => ($data['completed'] ?? false) ? now() : null,
            'updated_at' => now(),
        ];
        if ($existing) {
            DB::table('family_shared_goals')->where('id', $id)->update($row);
        } else {
            DB::table('family_shared_goals')->insert($row + [
                'id' => $id,
                'family_id' => $family,
                'created_by' => $r->user()->id,
                'visibility' => 'members',
                'created_at' => now(),
            ]);
            $this->audit($r, $family, 'goal.created');
        }

        return response()->json(['data' => DB::table('family_shared_goals')->find($id)], $existing ? 200 : 201);
    }

    public function deleteGoal(Request $r, string $family, string $goal)
    {
        $this->member($r, $family, true);
        $deleted = DB::table('family_shared_goals')->where('family_id', $family)->where('id', $goal)->delete();
        abort_unless($deleted > 0, 404);
        $this->audit($r, $family, 'goal.deleted');

        return response()->noContent();
    }

    public function removeMember(Request $r, string $family, int $memberUserId)
    {
        $this->member($r, $family, true);
        abort_if($memberUserId === $r->user()->id, 422, 'Pemilik tidak dapat mengeluarkan dirinya sendiri.');
        $deleted = DB::table('family_members')
            ->where('family_id', $family)
            ->where('user_id', $memberUserId)
            ->where('role', '!=', 'admin')
            ->delete();
        abort_unless($deleted > 0, 404);
        $this->audit($r, $family, 'member.removed');

        return response()->noContent();
    }

    public function update(Request $r, string $family)
    {
        $this->member($r, $family, true);
        $data = $r->validate(['name' => 'required|string|max:100', 'timezone' => 'required|timezone']);
        DB::table('families')->where('id', $family)->update($data + ['updated_at' => now()]);
        return $this->show($r, $family);
    }

    public function invite(Request $r, string $family)
    {
        $this->member($r, $family, true);
        $token = Str::random(40);
        $id = (string) Str::uuid();
        DB::table('family_invitations')->insert(['id' => $id, 'family_id' => $family, 'token_hash' => hash('sha256', $token), 'expires_at' => now()->addDays(2), 'created_at' => now(), 'updated_at' => now()]);
        $this->audit($r, $family, 'invite.created');
        return response()->json(['data' => ['id' => $id, 'token' => $token, 'expires_at' => now()->addDays(2)->toIso8601String()]], 201);
    }

    public function revoke(Request $r, string $family, string $invite)
    {
        $this->member($r, $family, true);
        DB::table('family_invitations')->where('family_id', $family)->where('id', $invite)->update(['revoked_at' => now()]);
        $this->audit($r, $family, 'invite.revoked');
        return response()->noContent();
    }

    public function accept(Request $r)
    {
        abort_unless($r->user()->email_verified_at, 403, 'Verifikasi email terlebih dahulu.');
        $data = $r->validate(['token' => 'required|string|max:100']);
        $family = DB::transaction(function () use ($r, $data) {
            $invite = DB::table('family_invitations')->where('token_hash', hash('sha256', $data['token']))->lockForUpdate()->first();
            abort_unless($invite && !$invite->revoked_at && $invite->expires_at > now() && $invite->used_count < $invite->max_uses, 422, 'Undangan tidak berlaku.');
            DB::table('families')->where('id', $invite->family_id)->lockForUpdate()->first();
            $members = DB::table('family_members')->where('family_id', $invite->family_id);
            if ((clone $members)->where('user_id', $r->user()->id)->exists()) return $invite->family_id;
            abort_if($members->count() >= config('community.family_member_limit', 8), 422, 'Ruang keluarga penuh.');
            DB::table('family_members')->insert(['family_id' => $invite->family_id, 'user_id' => $r->user()->id, 'role' => 'member', 'created_at' => now(), 'updated_at' => now()]);
            DB::table('family_invitations')->where('id', $invite->id)->increment('used_count');
            $this->audit($r, $invite->family_id, 'member.joined');
            return $invite->family_id;
        });
        return response()->json(['data' => ['family_id' => $family]]);
    }

    public function saveEvent(Request $r, string $family, string $event)
    {
        $this->member($r, $family, true);
        abort_unless(Str::isUuid($event), 422);
        $data = $r->validate(['title' => 'required|string|max:150', 'starts_at' => 'required|date', 'location' => 'nullable|string|max:255', 'recurrence' => ['required', Rule::in(['none', 'daily', 'weekly'])], 'learning_path' => 'nullable|string|max:80', 'version' => 'required|integer|min:0', 'deleted' => 'sometimes|boolean']);
        $saved = DB::transaction(function () use ($r, $family, $event, $data) {
            DB::table('families')->where('id', $family)->lockForUpdate()->first();
            $this->member($r, $family, true);
            $old = DB::table('family_events')->where('id', $event)->first();
            abort_if($old && $old->family_id !== $family, 404);
            abort_if(($old?->version ?? 0) !== $data['version'], 409, 'Agenda telah berubah. Muat pembaruan sebelum menyimpan kembali.');
            $row = collect($data)->except(['version', 'deleted'])->all() + ['version' => $data['version'] + 1, 'deleted_at' => ($data['deleted'] ?? false) ? now() : null, 'updated_at' => now()];
            if ($old) DB::table('family_events')->where('id', $event)->update($row);
            else DB::table('family_events')->insert($row + ['id' => $event, 'family_id' => $family, 'created_by' => $r->user()->id, 'created_at' => now()]);
            return DB::table('family_events')->find($event);
        });
        return response()->json(['data' => $saved]);
    }

    public function leave(Request $r, string $family)
    {
        $m = $this->member($r, $family);
        abort_if($m->role === 'admin', 422, 'Pemilik perlu membubarkan ruang.');
        DB::transaction(function () use ($r, $family) {
            DB::table('families')->where('id', $family)->lockForUpdate()->first();
            DB::table('family_members')->where('family_id', $family)->where('user_id', $r->user()->id)->delete();
            $this->audit($r, $family, 'member.left');
        });
        return response()->noContent();
    }

    public function destroy(Request $r, string $family)
    {
        $this->member($r, $family, true);
        $data = $r->validate(['confirm_name' => 'required|string']);
        abort_unless(DB::table('families')->where('id', $family)->value('name') === $data['confirm_name'], 422);
        DB::table('families')->where('id', $family)->delete();
        return response()->noContent();
    }
}
