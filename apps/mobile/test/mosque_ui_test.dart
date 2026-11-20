import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:moeslim_mobile/features/masjid/agenda_page.dart';
import 'package:moeslim_mobile/features/masjid/finance_pages.dart';
import 'package:moeslim_mobile/features/masjid/mosque_shell.dart';
import 'package:moeslim_mobile/features/masjid/session.dart';

import 'fake_mosque_backend.dart';
import 'helpers.dart';

/// Masuk ke shell Mosque dengan token tersimpan (sudah login) lewat Profil → Fitur tambahan.
Future<List<http.Request>> openMosque(
  WidgetTester tester, {
  String role = 'admin',
  List<String> permissions = adminPermissions,
}) async {
  final log = <http.Request>[];
  await pumpApp(
    tester,
    client: fakeMosqueBackend(log, role: role, permissions: permissions, warnings: const []),
    tokens: MemoryTokenStore('t0k3n'),
  );
  await tester.tap(find.text('Profil').last);
  await tester.pump();
  await tester.scrollUntilVisible(
    find.byKey(const Key('masjid-entry')),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.byKey(const Key('masjid-entry')));
  await tester.pumpAndSettle();
  expect(find.byType(MasjidDashboardPage), findsOneWidget);
  return log;
}

Finder inShell(Finder f) => find.descendant(of: find.byType(MasjidDashboardPage), matching: f);

Future<void> tapVisible(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> openAccountMenu(WidgetTester tester, String key) async {
  await tester.tap(find.text('Akun').last);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.byKey(Key(key)), 200, scrollable: inShell(find.byType(Scrollable)).last);
  await tapVisible(tester, find.byKey(Key(key)));
}

