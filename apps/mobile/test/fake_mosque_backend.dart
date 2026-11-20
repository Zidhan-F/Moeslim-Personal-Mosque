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
        'mosque': {'id': 'M1', 'name': 'Masjid Al-Ikhlas', 'city': 'Jakarta'},
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
      });
    case ('POST', '/mosques/M1/displays/pairing-codes'):
      return json({
        'data': {'code': '482913', 'expires_at': '2026-11-20T10:10:00Z'},
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
  }
  return json({'message': 'not found'}, 404);
});
