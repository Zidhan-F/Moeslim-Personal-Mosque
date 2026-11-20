<?php

namespace App\Services;

use App\Exceptions\DomainRuleException;
use App\Models\AuditLog;
use App\Models\Mosque;
use App\Models\MosqueInvitation;
use App\Models\MosqueMember;
use App\Models\User;
use App\Support\Audit;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MemberService
{
    /** Maksimal penonaktifan (pembebasan slot) per 30 hari, mencegah rotasi akun. */
    public const MAX_DEACTIVATIONS_PER_30_DAYS = 3;

    public const INVITATION_DAYS = 7;

    /** @return array{0: MosqueInvitation, 1: string} undangan dan token mentah (hanya ditampilkan sekali) */
    public function invite(Mosque $mosque, User $by, string $email, string $role): array
    {
        return DB::transaction(function () use ($mosque, $by, $email, $role) {
            Mosque::whereKey($mosque->id)->lockForUpdate()->first();
            $email = Str::lower($email);

            $existing = $mosque->members()->whereHas('user', fn ($q) => $q->whereRaw('lower(email) = ?', [$email]))->first();
            if ($existing?->status === 'active') {
                throw new DomainRuleException('already_member', 'Pengguna ini sudah menjadi pengurus aktif.');
            }

            // Undangan lama untuk email yang sama digantikan.
            MosqueInvitation::where('mosque_id', $mosque->id)->where('email', $email)->pending()->delete();

            $pending = MosqueInvitation::where('mosque_id', $mosque->id)->pending()->count();
            if ($mosque->activeMembers()->count() + $pending >= Mosque::MAX_ACTIVE_MEMBERS) {
                throw new DomainRuleException('member_limit_reached', 'Batas 5 pengurus aktif (termasuk undangan tertunda) telah tercapai.');
            }

            $token = Str::random(48);
            $invitation = MosqueInvitation::create([
                'mosque_id' => $mosque->id,
                'email' => $email,
                'role' => $role,
                'token_hash' => hash('sha256', $token),
                'invited_by' => $by->id,
                'expires_at' => now()->addDays(self::INVITATION_DAYS),
            ]);
            Audit::log($mosque, 'member.invited', $invitation, ['email' => $email, 'role' => $role]);

            return [$invitation, $token];
        });
    }

    public function accept(User $user, string $token): MosqueMember
    {
        return DB::transaction(function () use ($user, $token) {
            $invitation = MosqueInvitation::where('token_hash', hash('sha256', $token))->pending()->lockForUpdate()->first();
            abort_if($invitation === null, 404, 'Undangan tidak ditemukan atau kedaluwarsa.');
            abort_if(Str::lower($user->email) !== $invitation->email, 403, 'Undangan ini untuk email lain.');
            abort_if($user->email_verified_at === null, 403, 'Verifikasi email terlebih dahulu.');

            $mosque = Mosque::whereKey($invitation->mosque_id)->lockForUpdate()->firstOrFail();
            if ($mosque->activeMembers()->count() >= Mosque::MAX_ACTIVE_MEMBERS) {
                throw new DomainRuleException('member_limit_reached', 'Batas 5 pengurus aktif telah tercapai.');
            }

            $member = MosqueMember::updateOrCreate(
                ['mosque_id' => $mosque->id, 'user_id' => $user->id],
                [
                    'role' => $invitation->role,
                    'status' => 'active',
                    'invited_by' => $invitation->invited_by,
                    'activated_at' => now(),
                    'deactivated_at' => null,
                ]
            );
            $invitation->update(['accepted_at' => now()]);
            Audit::log($mosque, 'member.joined', $member, ['role' => $member->role]);

            return $member;
        });
    }

    public function changeRole(Mosque $mosque, MosqueMember $member, string $role): MosqueMember
    {
        return DB::transaction(function () use ($mosque, $member, $role) {
            Mosque::whereKey($mosque->id)->lockForUpdate()->first();
            if ($member->role === 'admin' && $role !== 'admin') {
                $this->guardLastAdmin($mosque, $member);
            }
            $from = $member->role;
            $member->update(['role' => $role]);
            Audit::log($mosque, 'member.role_changed', $member, ['from' => $from, 'to' => $role]);

            return $member;
        });
    }

    public function deactivate(Mosque $mosque, MosqueMember $member): MosqueMember
    {
        return DB::transaction(function () use ($mosque, $member) {
            Mosque::whereKey($mosque->id)->lockForUpdate()->first();
            if ($member->status !== 'active') {
                return $member;
            }
            if ($member->role === 'admin') {
                $this->guardLastAdmin($mosque, $member);
            }
            if ($member->is_owner) {
                throw new DomainRuleException('owner_cannot_be_deactivated', 'Pindahkan kepemilikan sebelum menonaktifkan pemilik.');
            }
            $recent = AuditLog::where('mosque_id', $mosque->id)
                ->where('action', 'member.deactivated')
                ->where('created_at', '>=', now()->subDays(30))
                ->count();
            if ($recent >= self::MAX_DEACTIVATIONS_PER_30_DAYS) {
                throw new DomainRuleException('rotation_limit_reached', 'Maksimal 3 penonaktifan pengurus per 30 hari.');
            }
            $member->update(['status' => 'inactive', 'deactivated_at' => now()]);
            // Cabut semua token akses aktif? Tidak: token tetap milik user (bisa anggota masjid lain);
            // middleware tenant menolak karena status tidak aktif.
            Audit::log($mosque, 'member.deactivated', $member);

            return $member;
        });
    }

    public function reactivate(Mosque $mosque, MosqueMember $member): MosqueMember
    {
        return DB::transaction(function () use ($mosque, $member) {
            Mosque::whereKey($mosque->id)->lockForUpdate()->first();
            if ($member->status === 'active') {
                return $member;
            }
            if ($mosque->activeMembers()->count() >= Mosque::MAX_ACTIVE_MEMBERS) {
                throw new DomainRuleException('member_limit_reached', 'Batas 5 pengurus aktif telah tercapai.');
            }
            $member->update(['status' => 'active', 'activated_at' => now(), 'deactivated_at' => null]);
            Audit::log($mosque, 'member.reactivated', $member);

            return $member;
        });
    }

    public function transferOwnership(Mosque $mosque, MosqueMember $from, MosqueMember $to): void
    {
        DB::transaction(function () use ($mosque, $from, $to) {
            abort_unless($from->is_owner, 403, 'Hanya pemilik yang dapat memindahkan kepemilikan.');
            if ($to->status !== 'active' || $to->role !== 'admin') {
                throw new DomainRuleException('invalid_new_owner', 'Pemilik baru harus admin aktif.');
            }
            $from->update(['is_owner' => false]);
            $to->update(['is_owner' => true]);
            Audit::log($mosque, 'member.ownership_transferred', $to, ['from_member' => $from->id]);
        });
    }

    private function guardLastAdmin(Mosque $mosque, MosqueMember $member): void
    {
        $otherAdmins = $mosque->activeMembers()->where('role', 'admin')->whereKeyNot($member->id)->count();
        if ($otherAdmins === 0) {
            throw new DomainRuleException('last_admin', 'Masjid harus memiliki minimal satu admin aktif.');
        }
    }
}
