<?php

namespace Tests\Feature\Api;

use App\Models\Announcement;
use App\Models\Event;
use App\Models\InventoryItem;
use App\Models\Mosque;
use App\Models\User;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class OperationsTest extends TestCase
{
    private User $owner;

    private Mosque $mosque;

    protected function setUp(): void
    {
        parent::setUp();
        $this->owner = $this->verifiedUser();
        $this->mosque = $this->createMosque($this->owner);
        Sanctum::actingAs($this->owner);
    }

    private function url(string $p): string
    {
        return "/api/mosques/{$this->mosque->id}{$p}";
    }

    private function event(array $over = [])
    {
        return $this->postJson($this->url('/events'), $over + [
            'title' => 'Kajian Ahad Pagi',
            'category' => 'kajian',
            'speaker' => 'Ust. Fulan',
            'location' => 'Ruang utama',
            'starts_at' => '2026-12-06 06:00:00',
            'visibility' => 'public',
        ]);
    }

    public function test_event_crud_and_archive(): void
    {
        $id = $this->event()->assertCreated()->json('data.id');
        $this->patchJson($this->url("/events/{$id}"), ['title' => 'Kajian Tafsir'])->assertOk()
            ->assertJsonPath('data.title', 'Kajian Tafsir');
        $this->getJson($this->url('/events'))->assertOk()->assertJsonCount(1, 'data');
        $this->postJson($this->url("/events/{$id}/archive"))->assertOk()->assertJsonPath('data.status', 'archived');
        $this->getJson($this->url('/events'))->assertJsonCount(0, 'data');
        $this->getJson($this->url('/events?status=archived'))->assertJsonCount(1, 'data');
        $this->deleteJson($this->url("/events/{$id}"))->assertNoContent();
    }

    public function test_event_validation(): void
    {
        $this->event(['starts_at' => 'kemarin', 'category' => 'pesta', 'ends_at' => '2020-01-01'])
            ->assertUnprocessable()->assertJsonValidationErrors(['starts_at', 'category']);
    }

    public function test_announcements_and_active_content_limit(): void
    {
        $this->postJson($this->url('/announcements'), [
            'title' => 'Kerja bakti', 'body' => 'Ahad pukul 07.00', 'visibility' => 'public', 'priority' => 2,
        ])->assertCreated();

        // isi sampai batas
        $now = now();
        $rows = [];
        for ($i = 0; $i < Mosque::MAX_ACTIVE_CONTENT - 1; $i++) {
            $rows[] = ['mosque_id' => $this->mosque->id, 'title' => "E{$i}", 'category' => 'lainnya', 'starts_at' => $now,
                'visibility' => 'internal', 'status' => 'active', 'created_by' => $this->owner->id, 'created_at' => $now, 'updated_at' => $now];
        }
        Event::insert($rows);

        $this->event()->assertUnprocessable()->assertJsonPath('code', 'content_limit_reached');
        $this->postJson($this->url('/announcements'), ['title' => 'x', 'body' => 'y', 'visibility' => 'public'])
            ->assertUnprocessable();

        $first = Event::where('mosque_id', $this->mosque->id)->first();
        $this->postJson($this->url("/events/{$first->id}/archive"))->assertOk();
        $this->event()->assertCreated();
    }

    public function test_operator_can_only_toggle_display(): void
    {
        $id = $this->event()->json('data.id');
        $ann = $this->postJson($this->url('/announcements'), ['title' => 'a', 'body' => 'b', 'visibility' => 'public'])->json('data.id');
        $op = $this->addMember($this->mosque, 'operator');
        Sanctum::actingAs($op);

        $this->getJson($this->url('/events'))->assertOk();
        $this->event()->assertForbidden();
        $this->patchJson($this->url("/events/{$id}"), ['title' => 'x'])->assertForbidden();
        $this->patchJson($this->url("/events/{$id}/display"), ['show_on_display' => false])->assertOk()
            ->assertJsonPath('data.show_on_display', false);
        $this->patchJson($this->url("/announcements/{$ann}/display"), ['show_on_display' => false])->assertOk();
    }

    public function test_bendahara_cannot_write_events(): void
    {
        $b = $this->addMember($this->mosque, 'bendahara');
        Sanctum::actingAs($b);
        $this->event()->assertForbidden();
        $this->getJson($this->url('/events'))->assertOk();
    }

    public function test_staff_assignments(): void
    {
        $member = $this->addMember($this->mosque, 'pengurus');
        $this->postJson($this->url('/staff-assignments'), [
            'duty_type' => 'imam', 'prayer' => 'maghrib', 'date' => '2026-12-01', 'user_id' => $member->id,
        ])->assertCreated()->assertJsonPath('data.name', $member->name);
        $this->postJson($this->url('/staff-assignments'), [
            'duty_type' => 'khatib', 'prayer' => 'jumat', 'date' => '2026-12-04', 'external_name' => 'KH. Ahmad',
        ])->assertCreated();
        $this->postJson($this->url('/staff-assignments'), ['duty_type' => 'imam', 'date' => '2026-12-01'])
            ->assertUnprocessable();

        // user bukan anggota masjid ini tidak boleh ditugaskan
        $stranger = $this->verifiedUser();
        $this->postJson($this->url('/staff-assignments'), [
            'duty_type' => 'muadzin', 'date' => '2026-12-01', 'user_id' => $stranger->id,
        ])->assertUnprocessable();

        $this->getJson($this->url('/staff-assignments?from=2026-12-01&to=2026-12-07'))->assertOk()->assertJsonCount(2, 'data');
        $sid = $this->getJson($this->url('/staff-assignments?from=2026-12-01&to=2026-12-07'))->json('data.0.id');
        $this->patchJson($this->url("/staff-assignments/{$sid}"), ['notes' => 'Ganti'])->assertOk()->assertJsonPath('data.notes', 'Ganti');
        $this->deleteJson($this->url("/staff-assignments/{$sid}"))->assertNoContent();
    }

    public function test_inventory_crud_limit_and_maintenance(): void
    {
        $id = $this->postJson($this->url('/inventory'), [
            'name' => 'Sound system', 'quantity' => 1, 'condition' => 'baik', 'location' => 'Mimbar',
        ])->assertCreated()->json('data.id');
        $this->postJson($this->url("/inventory/{$id}/maintenance"), ['date' => '2026-11-10', 'notes' => 'Ganti kabel', 'cost' => 75000])
            ->assertCreated();
        $this->getJson($this->url("/inventory/{$id}"))->assertOk()->assertJsonCount(1, 'data.maintenance');
        $this->patchJson($this->url("/inventory/{$id}"), ['condition' => 'rusak_ringan'])->assertOk()->assertJsonPath('data.condition', 'rusak_ringan');

        $now = now();
        $rows = [];
        for ($i = 1; $i < Mosque::MAX_INVENTORY_ITEMS; $i++) {
            $rows[] = ['mosque_id' => $this->mosque->id, 'name' => "I{$i}", 'quantity' => 1, 'condition' => 'baik', 'created_at' => $now, 'updated_at' => $now];
        }
        foreach (array_chunk($rows, 1000) as $chunk) {
            InventoryItem::insert($chunk);
        }
        $this->postJson($this->url('/inventory'), ['name' => 'X', 'quantity' => 1, 'condition' => 'baik'])
            ->assertUnprocessable()->assertJsonPath('code', 'inventory_limit_reached');
    }

    public function test_cross_tenant_content_is_404(): void
    {
        $id = $this->event()->json('data.id');
        $other = $this->createMosque();
        Sanctum::actingAs($other->members()->first()->user);
        $this->patchJson("/api/mosques/{$other->id}/events/{$id}", ['title' => 'x'])->assertNotFound();
        $this->assertSame(0, Announcement::count());
    }
}
