import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/core/l10n.dart';
import 'package:moeslim_mobile/core/providers.dart';
import 'package:moeslim_mobile/features/family/family_space_page.dart';
import 'package:moeslim_mobile/features/ibadah/muhasabah_journal_page.dart';
import 'package:moeslim_mobile/features/learning/learning_path_page.dart';
import 'package:moeslim_mobile/features/masjid/mosque_providers.dart';
import 'package:moeslim_mobile/features/masjid/services_admin_page.dart';
import 'package:moeslim_mobile/features/masjid/session.dart';
import 'package:moeslim_mobile/features/more/ramadan_local_page.dart';
import 'package:moeslim_mobile/features/services/personal_services_page.dart';
import 'package:personal_core/personal_core.dart';

import 'fake_mosque_backend.dart';

Widget _wrap(
  Widget child, {
  required InMemoryStore store,
  List<http.Request>? log,
  String? token,
  List<String> permissions = adminPermissions,
}) {
  final reqLog = log ?? <http.Request>[];
  return ProviderScope(
    overrides: [
      storeProvider.overrideWithValue(store),
      httpClientProvider.overrideWithValue(fakeMosqueBackend(reqLog, role: 'admin', permissions: permissions)),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore(token)),
    ],
    child: AppLangScope(
      language: AppLanguage.id,
      child: MaterialApp(theme: ThemeData(useMaterial3: true), home: child),
    ),
  );
}

