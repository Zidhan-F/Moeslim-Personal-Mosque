<?php

namespace Tests\Feature\Api;

use App\Models\AuditLog;
use App\Models\MosqueMember;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class TenancyAndMembersTest extends TestCase
{
    public function test_non_member_gets_404_on_other_tenant(): void
    {
        $a = $this->createMosque();
        $outsider = $this->verifiedUser();
        $this->createMosque($outsider);

        Sanctum::actingAs($outsider);
        $this->getJson("/api/mosques/{$a->id}")->assertNotFound();
        $this->patchJson("/api/mosques/{$a->id}", ['name' => 'Hack'])->assertNotFound();
        $this->getJson("/api/mosques/{$a->id}/members")->assertNotFound();
    }

    public function test_inactive_member_loses_access(): void
    {
        $m = $this->createMosque();
        $u = $this->addMember($m, 'pengurus');
        $m->members()->where('user_id', $u->id)->update(['status' => 'inactive']);
        Sanctum::actingAs($u);
        $this->getJson("/api/mosques/{$m->id}")->assertNotFound();
    }

    public function test_only_admin_can_update_profile_and_settings_are_whitelisted(): void
    {
        $owner = $this->verifiedUser();
        $m = $this->createMosque($owner);
        $bendahara = $this->addMember($m, 'bendahara');

        Sanctum::actingAs($bendahara);
        $this->patchJson("/api/mosques/{$m->id}", ['name' => 'Baru'])->assertForbidden();

        Sanctum::actingAs($owner);
        $this->patchJson("/api/mosques/{$m->id}", [
            'name' => 'Masjid Baru',
            'settings' => ['display_show_finance' => true, 'evil' => 1, 'iqamah_minutes' => ['fajr' => 15]],
        ])->assertOk()
            ->assertJsonPath('data.name', 'Masjid Baru')
            ->assertJsonPath('data.settings.display_show_finance', true)
            ->assertJsonPath('data.settings.iqamah_minutes.fajr', 15)
            ->assertJsonPath('data.settings.iqamah_minutes.maghrib', 5)
            ->assertJsonMissingPath('data.settings.evil');
    }

    public function test_invite_and_accept_flow(): void
    {
        $owner = $this->verifiedUser();
        $m = $this->createMosque($owner);
        $invitee = $this->verifiedUser(['email' => 'bendahara@example.test']);

        Sanctum::actingAs($owner);
        $token = $this->postJson("/api/mosques/{$m->id}/members/invite", [
            'email' => 'bendahara@example.test', 'role' => 'bendahara',
        ])->assertCreated()->json('data.token');

        // email lain tidak boleh memakai undangan
        Sanctum::actingAs($this->verifiedUser());
        $this->postJson('/api/invitations/accept', ['token' => $token])->assertForbidden();

        Sanctum::actingAs($invitee);
        $this->postJson('/api/invitations/accept', ['token' => $token])->assertOk()
            ->assertJsonPath('data.role', 'bendahara');
        $this->postJson('/api/invitations/accept', ['token' => $token])->assertNotFound();

        $this->assertTrue(AuditLog::where('action', 'member.invited')->exists());
        $this->assertTrue(AuditLog::where('action', 'member.joined')->exists());
    }

    public function test_sixth_active_member_is_rejected(): void
    {
        $owner = $this->verifiedUser();
        $m = $this->createMosque($owner);
        foreach (['bendahara', 'pengurus', 'operator', 'pengurus'] as $role) {
            $this->addMember($m, $role);
        }
        Sanctum::actingAs($owner);
        $this->postJson("/api/mosques/{$m->id}/members/invite", ['email' => 'x@example.test', 'role' => 'pengurus'])
            ->assertUnprocessable()->assertJsonPath('code', 'member_limit_reached');
    }

    public function test_pending_invites_count_towards_limit_and_accept_rechecks(): void
    {
        $owner = $this->verifiedUser();
        $m = $this->createMosque($owner);
        foreach (['bendahara', 'pengurus', 'operator'] as $role) {
            $this->addMember($m, $role);
        }
        Sanctum::actingAs($owner);
        $this->postJson("/api/mosques/{$m->id}/members/invite", ['email' => 'a@example.test', 'role' => 'pengurus'])->assertCreated();
        $this->postJson("/api/mosques/{$m->id}/members/invite", ['email' => 'b@example.test', 'role' => 'pengurus'])
            ->assertUnprocessable();

        // mencabut undangan membebaskan slot
        $inv = $this->getJson("/api/mosques/{$m->id}/members")->json('invitations.0.id');
        $this->deleteJson("/api/mosques/{$m->id}/invitations/{$inv}")->assertOk();
        $this->postJson("/api/mosques/{$m->id}/members/invite", ['email' => 'b@example.test', 'role' => 'pengurus'])->assertCreated();
    }

    public function test_deactivate_frees_slot_but_rotation_is_limited(): void
    {
        $owner = $this->verifiedUser();
        $m = $this->createMosque($owner);
        $ids = [];
        foreach (range(1, 4) as $i) {
            $u = $this->addMember($m, 'pengurus');
            $ids[] = $m->members()->where('user_id', $u->id)->value('id');
        }
        Sanctum::actingAs($owner);
        foreach (array_slice($ids, 0, 3) as $id) {
            $this->postJson("/api/mosques/{$m->id}/members/{$id}/deactivate")->assertOk();
        }
        $this->postJson("/api/mosques/{$m->id}/members/{$ids[3]}/deactivate")
            ->assertUnprocessable()->assertJsonPath('code', 'rotation_limit_reached');

        // reaktivasi mengisi slot kembali
        $this->postJson("/api/mosques/{$m->id}/members/{$ids[0]}/reactivate")->assertOk();
        $this->assertSame(3, $m->activeMembers()->count());
    }

    public function test_last_admin_cannot_be_deactivated_or_demoted(): void
    {
        $owner = $this->verifiedUser();
        $m = $this->createMosque($owner);
        $memberId = $m->members()->where('user_id', $owner->id)->value('id');
        Sanctum::actingAs($owner);
        $this->postJson("/api/mosques/{$m->id}/members/{$memberId}/deactivate")
            ->assertUnprocessable()->assertJsonPath('code', 'last_admin');
        $this->patchJson("/api/mosques/{$m->id}/members/{$memberId}", ['role' => 'pengurus'])
            ->assertUnprocessable()->assertJsonPath('code', 'last_admin');
    }

    public function test_role_change_is_audited_and_member_of_other_tenant_is_404(): void
    {
        $owner = $this->verifiedUser();
        $m = $this->createMosque($owner);
        $other = $this->createMosque();
        $u = $this->addMember($other, 'pengurus');
        $foreignId = $other->members()->where('user_id', $u->id)->value('id');

        Sanctum::actingAs($owner);
        $this->patchJson("/api/mosques/{$m->id}/members/{$foreignId}", ['role' => 'admin'])->assertNotFound();

        $mine = $this->addMember($m, 'pengurus');
        $id = $m->members()->where('user_id', $mine->id)->value('id');
        $this->patchJson("/api/mosques/{$m->id}/members/{$id}", ['role' => 'bendahara'])->assertOk();
        $this->assertSame('bendahara', MosqueMember::find($id)->role);
        $log = AuditLog::where('action', 'member.role_changed')->first();
        $this->assertEquals(['from' => 'pengurus', 'to' => 'bendahara'], $log->summary);
    }

    public function test_non_admin_cannot_manage_members(): void
    {
        $m = $this->createMosque();
        $p = $this->addMember($m, 'pengurus');
        Sanctum::actingAs($p);
        $this->getJson("/api/mosques/{$m->id}/members")->assertOk();
        $this->postJson("/api/mosques/{$m->id}/members/invite", ['email' => 'z@example.test', 'role' => 'admin'])
            ->assertForbidden();
    }

    public function test_audit_log_visibility_by_role(): void
    {
        $owner = $this->verifiedUser();
        $m = $this->createMosque($owner);
        $op = $this->addMember($m, 'operator');
        $bend = $this->addMember($m, 'bendahara');
        Sanctum::actingAs($owner);
        $this->postJson("/api/mosques/{$m->id}/members/invite", ['email' => 'q@example.test', 'role' => 'pengurus']);
        $this->getJson("/api/mosques/{$m->id}/audit-logs")->assertOk()->assertJsonPath('data.0.action', 'member.invited');

        Sanctum::actingAs($bend);
        $this->getJson("/api/mosques/{$m->id}/audit-logs")->assertOk()->assertJsonCount(0, 'data');
        Sanctum::actingAs($op);
        $this->getJson("/api/mosques/{$m->id}/audit-logs")->assertForbidden();
    }

    public function test_transfer_ownership(): void
    {
        $owner = $this->verifiedUser();
        $m = $this->createMosque($owner);
        $u = $this->addMember($m, 'admin');
        $id = $m->members()->where('user_id', $u->id)->value('id');
        Sanctum::actingAs($owner);
        $this->postJson("/api/mosques/{$m->id}/transfer-ownership", ['member_id' => $id])->assertOk();
        $this->assertTrue(MosqueMember::find($id)->is_owner);
        $this->assertFalse($m->members()->where('user_id', $owner->id)->first()->is_owner);
    }
}
