<?php

namespace Tests\Feature\Api;

use App\Models\AuditLog;
use App\Models\Event;
use App\Models\Mosque;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class CommunityFeaturesTest extends TestCase
{
    private User $ownerA;

    private Mosque $mosqueA;

    private User $ownerB;

    private Mosque $mosqueB;

    protected function setUp(): void
    {
        parent::setUp();
        $this->ownerA = $this->verifiedUser();
        $this->mosqueA = $this->createMosque($this->ownerA, ['name' => 'Masjid Al-Falah']);
        $this->ownerB = $this->verifiedUser();
        $this->mosqueB = $this->createMosque($this->ownerB, ['name' => 'Masjid Baitussalam']);
    }

    // ── MOESLIM FAMILY CLOUD ────────────────────────────────────────────────

    public function test_family_lifecycle_invite_revocation_goals_conflict_and_isolation(): void
    {
        $admin = $this->verifiedUser(['name' => 'Ayah Ahmad']);
        $member = $this->verifiedUser(['name' => 'Ibu Fatimah']);
        $outsider = $this->verifiedUser(['name' => 'Orang Luar']);

        Sanctum::actingAs($admin);
        $famId = $this->postJson('/api/families', [
            'name' => 'Keluarga Ahmad',
            'timezone' => 'Asia/Jakarta',
        ])->assertCreated()->json('data.id');

        // Undangan valid & undangan yang dicabut (FAM-AC02)
        $inv1 = $this->postJson("/api/families/{$famId}/invites")->assertCreated()->json('data');
        $inv2 = $this->postJson("/api/families/{$famId}/invites")->assertCreated()->json('data');
        $this->deleteJson("/api/families/{$famId}/invites/{$inv2['id']}")->assertNoContent();

        // Agenda bersama + optimistik versi konflik 409 (FAM-05 / FAM-09)
        $eventId = (string) Str::uuid();
        $this->putJson("/api/families/{$famId}/events/{$eventId}", [
            'title' => 'Tadarus Ba\'da Maghrib',
            'starts_at' => now()->addDay()->toIso8601String(),
            'location' => 'Ruang Keluarga',
            'recurrence' => 'daily',
            'learning_path' => 'quran',
            'version' => 0,
        ])->assertOk()->assertJsonPath('data.version', 1);

        // Kirim ulang dengan version basi (0) -> harus 409 Conflict, tidak menimpa diam-diam!
        $this->putJson("/api/families/{$famId}/events/{$eventId}", [
            'title' => 'Tadarus Stale',
            'starts_at' => now()->addDay()->toIso8601String(),
            'recurrence' => 'daily',
            'version' => 0,
        ])->assertStatus(409);

        // Target belajar bersama tanpa ranking salat (FAM-06)
        $goalId = $this->postJson("/api/families/{$famId}/goals", [
            'learning_path' => 'arabic',
            'title' => 'Selesaikan Bahasa Arab L1 & L2',
            'target_description' => '15 menit bersama setiap akhir pekan',
            'deadline' => now()->addMonth()->toDateString(),
        ])->assertCreated()->json('data.id');
        $this->assertNotEmpty($goalId);

        // Anggota menerima undangan yang sudah dicabut -> ditolak 422
        Sanctum::actingAs($member);
        $this->postJson('/api/family-invites/accept', ['token' => $inv2['token']])->assertUnprocessable();

        // Anggota menerima undangan sah -> berhasil bergabung & bisa baca ruang keluarga
        $this->postJson('/api/family-invites/accept', ['token' => $inv1['token']])
            ->assertOk()->assertJsonPath('data.family_id', $famId);
        $this->getJson("/api/families/{$famId}")
            ->assertOk()
            ->assertJsonCount(2, 'data.members')
            ->assertJsonCount(1, 'data.events')
            ->assertJsonCount(1, 'data.goals');

        // Orang luar memanipulasi ID keluarga -> 404 (FAM-AC03)
        Sanctum::actingAs($outsider);
        $this->getJson("/api/families/{$famId}")->assertNotFound();

        // Anggota bisa keluar sendiri dan langsung kehilangan akses (FAM-10)
        Sanctum::actingAs($member);
        $this->postJson("/api/families/{$famId}/leave")->assertNoContent();
        $this->getJson("/api/families/{$famId}")->assertNotFound();

        // Admin bubarkan ruang wajib konfirmasi nama persis (FAM-01)
        Sanctum::actingAs($admin);
        $this->deleteJson("/api/families/{$famId}", ['confirm_name' => 'Salah'])->assertUnprocessable();
        $this->deleteJson("/api/families/{$famId}", ['confirm_name' => 'Keluarga Ahmad'])->assertNoContent();
    }

    // ── RAMADAN LOCAL & KELAS MASJID (LEARNING PATH) ────────────────────────

    public function test_ramadan_local_publication_atomic_quota_waitlist_and_classes(): void
    {
        Sanctum::actingAs($this->ownerA);

        // 1. Draft tidak muncul di API publik (RAM-AC01)
        $this->postJson("/api/mosques/{$this->mosqueA->id}/events", [
            'title' => 'Draft I\'tikaf Internal',
            'category' => 'ramadan',
            'starts_at' => now()->addDays(5)->toIso8601String(),
            'visibility' => 'public',
            'publication_status' => 'draft',
            'hijri_year' => 1448,
        ])->assertCreated();

        // 2. Kegiatan Ramadan published dengan kuota 1 dan waitlist aktif
        $itikafId = $this->postJson("/api/mosques/{$this->mosqueA->id}/events", [
            'title' => 'I\'tikaf 10 Malam Terakhir',
            'category' => 'ramadan',
            'location' => 'Ruang Utama',
            'speaker' => 'Ust. Salman',
            'starts_at' => now()->addDays(7)->toIso8601String(),
            'visibility' => 'public',
            'publication_status' => 'published',
            'hijri_year' => 1448,
            'registration_enabled' => true,
            'waitlist_enabled' => true,
            'capacity' => 1,
        ])->assertCreated()->json('data.id');

        // 3. Kegiatan Ramadan tanpa waitlist dengan kuota 1 (untuk uji RAM-AC04 ketat)
        $bukaId = $this->postJson("/api/mosques/{$this->mosqueA->id}/events", [
            'title' => 'Buka Puasa Bersama Kuota Terbatas',
            'category' => 'ramadan',
            'starts_at' => now()->addDays(3)->toIso8601String(),
            'visibility' => 'public',
            'publication_status' => 'published',
            'hijri_year' => 1448,
            'registration_enabled' => true,
            'waitlist_enabled' => false,
            'capacity' => 1,
        ])->assertCreated()->json('data.id');

        // 4. Kelas Bahasa Arab resmi masjid (Learning Path LP-08)
        $classId = $this->postJson("/api/mosques/{$this->mosqueA->id}/events", [
            'title' => 'Kelas Bahasa Arab Dasar (Nahwu & Sharaf)',
            'category' => 'pendidikan',
            'learning_path' => 'arabic',
            'speaker' => 'Ust. Zaid',
            'starts_at' => now()->addDays(4)->toIso8601String(),
            'visibility' => 'public',
            'publication_status' => 'published',
            'registration_enabled' => true,
            'capacity' => 25,
        ])->assertCreated()->json('data.id');

        // Publik Ramadan hanya menampilkan yang bukan draft (2 kegiatan, bukan 3) + isolasi masjid B (RAM-AC05)
        $this->app['auth']->forgetGuards();
        $this->getJson("/api/public/mosques/{$this->mosqueA->slug}/ramadan/events?hijri_year=1448")
            ->assertOk()
            ->assertJsonCount(2, 'data');
        $this->getJson("/api/public/mosques/{$this->mosqueB->slug}/ramadan/events?hijri_year=1448")
            ->assertOk()
            ->assertJsonCount(0, 'data');

        // Publik Kelas Masjid menampilkan kelas Bahasa Arab
        $this->getJson("/api/public/mosques/{$this->mosqueA->slug}/classes?learning_path=arabic")
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $classId);

        // Uji kuota atomik 1 kursi (RAM-AC04): jamaah 1 berhasil, jamaah 2 ditolak saat non-waitlist
        $j1 = $this->verifiedUser(['name' => 'Jamaah Satu']);
        $j2 = $this->verifiedUser(['name' => 'Jamaah Dua']);

        Sanctum::actingAs($j1);
        $this->postJson("/api/events/{$bukaId}/registrations")->assertCreated()->assertJsonPath('data.status', 'confirmed');
        $this->postJson("/api/events/{$itikafId}/registrations")->assertCreated()->assertJsonPath('data.status', 'confirmed');

        Sanctum::actingAs($j2);
        $this->postJson("/api/events/{$bukaId}/registrations")->assertUnprocessable()->assertJsonPath('code', 'event_full');
        // Pada i'tikaf ber-waitlist, jamaah 2 masuk waiting list
        $this->postJson("/api/events/{$itikafId}/registrations")->assertCreated()->assertJsonPath('data.status', 'waitlisted');

        // Jamaah 1 batal -> Jamaah 2 otomatis dipromosikan ke confirmed!
        Sanctum::actingAs($j1);
        $this->deleteJson("/api/events/{$itikafId}/registrations")->assertOk()->assertJsonPath('data.status', 'cancelled');

        Sanctum::actingAs($j2);
        $this->getJson('/api/me/registrations')->assertOk()
            ->assertJsonPath('data.0.status', 'confirmed');

        // Update agenda oleh pengurus menaikkan version & status updated (RAM-AC02)
        Sanctum::actingAs($this->ownerA);
        $this->patchJson("/api/mosques/{$this->mosqueA->id}/events/{$itikafId}", [
            'location' => 'Aula Lantai 2',
        ])->assertOk()
            ->assertJsonPath('data.version', 2)
            ->assertJsonPath('data.publication_status', 'updated');
    }

    // ── MOESLIM SERVICES (DUAL-SIDE, RBAC, IDEMPOTENCY, PRIVATE FILES) ──────

    public function test_services_workflow_rbac_idempotency_isolation_and_private_attachments(): void
    {
        Storage::fake('local');
        config(['filesystems.attachments_disk' => 'local']);

        // 1. Bendahara TIDAK otomatis mendapat akses Services (§8.5)
        $bendaharaA = $this->addMember($this->mosqueA, 'bendahara');
        Sanctum::actingAs($bendaharaA);
        $this->getJson("/api/mosques/{$this->mosqueA->id}/services")->assertForbidden();
        $this->getJson("/api/mosques/{$this->mosqueA->id}/service-requests")->assertForbidden();

        // 2. Pengurus / Admin Masjid A membuat layanan Pendaftaran TPQ
        $pengurusA = $this->addMember($this->mosqueA, 'pengurus');
        Sanctum::actingAs($pengurusA);
        $defId = $this->postJson("/api/mosques/{$this->mosqueA->id}/services", [
            'title' => 'Pendaftaran Santri TPQ 2026',
            'type' => 'tpq',
            'description' => 'Pendaftaran belajar membaca Al-Qur\'an untuk anak usia 6-12 tahun.',
            'privacy_notice' => 'Data santri dan nomor wali hanya digunakan pengurus TPQ masjid ini.',
            'fields' => [
                ['key' => 'nama_santri', 'label' => 'Nama Santri', 'type' => 'text', 'required' => true],
                ['key' => 'usia', 'label' => 'Usia (tahun)', 'type' => 'number', 'required' => true],
                ['key' => 'kelas', 'label' => 'Pilihan Waktu', 'type' => 'select', 'required' => true, 'options' => ['Sore 15:30', 'Maghrib 18:15']],
            ],
            'capacity' => 20,
            'active' => true,
            'retention_days' => 180,
        ])->assertCreated()->json('data.id');

        // 3. Katalog publik menampilkan layanan aktif Masjid A
        $this->app['auth']->forgetGuards();
        $this->getJson("/api/public/mosques/{$this->mosqueA->slug}/services")
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.title', 'Pendaftaran Santri TPQ 2026');

        // 4. Jamaah 1 mengirim permohonan dengan Idempotency-Key (SVC-AC03)
        $jamaah1 = $this->verifiedUser(['name' => 'Wali Santri 1']);
        $jamaah2 = $this->verifiedUser(['name' => 'Wali Santri 2']);
        Sanctum::actingAs($jamaah1);

        $first = $this->withHeader('Idempotency-Key', 'idem-tpq-001')
            ->postJson("/api/public/mosques/{$this->mosqueA->slug}/service-requests", [
                'service_definition_id' => $defId,
                'answers' => [
                    'nama_santri' => 'Aisyah',
                    'usia' => '8',
                    'kelas' => 'Sore 15:30',
                ],
            ])->assertCreated()->json('data');

        // Submit ulang dengan Idempotency-Key yang sama tidak membuat duplikat
        $dup = $this->withHeader('Idempotency-Key', 'idem-tpq-001')
            ->postJson("/api/public/mosques/{$this->mosqueA->slug}/service-requests", [
                'service_definition_id' => $defId,
                'answers' => [
                    'nama_santri' => 'Aisyah',
                    'usia' => '8',
                    'kelas' => 'Sore 15:30',
                ],
            ])->assertOk()->json('data');
        $this->assertSame($first['id'], $dup['id']);

        // 5. Lampiran privat hanya bisa diakses pemohon & pengurus berizin Masjid A (SVC-AC04)
        $file = UploadedFile::fake()->createWithContent('kk.pdf', '%PDF-1.4 dummy');
        $attId = $this->post("/api/me/service-requests/{$first['id']}/attachments", ['file' => $file])
            ->assertCreated()->json('data.id');
        $this->get("/api/service-attachments/{$attId}")->assertOk();

        // Jamaah 2 tidak bisa membaca permohonan maupun lampiran Jamaah 1 (SVC-AC01)
        Sanctum::actingAs($jamaah2);
        $this->getJson("/api/me/service-requests/{$first['id']}")->assertNotFound();
        $this->get("/api/service-attachments/{$attId}")->assertNotFound();

        // Pengurus Masjid B tidak bisa mengakses permohonan atau lampiran Masjid A (SVC-AC02)
        Sanctum::actingAs($this->ownerB);
        $this->getJson("/api/mosques/{$this->mosqueB->id}/service-requests/{$first['id']}")->assertNotFound();
        $this->get("/api/service-attachments/{$attId}")->assertNotFound();

        // Bendahara Masjid A juga tidak bisa mengunduh lampiran sensitif Services
        Sanctum::actingAs($bendaharaA);
        $this->get("/api/service-attachments/{$attId}")->assertNotFound();

        // 6. State machine & audit log (SVC-AC05): tidak boleh lompat submitted -> approved langsung
        Sanctum::actingAs($pengurusA);
        $this->get("/api/service-attachments/{$attId}")->assertOk();
        $this->patchJson("/api/mosques/{$this->mosqueA->id}/service-requests/{$first['id']}/status", [
            'status' => 'approved',
        ])->assertUnprocessable()->assertJsonPath('code', 'invalid_status_transition');

        // submitted -> under_review -> need_revision (wajib pesan) -> resubmitted (pemohon) -> approved -> completed -> closed
        $this->patchJson("/api/mosques/{$this->mosqueA->id}/service-requests/{$first['id']}/status", [
            'status' => 'under_review',
        ])->assertOk()->assertJsonPath('data.status', 'under_review');

        $this->patchJson("/api/mosques/{$this->mosqueA->id}/service-requests/{$first['id']}/status", [
            'status' => 'need_revision',
            'message' => 'Mohon lengkapi nama panggilan santri.',
        ])->assertOk()->assertJsonPath('data.status', 'need_revision');

        Sanctum::actingAs($jamaah1);
        $this->postJson("/api/me/service-requests/{$first['id']}/resubmit", [
            'answers' => [
                'nama_santri' => 'Aisyah Rahma',
                'usia' => '8',
                'kelas' => 'Sore 15:30',
            ],
            'message' => 'Sudah dilengkapi.',
        ])->assertOk()->assertJsonPath('data.status', 'resubmitted');

        Sanctum::actingAs($pengurusA);
        $this->patchJson("/api/mosques/{$this->mosqueA->id}/service-requests/{$first['id']}/status", [
            'status' => 'approved',
            'message' => 'Diterima masuk kelas sore.',
        ])->assertOk()->assertJsonPath('data.status', 'approved');

        $this->patchJson("/api/mosques/{$this->mosqueA->id}/service-requests/{$first['id']}/status", [
            'status' => 'completed',
        ])->assertOk()->assertJsonPath('data.status', 'completed');

        $this->assertTrue(
            AuditLog::where('mosque_id', $this->mosqueA->id)->where('action', 'service.request_status_updated')->exists()
        );

        // Export CSV operasional
        $this->get("/api/mosques/{$this->mosqueA->id}/services/{$defId}/export")->assertOk();
    }
}
