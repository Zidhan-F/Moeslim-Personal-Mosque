import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json; charset=utf-8'});

const adminPermissions = [
  'dashboard.view',
  'members.view',
  'members.manage',
  'finance.view',
  'finance.write',
  'finance.export',
  'events.view',
  'events.write',
  'events.display',
  'staff.view',
  'staff.write',
  'inventory.view',
  'inventory.write',
  'display.view',
  'display.manage',
  'audit.view',
  'mosque.update',
  'billing.manage',
  'zakat.view',
  'zakat.write',
  'qurban.view',
  'qurban.write',
  'services.view',
  'services.manage',
];

String _today() {
  final d = DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// Backend palsu Moeslim Mosque untuk widget test. [role]/[permissions] mengatur respons dashboard.
MockClient fakeMosqueBackend(
  List<http.Request> log, {
  String role = 'bendahara',
  List<String> permissions = const ['finance.view', 'finance.write', 'events.view'],
  List<String> warnings = const ['storage_warning'],
}) => MockClient((req) async {
  log.add(req);
  final p = req.url.path.replaceFirst('/api', '');
  final today = _today();
  switch ((req.method, p)) {
    case ('POST', '/auth/login'):
      final body = jsonDecode(req.body) as Map;
      return body['password'] == 'benar-sekali-123'
          ? json({'token': 't0k3n', 'user': {}})
          : json({
              'message': 'Email atau kata sandi salah.',
              'errors': {
                'email': ['Email atau kata sandi salah.'],
              },
            }, 422);
    case ('GET', '/me'):
      return json({
        'user': {'id': 1, 'name': 'Ahmad Fadli', 'email': 'b@x.id', 'email_verified': true},
        'memberships': [],
      });
    case ('GET', '/mosques'):
      return json({
        'data': [
          {'id': 'M1', 'name': 'Masjid Al-Ikhlas', 'role': role, 'city': 'Jakarta'},
        ],
      });
    case ('GET', '/mosques/M1/dashboard'):
      return json({
        'mosque': {
          'id': 'M1',
          'slug': 'masjid-al-ikhlas',
          'name': 'Masjid Al-Ikhlas',
          'city': 'Jakarta',
          'settings': {'public_show_finance': false},
        },
        'role': role,
        'permissions': permissions,
        'finance': permissions.contains('finance.view')
            ? {
                'balance': 250000,
                'month_in': 300000,
                'month_out': 50000,
                'funds': [
                  {'id': 1, 'name': 'Kas Operasional', 'balance': 250000, 'restricted': false},
                ],
              }
            : null,
        'subscription': {'state': 'trialing', 'price_idr': 59000, 'trial_ends_at': '2026-12-20T00:00:00Z'},
        'usage': {
          'members': {'used': 3, 'limit': 5},
          'displays': {'used': 1, 'limit': 5},
          'storage': {'used': 900 * 1024 * 1024, 'limit': 1024 * 1024 * 1024, 'level': 'warning'},
          'active_content': {'used': 4, 'limit': 500},
          'inventory': {'used': 2, 'limit': 5000},
          'transactions_this_month': {'used': 2, 'limit': 10000},
        },
        'warnings': warnings,
        'displays': {'active': 1, 'online': 1, 'devices': []},
        'staff_today': [
          {'duty_type': 'imam', 'prayer': 'maghrib', 'name': 'Ust. Fahri'},
        ],
        'upcoming_events': [
          {
            'id': 7,
            'title': 'Kajian Rutin Jumat',
            'category': 'kajian',
            'starts_at': '${today}T12:30:00Z',
            'visibility': 'public',
          },
        ],
        'active_announcements': 1,
      });
    case ('GET', '/mosques/M1/audit-logs'):
      return json({
        'data': [
          {'id': 1, 'action': 'event.created', 'created_at': '2026-11-19T10:00:00Z'},
        ],
      });
    case ('GET', '/mosques/M1/finance/summary'):
      return json({
        'total_in': 300000,
        'total_out': 50000,
        'net': 250000,
        'balance': 250000,
        'funds': [
          {'id': 1, 'name': 'Kas Operasional', 'balance': 250000, 'restricted': false},
        ],
        'accounts': [],
        'by_category': [
          {'flow': 'in', 'category': 'Infaq', 'total': 200000},
          {'flow': 'in', 'category': 'Zakat', 'total': 100000},
          {'flow': 'out', 'category': 'Listrik', 'total': 50000},
        ],
      });
    case ('GET', '/mosques/M1/finance/reports/monthly'):
      return json({
        'year': int.parse(req.url.queryParameters['year']!),
        'months': [
          for (var m = 1; m <= 12; m++) {'month': m, 'in': m * 10000, 'out': m * 4000},
        ],
      });
    case ('PATCH', '/mosques/M1'):
      return json({'data': jsonDecode(req.body)});
    case ('GET', '/mosques/M1/finance/friday-report'):
      return json({
        'mosque_name': 'Masjid Al-Ikhlas',
        'mosque_city': 'Jakarta',
        'from': '2026-11-14',
        'to': req.url.queryParameters['date'] ?? '2026-11-20',
        'opening_balance': 1000000,
        'total_in': 500000,
        'total_out': 150000,
        'net': 350000,
        'closing_balance': 1350000,
        'funds': [
          {'id': 1, 'name': 'Kas Operasional', 'balance': 1350000, 'restricted': false},
        ],
        'top_in': [
          {'date': '2026-11-20', 'description': 'Infaq Kotak Jumat', 'amount': 500000, 'fund_name': 'Kas Operasional'},
        ],
        'top_out': [
          {'date': '2026-11-18', 'description': 'Token Listrik', 'amount': 150000, 'fund_name': 'Kas Operasional'},
        ],
        'whatsapp_text': '*LAPORAN KAS JUMAT*\n*Masjid Al-Ikhlas*\nSaldo Akhir: Rp1.350.000',
      });
    case ('GET', '/mosques/M1/finance/donation-box-counts'):
      return json({
        'data': [
          {
            'id': 1,
            'date': today,
            'box_name': 'Kotak Amal Utama',
            'denominations': {'100000': 2, '50000': 3},
            'total_amount': 350000,
            'witness_1_name': 'H. Budi',
            'witness_2_name': 'Bpk. Slamet',
            'transaction': {'id': 11, 'reference_no': 'TX-11', 'amount': 350000, 'date': today, 'receipt_token': 'tok-11'},
          },
        ],
      });
    case ('POST', '/mosques/M1/finance/donation-box-counts'):
      final body = jsonDecode(req.body) as Map;
      return json({
        'data': {
          'id': 2,
          'date': body['date'],
          'box_name': body['box_name'],
          'denominations': body['denominations'],
          'total_amount': 250000,
          'witness_1_name': body['witness_1_name'],
          'witness_2_name': body['witness_2_name'],
          'transaction': {'id': 14, 'reference_no': 'TX-14', 'amount': 250000, 'date': body['date'], 'receipt_token': 'tok-14'},
        },
      }, 201);
    case ('GET', '/mosques/M1/finance/transactions/11/receipt'):
      return json({
        'data': {
          'receipt_no': 'TX-11',
          'receipt_token': 'tok-11',
          'verify_url': 'https://moeslim.id/verify/receipt/tok-11',
          'status': 'valid',
          'mosque_name': 'Masjid Al-Ikhlas',
          'mosque_city': 'Jakarta',
          'donor_name': 'H. Ahmad Fauzi',
          'amount': 200000,
          'fund_name': 'Kas Operasional',
          'account_name': 'Tunai',
          'date': today,
          'description': 'Infaq Jumat',
        },
      });
    case ('GET', '/mosques/M1/finance/transactions'):
      final flow = req.url.queryParameters['flow'];
      final all = [
        {
          'id': 11,
          'reference_no': 'TX-11',
          'flow': 'in',
          'amount': 200000,
          'date': today,
          'description': 'Infaq Jumat',
          'donor_name': 'H. Ahmad Fauzi',
          'receipt_token': 'tok-11',
          'category': {'id': 1, 'name': 'Infaq'},
          'fund': {'id': 1, 'name': 'Kas Operasional'},
          'account': {'id': 1, 'name': 'Tunai'},
          'reversal_of_id': null,
        },
        {
          'id': 12,
          'reference_no': 'TX-12',
          'flow': 'out',
          'amount': 50000,
          'date': today,
          'description': 'Bayar listrik',
          'category': {'id': 2, 'name': 'Listrik'},
          'fund': {'id': 1, 'name': 'Kas Operasional'},
          'account': {'id': 1, 'name': 'Tunai'},
          'reversal_of_id': null,
        },
      ];
      return json({'data': flow == null ? all : all.where((t) => t['flow'] == flow).toList()});
    case ('POST', '/mosques/M1/finance/transactions'):
      return json({
        'data': {'id': 1},
      }, 201);
    case ('POST', '/mosques/M1/finance/transactions/11/reverse'):
      return json({
        'data': {'id': 13},
      }, 201);
    case ('GET', '/mosques/M1/finance/setup'):
      return json({
        'funds': [
          {'id': 1, 'name': 'Kas Operasional', 'restricted': false},
        ],
        'accounts': [
          {'id': 1, 'name': 'Tunai'},
        ],
        'categories': [
          {'id': 1, 'name': 'Infaq', 'flow': 'in'},
          {'id': 2, 'name': 'Listrik', 'flow': 'out'},
        ],
      });
    case ('GET', '/mosques/M1/members'):
      return json({
        'data': [
          {
            'id': 1,
            'user_id': 1,
            'name': 'H. Ahmad Fadli',
            'email': 'a@x.id',
            'role': 'admin',
            'status': 'active',
            'is_owner': true,
          },
          {
            'id': 2,
            'user_id': 2,
            'name': 'Rizal Wicaksono',
            'email': 'r@x.id',
            'role': 'bendahara',
            'status': 'active',
            'is_owner': false,
          },
          {
            'id': 3,
            'user_id': 3,
            'name': 'Agus Setiawan',
            'email': 'g@x.id',
            'role': 'operator',
            'status': 'active',
            'is_owner': false,
          },
        ],
        'invitations': [],
        'limit': 5,
        'active_count': 3,
      });
    case ('POST', '/mosques/M1/members/invite'):
      return json({
        'data': {'id': 9, 'email': 'baru@x.id', 'role': 'pengurus', 'token': 'UNDANGAN-123'},
      }, 201);
    case ('PATCH', '/mosques/M1/members/2'):
      return json({'data': {}});
    case ('GET', '/mosques/M1/events'):
      return json({
        'data': [
          {
            'id': 7,
            'title': 'Kajian Rutin Jumat',
            'category': 'kajian',
            'starts_at': '${today}T12:30:00Z',
            'visibility': 'public',
            'location': 'Ruang Utama',
            'speaker': 'Ust. Basri',
            'show_on_display': true,
          },
        ],
      });
    case ('POST', '/mosques/M1/events'):
      return json({
        'data': {'id': 8},
      }, 201);
    case ('PATCH', '/mosques/M1/events/7/display'):
      return json({'data': {}});
    case ('GET', '/mosques/M1/staff-assignments'):
      return json({
        'data': [
          {
            'id': 1,
            'duty_type': 'imam',
            'prayer': 'maghrib',
            'date': today,
            'user_id': null,
            'name': 'Ust. Fahri Maulana',
          },
          {
            'id': 2,
            'duty_type': 'muadzin',
            'prayer': 'maghrib',
            'date': today,
            'user_id': null,
            'name': 'Rafi Hidayat',
          },
        ],
      });
    case ('POST', '/mosques/M1/staff-assignments'):
      return json({'data': {}}, 201);
    case ('GET', '/mosques/M1/inventory'):
      return json({
        'data': [
          {
            'id': 1,
            'code': 'INV-001',
            'name': 'Speaker Aktif',
            'quantity': 2,
            'condition': 'baik',
            'location': 'Ruang Utama',
          },
          {
            'id': 2,
            'code': 'INV-003',
            'name': 'AC 2 PK',
            'quantity': 2,
            'condition': 'rusak_ringan',
            'location': 'Aula',
          },
        ],
      });
    case ('GET', '/mosques/M1/inventory/1'):
      return json({
        'data': {
          'id': 1,
          'code': 'INV-001',
          'name': 'Speaker Aktif',
          'quantity': 2,
          'condition': 'baik',
          'location': 'Ruang Utama',
          'maintenance': [
            {'id': 1, 'date': '2026-10-02', 'notes': 'Ganti kabel', 'cost': 75000},
          ],
        },
      });
    case ('GET', '/mosques/M1/displays'):
      return json({
        'data': [
          {
            'id': 5,
            'name': 'Ruang Utama',
            'status': 'active',
            'last_seen_at': DateTime.now().toUtc().toIso8601String(),
            'config': {'theme': 'auto'},
          },
        ],
        'limit': 5,
        'mosque_settings': {
          'display_show_finance': false,
          'display_show_qris': false,
          'qris_label': 'Infaq Masjid',
          'iqamah_minutes': {'fajr': 10, 'dhuhr': 10, 'asr': 10, 'maghrib': 5, 'isha': 10},
          'praying_minutes': {'fajr': 15, 'dhuhr': 15, 'asr': 15, 'maghrib': 15, 'isha': 15, 'jumuah': 45},
          'silent_prayer_screen': true,
          'silent_prayer_message': 'Luruskan & Rapatkan Shaf • Harap Tenangkan Ponsel',
          'iqamah_beep': true,
        },
        'qris': {'has_image': false, 'enabled': false, 'label': 'Infaq Masjid'},
        'override': null,
      });
    case ('GET', '/mosques/M1/displays/preview'):
      return json({
        'data': {
          'mosque': {
            'id': 'M1',
            'name': 'Masjid Al-Ikhlas',
            'address': 'Jl. Merdeka 1',
            'city': 'Jakarta',
            'latitude': -6.2,
            'longitude': 106.8,
            'timezone': 'Asia/Jakarta',
            'prayer_method': 'kemenag',
            'settings': {
              'iqamah_minutes': {'fajr': 10, 'dhuhr': 10, 'asr': 10, 'maghrib': 5, 'isha': 10},
              'praying_minutes': {'fajr': 15, 'dhuhr': 15, 'asr': 15, 'maghrib': 15, 'isha': 15, 'jumuah': 45},
            },
          },
          'events': [
            {'id': 7, 'title': 'Kajian Ahad', 'category': 'kajian', 'starts_at': '2026-11-22T00:00:00Z'},
          ],
          'announcements': [
            {'id': 3, 'title': 'Kerja bakti', 'body': 'Ahad pagi', 'priority': 1},
          ],
          'staff_today': [
            {'duty_type': 'imam', 'prayer': 'maghrib', 'name': 'Ust. Ahmad'},
          ],
          'friday_staff': null,
          'finance': null,
          'qris': null,
          'override': null,
        },
        'server_time': '2026-11-20T03:00:00Z',
      });
    case ('PATCH', '/mosques/M1/displays/settings'):
      return json({'data': jsonDecode(req.body)});
    case ('POST', '/mosques/M1/displays/override'):
      return json({'data': jsonDecode(req.body)});
    case ('DELETE', '/mosques/M1/displays/override'):
      return json({'data': null});
    case ('DELETE', '/mosques/M1/displays/qris'):
      return json({'data': {'has_image': false, 'enabled': false}});
    case ('POST', '/mosques/M1/displays/pairing-codes'):
      return json({
        'data': {'code': '482913', 'expires_at': '2026-11-20T10:10:00Z'},
      }, 201);
    case ('POST', '/mosques/M1/displays/approve-session'):
      final body = jsonDecode(req.body) as Map;
      return json({
        'data': {
          'id': 6,
          'name': (body['name'] as String?)?.trim().isNotEmpty == true ? body['name'] : 'TV Display Web',
          'status': 'active',
          'config': <String, dynamic>{},
        },
      }, 201);
    case ('PATCH', '/mosques/M1/displays/5'):
      return json({'data': {}});
    case ('GET', '/mosques/M1/announcements'):
      return json({
        'data': [
          {
            'id': 3,
            'title': 'Kerja bakti',
            'body': 'Ahad pagi pukul 07.00',
            'visibility': 'public',
            'show_on_display': false,
            'status': 'active',
          },
        ],
      });
    case ('PATCH', '/mosques/M1/announcements/3/display'):
      return json({'data': {}});
    case ('GET', '/mosques/M1/zakat'):
      return json({
        'summary': {
          'total_collections': 1,
          'total_souls': 4,
          'total_money_in': 180000,
          'total_rice_in_kg': 0,
          'total_mustahik': 1,
          'distributed_mustahik': 0,
          'distributed_money': 0,
          'distributed_rice_kg': 0,
        },
        'collections': [
          {
            'id': 1,
            'type': 'fitrah_money',
            'hijri_year': 1447,
            'date': today,
            'muzakki_name': 'Keluarga Bpk. Hasan',
            'souls_count': 4,
            'money_amount': 180000,
            'rice_kg': 0,
          },
        ],
        'mustahiks': [
          {
            'id': 10,
            'hijri_year': 1447,
            'name': 'Mbah Suyono',
            'asnaf': 'fakir',
            'address': 'RT 03',
            'money_amount': 100000,
            'rice_kg': 3.5,
            'status': 'planned',
          },
        ],
      });
    case ('POST', '/mosques/M1/zakat/collections'):
      return json({'data': {'id': 2, ...jsonDecode(req.body) as Map}}, 201);
    case ('POST', '/mosques/M1/zakat/mustahiks'):
      return json({'data': {'id': 11, ...jsonDecode(req.body) as Map}}, 201);
    case ('POST', '/mosques/M1/zakat/mustahiks/10/distribute'):
      return json({'data': {'id': 10, 'status': 'distributed'}});
    case ('GET', '/mosques/M1/qurban/animals'):
      return json({
        'summary': {
          'total_animals': 1,
          'total_participants': 1,
          'total_meat_packs': 0,
          'slaughtered_count': 0,
        },
        'data': [
          {
            'id': 5,
            'hijri_year': 1447,
            'code': 'SAPI-01',
            'species': 'sapi',
            'capacity': 7,
            'used_shares': 1,
            'remaining_shares': 6,
            'weight_kg': 450,
            'price_idr': 24500000,
            'slaughter_status': 'registered',
            'meat_packs_count': 0,
            'participants': [
              {'id': 21, 'name': 'H. Rahman', 'shares': 1, 'amount_idr': 3500000, 'payment_status': 'paid', 'meat_taken': false},
            ],
          },
        ],
      });
    case ('POST', '/mosques/M1/qurban/animals'):
      return json({'data': {'id': 6, ...jsonDecode(req.body) as Map}}, 201);
    case ('PATCH', '/mosques/M1/qurban/animals/5'):
      return json({'data': {'id': 5, ...jsonDecode(req.body) as Map}});
    case ('POST', '/mosques/M1/qurban/animals/5/participants'):
      return json({'data': {'id': 22, ...jsonDecode(req.body) as Map}}, 201);
    case ('GET', '/mosques/M1/coupons'):
      return json({
        'summary': {'total': 1, 'issued': 1, 'redeemed': 0, 'void': 0},
        'data': [
          {
            'id': 31,
            'program': 'qurban',
            'hijri_year': 1447,
            'code': 'QBN-ABC123',
            'recipient_name': 'Warga RW 05 #1',
            'recipient_address': 'RW 05',
            'status': 'issued',
          },
        ],
      });
    case ('POST', '/mosques/M1/coupons'):
      return json({
        'data': [
          {'id': 32, 'code': 'QBN-NEW999', 'recipient_name': 'Warga Baru #1', 'status': 'issued'},
        ],
      }, 201);
    case ('POST', '/mosques/M1/coupons/redeem'):
      final code = (jsonDecode(req.body) as Map)['code'] as String;
      if (code == 'QBN-DUP') {
        return json({'code': 'coupon_already_redeemed', 'message': 'Kupon QBN-DUP sudah ditukarkan sebelumnya.'}, 422);
      }
      return json({'data': {'id': 31, 'code': code, 'recipient_name': 'Warga RW 05 #1', 'status': 'redeemed'}});
    case ('GET', '/public/mosques/masjid-al-ikhlas/ramadan/events'):
      return json({
        'mosque': {'id': 'M1', 'slug': 'masjid-al-ikhlas', 'name': 'Masjid Al-Ikhlas', 'timezone': 'Asia/Jakarta'},
        'synced_at': '${today}T08:00:00Z',
        'data': [
          {
            'id': 701,
            'title': 'Tarawih & Kultum Malam Pertama',
            'description': 'Shalat tarawih berjamaah 11 rakaat bersama imam masjid.',
            'category': 'ramadan',
            'location': 'Ruang Utama',
            'speaker': 'Ust. Salman',
            'starts_at': '${today}T12:30:00Z',
            'publication_status': 'updated',
            'hijri_year': 1447,
            'registration_enabled': true,
            'waitlist_enabled': true,
            'capacity': 100,
            'confirmed_count': 40,
            'waitlisted_count': 0,
            'remaining_seats': 60,
            'updated_at': '${today}T07:45:00Z',
          },
        ],
      });
    case ('GET', '/public/mosques/masjid-al-ikhlas/classes'):
      return json({
        'mosque': {'id': 'M1', 'slug': 'masjid-al-ikhlas', 'name': 'Masjid Al-Ikhlas', 'timezone': 'Asia/Jakarta'},
        'synced_at': '${today}T08:00:00Z',
        'data': [
          {
            'id': 702,
            'title': 'Kelas Bahasa Arab Dasar',
            'category': 'pendidikan',
            'learning_path': 'bahasa_arab',
            'speaker': 'Ust. Ridwan',
            'starts_at': '${today}T13:00:00Z',
            'publication_status': 'published',
            'registration_enabled': true,
            'capacity': 25,
            'remaining_seats': 10,
          },
        ],
      });
    case ('GET', '/me/registrations'):
      return json({'data': []});
    case ('POST', '/events/701/registrations'):
      return json({'data': {'id': 'reg-1', 'event_id': 701, 'status': 'confirmed'}}, 201);
    case ('DELETE', '/events/701/registrations'):
      return json({'data': {'id': 'reg-1', 'event_id': 701, 'status': 'cancelled'}});
    case ('GET', '/public/mosques/masjid-al-ikhlas/services'):
      return json({
        'mosque': {'id': 'M1', 'slug': 'masjid-al-ikhlas', 'name': 'Masjid Al-Ikhlas', 'city': 'Jakarta'},
        'data': [
          {
            'id': 'svc-def-1',
            'title': 'Pendaftaran TPQ Al-Ikhlas',
            'type': 'tpq',
            'description': 'Kelas baca tulis Al-Qur\'an untuk anak usia 6-12 tahun.',
            'privacy_notice': 'Data santri hanya diakses pengurus pendidikan Masjid Al-Ikhlas.',
            'fields': [
              {'key': 'nama_santri', 'label': 'Nama Santri', 'type': 'text', 'required': true},
              {'key': 'kontak_wali', 'label': 'Kontak Wali', 'type': 'text', 'required': true},
            ],
            'form_version': 1,
            'capacity': 30,
            'remaining_capacity': 12,
            'retention_days': 365,
          },
        ],
      });
    case ('POST', '/public/mosques/masjid-al-ikhlas/service-requests'):
      final body = jsonDecode(req.body) as Map;
      return json({
        'data': {
          'id': 'svc-req-1',
          'reference_no': 'SVC-2611-TEST01',
          'status': 'submitted',
          'answers': body['answers'],
          'definition': {'id': 'svc-def-1', 'title': 'Pendaftaran TPQ Al-Ikhlas', 'type': 'tpq'},
          'history': [
            {'status': 'submitted', 'message': 'Permohonan dikirim oleh pemohon.'},
          ],
        },
      }, 201);
    case ('GET', '/me/service-requests'):
      return json({
        'data': [
          {
            'id': 'svc-req-1',
            'reference_no': 'SVC-2611-TEST01',
            'status': 'submitted',
            'answers': {'nama_santri': 'Zaid', 'kontak_wali': '08123456789'},
            'definition': {
              'id': 'svc-def-1',
              'title': 'Pendaftaran TPQ Al-Ikhlas',
              'type': 'tpq',
              'mosque': {'slug': 'masjid-al-ikhlas', 'name': 'Masjid Al-Ikhlas'},
            },
            'history': [
              {'status': 'submitted', 'message': 'Permohonan dikirim oleh pemohon.'},
            ],
          },
        ],
      });
    case ('GET', '/mosques/M1/services'):
      return json({
        'data': [
          {
            'id': 'svc-def-1',
            'title': 'Pendaftaran TPQ Al-Ikhlas',
            'type': 'tpq',
            'description': 'Kelas baca tulis Al-Qur\'an anak.',
            'privacy_notice': 'Data hanya untuk pengurus pendidikan.',
            'active': true,
            'retention_days': 365,
            'total_requests_count': 1,
            'pending_requests_count': 1,
          },
        ],
      });
    case ('POST', '/mosques/M1/services'):
      return json({'data': {'id': 'svc-def-2', ...jsonDecode(req.body) as Map}}, 201);
    case ('PATCH', '/mosques/M1/services/svc-def-1'):
      return json({'data': {'id': 'svc-def-1', ...jsonDecode(req.body) as Map}});
    case ('GET', '/mosques/M1/service-requests'):
      return json({
        'data': [
          {
            'id': 'svc-req-1',
            'reference_no': 'SVC-2611-TEST01',
            'status': 'submitted',
            'created_at': '${today}T09:00:00Z',
            'answers': {'nama_santri': 'Zaid', 'kontak_wali': '08123456789'},
            'definition': {'id': 'svc-def-1', 'title': 'Pendaftaran TPQ Al-Ikhlas', 'type': 'tpq'},
            'user': {'id': 1, 'name': 'Ahmad Fadli', 'email': 'b@x.id'},
            'history': [
              {'status': 'submitted', 'message': 'Permohonan dikirim oleh pemohon.'},
            ],
          },
        ],
      });
    case ('PATCH', '/mosques/M1/service-requests/svc-req-1/status'):
      final body = jsonDecode(req.body) as Map;
      return json({
        'data': {
          'id': 'svc-req-1',
          'reference_no': 'SVC-2611-TEST01',
          'status': body['status'],
        },
      });
  }
  return json({'message': 'not found'}, 404);
});
