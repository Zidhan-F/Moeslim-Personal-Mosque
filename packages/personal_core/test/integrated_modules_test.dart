import 'package:personal_core/personal_core.dart';
import 'package:test/test.dart';

void main() {
  group('Moeslim Journal (lokal & privat)', () {
    test('PIN disimpan sebagai hash bersalt (bukan plaintext) dan migrasi PIN lama berjalan', () async {
      final store = InMemoryStore();
      await store.write('muhasabah_pin', '1234');
      final repo = JournalRepository(store);

      expect(await repo.hasPin(), isTrue);
      expect(await repo.verifyPin('9999'), isFalse);
      expect(await repo.verifyPin('1234'), isTrue);

      // Setelah verifikasi, PIN lama plaintext harus terhapus dan diganti hash bersalt.
      expect(await store.read('muhasabah_pin'), isNull);
      final rawHash = await store.read('moeslim_journal_pin_hash_v1');
      expect(rawHash, isNotNull);
      expect(rawHash!.contains(':'), isTrue);
      expect(rawHash.contains('1234'), isFalse);
    });

    test('entri, referensi ayat terpisah, draft autosave, arsip, soft-delete/restore, dan ekspor terenkripsi', () async {
      final store = InMemoryStore();
      final repo = JournalRepository(store);

      await repo.saveDraft(JournalDraft(
        kind: JournalEntryKind.ayah,
        title: 'Draft Tadabbur',
        body: 'Masih menulis...',
        updatedAt: DateTime(2026, 11, 24),
      ));
      expect((await repo.loadDraft())?.title, 'Draft Tadabbur');

      final entry = await repo.saveEntry(
        kind: JournalEntryKind.ayah,
        title: 'Tentang Kemudahan',
        body: 'Refleksi pribadi agar tetap tenang saat ujian.',
        tags: ['#sabar', 'ramadan'],
        sourceRef: 'QS. Al-Insyirah: 5-6',
        sourceExcerpt: 'Sesungguhnya bersama kesulitan ada kemudahan.',
      );
      expect(entry.tags, containsAll(['sabar', 'ramadan']));
      expect(entry.sourceExcerpt, 'Sesungguhnya bersama kesulitan ada kemudahan.');

      // Pencarian lokal
      expect(await repo.search(query: 'Insyirah'), hasLength(1));
      expect(await repo.search(tag: 'sabar'), hasLength(1));

      // Ekspor terenkripsi lokal (JRN-07) -> password salah ditolak, password benar memulihkan entri
      final encrypted = await repo.exportEncrypted('Rahasia2026!');
      expect(encrypted.contains('Refleksi pribadi'), isFalse);

      final store2 = InMemoryStore();
      final repo2 = JournalRepository(store2);
      expect(() => repo2.importEncrypted(encrypted, 'Salah123'), throwsFormatException);
      final count = await repo2.importEncrypted(encrypted, 'Rahasia2026!');
      expect(count, 1);
      expect((await repo2.allEntries()).first.title, 'Tentang Kemudahan');

      // Soft delete -> pulihkan -> arsipkan
      await repo.softDelete(entry.id);
      expect(await repo.allEntries(), isEmpty);
      expect(await repo.deletedEntries(), hasLength(1));
      await repo.restoreEntry(entry.id);
      expect(await repo.allEntries(), hasLength(1));
      await repo.setArchived(entry.id, true);
      expect(await repo.archivedEntries(), hasLength(1));
    });
  });

  group('Learning Path & Bahasa Arab (offline-first, tanpa 7 Naghom)', () {
    test('katalog memiliki 6 jalur resmi dan sama sekali tidak memuat Naghom', () {
      expect(learningPathCatalog.map((t) => t.id), ['arabic', 'quran', 'fiqih', 'hadith', 'sejarah', 'akhlak']);
      for (final track in learningPathCatalog) {
        expect(track.titleId.toLowerCase(), isNot(contains('naghom')));
        for (final lesson in track.lessons) {
          expect(lesson.titleId.toLowerCase(), isNot(contains('naghom')));
          expect(lesson.sourceRef, isNotEmpty);
        }
      }
    });

    test('kamus dua arah offline & spaced repetition Bahasa Arab bekerja lokal', () async {
      expect(searchArabicDictionary('مسجد'), isNotEmpty);
      expect(searchArabicDictionary('masjid'), isNotEmpty);
      expect(searchArabicDictionary('kasih sayang'), isNotEmpty);

      final store = InMemoryStore();
      var now = DateTime.utc(2026, 11, 24, 8, 0);
      final arabicRepo = ArabicStudyRepository(store, now: () => now);
      final st1 = await arabicRepo.recordReview('ar_masjid', quality: 5);
      expect(st1.repetitions, 1);
      expect(st1.intervalDays, 1);

      now = now.add(const Duration(days: 2));
      final st2 = await arabicRepo.recordReview('ar_masjid', quality: 5);
      expect(st2.repetitions, 2);
      expect(st2.intervalDays, 4);
    });

    test('hapus paket unduhan offline tidak menghapus progres belajar (LP-03)', () async {
      final repo = LearningPathRepository(InMemoryStore());
      await repo.saveLessonProgress('ar_l1_huruf', status: 'completed', bestScore: 1, totalQuestions: 1);
      await repo.setBundleInstalled('bundle_arabic_l1', false);

      final bundles = await repo.installedBundles();
      final prog = await repo.loadProgress();
      expect(bundles.contains('bundle_arabic_l1'), isFalse);
      expect(prog['ar_l1_huruf']?.isCompleted, isTrue);
    });
  });

  group('Moeslim Family lokal, offline queue & Community Cache', () {
    test('agenda offline antre sinkronisasi, deteksi konflik versi, dan profil anak tetap lokal', () async {
      final store = InMemoryStore();
      final fam = FamilySpaceRepository(store);
      await fam.saveSpace(const LocalFamilySpace(id: 'f1', name: 'Keluarga Budi', cloudFamilyId: 'cloud-1'));

      final id = FamilySpaceRepository.newUuidV4();
      await fam.upsertEvent(FamilyAgendaItem(
        id: id,
        title: 'Mengaji Sore (Offline)',
        startsAt: DateTime.utc(2026, 11, 25, 11, 0),
        version: 1,
        syncState: FamilySyncState.pendingSync,
      ));
      expect(await fam.pendingSyncEvents(), hasLength(1));

      // Server membawa versi 2 -> ditandai conflict (tidak menimpa diam-diam!)
      await fam.replaceFromCloudEvents([
        {
          'id': id,
          'title': 'Mengaji Sore (Diedit Ibu)',
          'starts_at': DateTime.utc(2026, 11, 25, 11, 0).toIso8601String(),
          'recurrence': 'none',
          'version': 2,
        },
      ]);
      final loaded = await fam.loadEvents();
      expect(loaded.first.syncState, FamilySyncState.conflict);
      expect(loaded.first.conflictServerTitle, 'Mengaji Sore (Diedit Ibu)');

      await fam.saveLocalChild(const LocalChildProfile(
        id: 'ch1',
        nickname: 'Aisyah',
        ageGroup: '7-9 tahun',
        learningLevel: 'L1 Huruf',
      ));
      expect(await fam.loadLocalChildren(), hasLength(1));
    });

    test('cache Ramadan Local & draft Services tersimpan lokal untuk mode offline', () async {
      final cache = CommunityCacheRepository(InMemoryStore());
      final ts = DateTime.utc(2026, 11, 24, 10, 0);
      await cache.saveRamadanCache('masjid-al-falah', [
        {'id': 1, 'title': 'Tarawih Malam 1', 'publication_status': 'published'},
      ], ts);
      final loaded = await cache.loadRamadanCache('masjid-al-falah');
      expect(loaded?.events, hasLength(1));
      expect(loaded?.syncedAt, ts);

      await cache.saveServiceDraft(ServiceRequestDraft(
        id: 'd1',
        mosqueSlug: 'masjid-al-falah',
        mosqueName: 'Masjid Al-Falah',
        definitionId: 'def1',
        serviceTitle: 'Pendaftaran TPQ',
        idempotencyKey: 'idem-1',
        answers: const {'nama_santri': 'Zaid'},
        updatedAt: ts,
      ));
      expect((await cache.loadServiceDrafts()).first.answers['nama_santri'], 'Zaid');
    });
  });
}