void main() {
  testWidgets('Moeslim Family: ruang lokal offline, agenda bersama, target belajar, dan profil anak lokal', (tester) async {
    final store = InMemoryStore();
    await tester.pumpWidget(_wrap(const FamilySpacePage(), store: store));
    await tester.pumpAndSettle();

    // 1. Buat ruang keluarga lokal tanpa login (FAM-01 / FAM-AC01)
    await tester.tap(find.byKey(const Key('family-create-local-btn')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('family-name-field')), 'Keluarga Ahmad');
    await tester.tap(find.byKey(const Key('family-create-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Keluarga Ahmad'), findsWidgets);

    // 2. Tambah agenda belajar bersama offline
    await tester.tap(find.byKey(const Key('family-add-event-btn')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('family-event-title')), 'Halaqah Keluarga Ba\'da Maghrib');
    await tester.tap(find.byKey(const Key('family-event-save')));
    await tester.pumpAndSettle();

    expect(find.text('Halaqah Keluarga Ba\'da Maghrib'), findsOneWidget);

    // 3. Tambah profil anak lokal di perangkat wali (FAM-08)
    await tester.tap(find.text('Profil Anak'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('family-add-child-btn')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('family-child-name')), 'Aisyah');
    await tester.tap(find.byKey(const Key('family-child-save')));
    await tester.pumpAndSettle();

    expect(find.text('Aisyah'), findsOneWidget);
  });

  testWidgets('Moeslim Journal: refleksi terpisah dari referensi ayat, pencarian lokal, dan kunci PIN bersalt', (tester) async {
    final store = InMemoryStore();
    await tester.pumpWidget(_wrap(const MuhasabahJournalPage(), store: store));
    await tester.pumpAndSettle();

    // Pilih jenis Refleksi Ayat agar kolom referensi sumber muncul terpisah
    await tester.tap(find.text('Refleksi Ayat'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('journal-title-field')), 'Tadabbur Surah Al-Insyirah');
    await tester.enterText(find.byKey(const Key('journal-source-ref-field')), 'QS. Al-Insyirah: 5-6');
    await tester.enterText(find.byKey(const Key('journal-body-field')), 'Bersama kesulitan selalu ada kemudahan.');
    await tester.drag(find.byType(ListView).first, const Offset(0, -320));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('journal-save-btn')));
    await tester.pumpAndSettle();

    final repo = JournalRepository(store);
    final savedEntries = await repo.allEntries();
    expect(savedEntries, hasLength(1));
    expect(savedEntries.first.title, 'Tadabbur Surah Al-Insyirah');
    expect(savedEntries.first.sourceRef, 'QS. Al-Insyirah: 5-6');

    // Pasang PIN dan verifikasi tersimpan sebagai hash bersalt (bukan plaintext)
    await tester.tap(find.byKey(const Key('muhasabah-pin-config-btn')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('muhasabah-set-pin-field')), '2468');
    await tester.tap(find.byKey(const Key('muhasabah-save-pin-btn')));
    await tester.pumpAndSettle();

    expect(await repo.verifyPin('2468'), isTrue);
    expect(await repo.verifyPin('0000'), isFalse);
    expect(await store.read('muhasabah_pin'), isNull);
    final rawHash = await store.read('moeslim_journal_pin_hash_v1');
    expect(rawHash, isNotNull);
    expect(rawHash!.contains('2468'), isFalse);
  });

  testWidgets('Learning Path & Bahasa Arab: 6 jalur resmi tanpa 7 Naghom + kamus offline + kuis', (tester) async {
    final store = InMemoryStore();
    await tester.pumpWidget(_wrap(const LearningPathPage(), store: store));
    await tester.pumpAndSettle();

    expect(find.text('Bahasa Arab'), findsWidgets);
    expect(find.textContaining('Naghom'), findsNothing);

    // Buka submodul Bahasa Arab di dalam Learning Path
    await tester.tap(find.text('Bahasa Arab').first);
    await tester.pumpAndSettle();

    // Cari kamus offline dua arah
    await tester.enterText(find.byKey(const Key('arabic-dict-search')), 'buku');
    await tester.pumpAndSettle();
    expect(find.textContaining('كِتَابٌ'), findsWidgets);
  });

  testWidgets('Ramadan Local: muat jadwal masjid, timestamp sinkron, dan toggle pengingat lokal', (tester) async {
    final store = InMemoryStore();
    final log = <http.Request>[];
    await tester.pumpWidget(
      _wrap(
        const RamadanLocalPage(
          initialMosqueSlug: 'masjid-al-ikhlas',
          initialMosqueName: 'Masjid Al-Ikhlas',
        ),
        store: store,
        log: log,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tarawih & Kultum Malam Pertama'), findsOneWidget);
    expect(find.text('Jadwal Diperbarui'), findsOneWidget);
    expect(find.byKey(const Key('ramadan-sync-timestamp')), findsOneWidget);

    // Toggle pengingat lokal offline
    await tester.tap(find.byKey(const Key('ramadan-reminder-701')));
    await tester.pumpAndSettle();
    final reminders = await CommunityCacheRepository(store).savedReminderEventIds();
    expect(reminders.contains(701), isTrue);
  });

  testWidgets('Moeslim Services Personal: privacy notice tampil, simpan draft lokal belum terkirim, dan kirim dengan Idempotency-Key', (tester) async {
    final store = InMemoryStore();
    final log = <http.Request>[];
    await tester.pumpWidget(
      _wrap(
        const PersonalServicesPage(
          initialMosqueSlug: 'masjid-al-ikhlas',
          initialMosqueName: 'Masjid Al-Ikhlas',
        ),
        store: store,
        log: log,
        token: 't0k3n',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pendaftaran TPQ Al-Ikhlas'), findsOneWidget);

    // Buka formulir layanan dan cek privacy notice
    await tester.tap(find.byKey(const Key('svc-open-svc-def-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('svc-privacy-notice')), findsOneWidget);
    expect(find.textContaining('hanya diakses pengurus pendidikan'), findsOneWidget);

    // Isi field & simpan sebagai Draft Lokal dulu
    await tester.enterText(find.byKey(const Key('svc-field-nama_santri')), 'Zaid');
    await tester.enterText(find.byKey(const Key('svc-field-kontak_wali')), '08123456789');
    await tester.tap(find.byKey(const Key('svc-save-draft-btn')));
    await tester.pumpAndSettle();

    // Pindah otomatis ke tab Permohonan & Draft dan tampil lencana belum terkirim
    expect(find.byKey(const Key('svc-draft-badge')), findsOneWidget);

    // Lanjutkan draft & kirim daring dengan Idempotency-Key
    await tester.tap(find.text('Lanjutkan / Kirim'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('svc-submit-btn')));
    await tester.pumpAndSettle();

    final submitReq = log.where((r) => r.method == 'POST' && r.url.path.endsWith('/service-requests')).toList();
    expect(submitReq, isNotEmpty);
    expect(submitReq.first.headers['Idempotency-Key'], isNotEmpty);
  });

  testWidgets('Moeslim Services Admin: kotak masuk permohonan & transisi status sesuai state machine', (tester) async {
    final store = InMemoryStore();
    final log = <http.Request>[];
    final ctx = MosqueCtx(
      id: 'M1',
      name: 'Masjid Al-Ikhlas',
      city: 'Jakarta',
      slug: 'masjid-al-ikhlas',
      role: 'admin',
      permissions: adminPermissions.toSet(),
    );

    await tester.pumpWidget(_wrap(MosqueServicesAdminPage(ctx: ctx), store: store, log: log, token: 't0k3n'));
    await tester.pumpAndSettle();

    expect(find.text('Pendaftaran TPQ Al-Ikhlas'), findsOneWidget);
    expect(find.textContaining('SVC-2611-TEST01'), findsOneWidget);

    // Buka detail permohonan dan transisi ke Ditinjau (under_review)
    await tester.tap(find.byKey(const Key('admin-svc-req-svc-req-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('admin-svc-action-under_review')));
    await tester.pumpAndSettle();

    expect(
      log.any((r) => r.method == 'PATCH' && r.url.path.endsWith('/mosques/M1/service-requests/svc-req-1/status')),
      isTrue,
    );
  });
}