void main() {
  testWidgets('admin: navigasi 5 tab, ringkasan 2×2, akses cepat & pengalih core', (tester) async {
    await openMosque(tester);
    for (final t in ['Beranda', 'Keuangan', 'Kegiatan', 'Petugas', 'Akun']) {
      expect(find.text(t), findsWidgets);
    }
    expect(find.byKey(const Key('mosque-banner')), findsOneWidget);
    expect(find.text('Masjid Al-Ikhlas'), findsOneWidget);
    expect(find.byKey(const Key('stat-kas')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('stat-pengurus')), matching: find.text('3/5')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('stat-tv')), matching: find.text('1/1')), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Ust. Fahri'), 200, scrollable: inShell(find.byType(Scrollable)).first);
    expect(find.text('Imam • Maghrib'), findsOneWidget);

    await tester.tap(find.byKey(const Key('core-switcher')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Moeslim Personal').last);
    await tester.pumpAndSettle();
    expect(find.byType(MasjidDashboardPage), findsNothing);
  });

  testWidgets('bendahara tidak melihat tab Kegiatan/Petugas tanpa izin', (tester) async {
    await openMosque(tester, role: 'bendahara', permissions: const ['dashboard.view', 'finance.view', 'finance.write']);
    expect(find.text('Keuangan'), findsWidgets);
    expect(find.text('Petugas'), findsNothing);
    expect(find.text('Kegiatan'), findsWidgets); // label kartu statistik tetap ada
    expect(find.byType(NavigationDestination), findsNWidgets(3));
  });

  testWidgets('keuangan: saldo dapat disembunyikan, donut kategori, riwayat & pembatalan', (tester) async {
    final log = await openMosque(tester);
    await tester.tap(find.text('Keuangan').last);
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('balance'))).data, contains('250.000'));
    await tester.tap(find.byKey(const Key('toggle-balance')));
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const Key('balance'))).data, 'Rp •••••••');
    await tester.scrollUntilVisible(
      find.byKey(const Key('category-donut')),
      200,
      scrollable: inShell(find.byType(Scrollable)).last,
    );
    expect(find.text('Infaq'), findsOneWidget);
    expect(find.text('66,7%'), findsOneWidget);

    await tapVisible(tester, find.byKey(const Key('open-history')));
    expect(find.byType(TransactionHistoryPage), findsOneWidget);
    expect(find.byKey(const Key('tx-11')), findsOneWidget);
    expect(find.text('Tercatat'), findsNWidgets(2));
    await tester.tap(find.byKey(const Key('flow-out')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tx-11')), findsNothing);
    expect(log.last.url.queryParameters['flow'], 'out');
    await tester.tap(find.byKey(const Key('flow-all')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tx-11')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Salah input');
    await tapVisible(tester, find.byKey(const Key('reverse-tx')));
    final rev = log.lastWhere((r) => r.url.path.endsWith('/reverse'));
    expect(jsonDecode(rev.body), {'reason': 'Salah input'});
  });

  testWidgets('tambah transaksi: tab Pemasukan/Pengeluaran/Transfer & Idempotency-Key', (tester) async {
    final log = await openMosque(tester);
    await tester.tap(find.text('Keuangan').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-transaction')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tab-Transfer')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tab-Pengeluaran')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('amount')), '50000');
    await tester.enterText(find.byKey(const Key('description')), 'Bayar listrik');
    await tapVisible(tester, find.byKey(const Key('save')));
    final post = log.lastWhere((r) => r.method == 'POST' && r.url.path.endsWith('/finance/transactions'));
    expect(post.headers['Idempotency-Key'], hasLength(32));
    expect(jsonDecode(post.body)['flow'], 'out');
    expect(find.byType(TransactionFormPage), findsNothing);
  });

  testWidgets('laporan: grafik bulanan & tombol ekspor CSV', (tester) async {
    await openMosque(tester);
    await openAccountMenu(tester, 'menu-report');
    expect(find.byKey(const Key('monthly-chart')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tab-Tahunan')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ringkasan ${DateTime.now().year}'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('export-csv')), 200, scrollable: find.byType(Scrollable).last);
    expect(find.byKey(const Key('export-csv')), findsOneWidget);
  });

  testWidgets('pengurus & role: lencana peran, ubah peran, undang dengan kode', (tester) async {
    final log = await openMosque(tester);
    await openAccountMenu(tester, 'menu-members');
    expect(find.text('Pengurus (3/5)'), findsOneWidget);
    expect(find.text('Operator TV'), findsWidgets);
    await tester.tap(find.byKey(const Key('member-menu-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jadikan Pengurus'));
    await tester.pumpAndSettle();
    expect(jsonDecode(log.lastWhere((r) => r.method == 'PATCH').body), {'role': 'pengurus'});

    await tester.tap(find.byKey(const Key('invite-member')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('invite-email')), 'baru@x.id');
    await tester.tap(find.byKey(const Key('send-invite')));
    await tester.pumpAndSettle();
    expect(find.text('UNDANGAN-123'), findsOneWidget);
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tab-Pengaturan Role')));
    await tester.pumpAndSettle();
    for (final r in ['admin', 'bendahara', 'pengurus', 'operator']) {
      expect(find.byKey(Key('role-$r')), findsOneWidget);
    }
  });

  testWidgets('agenda: kalender bertitik, agenda terdekat, tambah kegiatan', (tester) async {
    final log = await openMosque(tester);
    await tester.tap(find.text('Kegiatan').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-month')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('event-7')),
      200,
      scrollable: inShell(find.byType(Scrollable)).last,
    );
    expect(find.text('Kajian Rutin Jumat'), findsWidgets);

    await tester.tap(find.byKey(const Key('add-event')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('event-title')), 'Pengajian Muslimah');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-event')),
      200,
      scrollable: find.descendant(of: find.byType(EventFormPage), matching: find.byType(Scrollable)).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-event')));
    await tester.pumpAndSettle();
    final post = jsonDecode(log.lastWhere((r) => r.method == 'POST' && r.url.path.endsWith('/events')).body) as Map;
    expect(post['title'], 'Pengajian Muslimah');
    expect(post['show_on_display'], isTrue);
  });

  testWidgets('jadwal petugas: filter tugas & tambah petugas eksternal', (tester) async {
    final log = await openMosque(tester);
    await tester.tap(find.text('Petugas').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Ust. Fahri Maulana'),
      200,
      scrollable: inShell(find.byType(Scrollable)).last,
    );
    expect(find.text('Rafi Hidayat'), findsOneWidget);
    await tapVisible(tester, find.byKey(const Key('duty-imam')));
    await tester.scrollUntilVisible(
      find.text('Ust. Fahri Maulana'),
      200,
      scrollable: inShell(find.byType(Scrollable)).last,
    );
    expect(find.text('Rafi Hidayat'), findsNothing);

    final day = DateTime.now().day;
    await tapVisible(tester, find.byKey(Key('add-staff-$day')));
    await tester.enterText(find.byKey(const Key('staff-name')), 'Ust. Tamu');
    await tapVisible(tester, find.byKey(const Key('save-staff')));
    final body =
        jsonDecode(log.lastWhere((r) => r.method == 'POST' && r.url.path.endsWith('/staff-assignments')).body) as Map;
    expect(body['external_name'], 'Ust. Tamu');
    expect(body['duty_type'], 'imam');
  });

  testWidgets('inventaris: filter kondisi berjumlah & detail perawatan', (tester) async {
    await openMosque(tester);
    await openAccountMenu(tester, 'menu-inventory');
    expect(find.text('Semua (2)'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cond-rusak_ringan')));
    await tester.pumpAndSettle();
    expect(find.text('Speaker Aktif'), findsNothing);
    expect(find.text('AC 2 PK'), findsOneWidget);
    await tester.tap(find.byKey(const Key('cond-all')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('item-1')));
    await tester.pumpAndSettle();
    expect(find.text('Ganti kabel'), findsOneWidget);
    expect(find.text('Ruang Utama'), findsOneWidget);
  });

  testWidgets('konfigurasi TV: slot 1/5, kode pairing, ganti tema', (tester) async {
    final log = await openMosque(tester);
    await openAccountMenu(tester, 'menu-tv');
    expect(find.text('Screen Aktif (1 / 5)'), findsOneWidget);
    expect(find.byKey(const Key('screen-5')), findsOneWidget);
    expect(find.byKey(const Key('slot-4')), findsOneWidget);

    await tapVisible(tester, find.byKey(const Key('slot-1')));
    await tester.enterText(find.byKey(const Key('tv-name')), 'Serambi');
    await tester.tap(find.byKey(const Key('create-code')));
    await tester.pumpAndSettle();
    expect(find.text('482913'), findsOneWidget);
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.byKey(const Key('screen-5')));
    await tester.tap(find.byKey(const Key('theme-dark')));
    await tester.pumpAndSettle();
    expect(jsonDecode(log.lastWhere((r) => r.method == 'PATCH').body), {
      'config': {'theme': 'dark'},
    });
  });

  testWidgets('konten & pengumuman: sakelar tayang di TV', (tester) async {
    final log = await openMosque(tester);
    await openAccountMenu(tester, 'menu-announcements');
    await tester.tap(find.byKey(const Key('ann-display-3')));
    await tester.pumpAndSettle();
    expect(jsonDecode(log.lastWhere((r) => r.method == 'PATCH').body), {'show_on_display': true});
    await tester.tap(find.byKey(const Key('tab-Jadwal Tayang')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('event-display-7')));
    await tester.pumpAndSettle();
    expect(log.lastWhere((r) => r.method == 'PATCH').url.path, endsWith('/events/7/display'));
  });

  testWidgets('akun: langganan & pemakaian kuota hanya di Mosque', (tester) async {
    await openMosque(tester);
    await tester.tap(find.text('Akun').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('subscription-card')), findsOneWidget);
    expect(find.textContaining('59.000'), findsOneWidget);
    expect(find.text('Uji coba'), findsOneWidget);
    expect(find.text('3 / 5'), findsOneWidget);
    expect(find.textContaining('Moeslim Personal tetap gratis'), findsOneWidget);
  });
}
