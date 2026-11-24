import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_prayer/shared_prayer.dart';

class ApiException implements Exception {
  final int status;
  final String? code;
  final String message;
  final Map<String, dynamic> errors;

  const ApiException(this.status, this.message, {this.code, this.errors = const {}});

  bool get isUnauthorized => status == 401;

  @override
  String toString() => message;
}

/// Klien REST Moeslim Mosque. Base URL diatur saat build:
/// `--dart-define=API_BASE_URL=https://api.contoh.id/api`.
class MasjidApi {
  static const defaultBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000/api');

  final http.Client _client;
  final String baseUrl;
  String? token;
  AppLanguage lang;

  MasjidApi(this._client, {this.baseUrl = defaultBaseUrl, this.token, this.lang = AppLanguage.id});

  String _tr(String id, String en) => lang == AppLanguage.en ? en : id;

  static String newIdempotencyKey() {
    final r = Random.secure();
    return List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final req = http.Request(method, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        if (body != null) 'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if (baseUrl.contains('ngrok')) 'ngrok-skip-browser-warning': '1',
        ...?headers,
      });
    if (body != null) req.body = jsonEncode(body);

    final http.Response res;
    try {
      res = await () async {
        final streamed = await _client.send(req);
        return http.Response.fromStream(streamed);
      }().timeout(const Duration(seconds: 10));
    } catch (_) {
      throw ApiException(
        0,
        _tr(
          'Tidak dapat terhubung ke server. Pastikan server aktif dan koneksi internet tersedia.',
          'Unable to connect to the server. Make sure the server is online and check your internet connection.',
        ),
      );
    }
    dynamic decoded;
    try {
      decoded = res.body.isEmpty ? null : jsonDecode(res.body);
    } on FormatException {
      decoded = null; // mis. halaman HTML dari proxy
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isNotEmpty && decoded == null) {
        throw ApiException(res.statusCode, _tr('Respons server tidak valid.', 'Invalid server response.'));
      }
      return decoded;
    }

    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    final fallbackMessage = decoded == null && (res.statusCode == 404 || res.statusCode >= 502)
        ? _tr(
            'Server Moeslim Mosque sedang tidak aktif atau tidak dapat dijangkau (${res.statusCode}).',
            'Moeslim Mosque server is currently offline or unreachable (${res.statusCode}).',
          )
        : _tr('Terjadi kesalahan (${res.statusCode}).', 'An error occurred (${res.statusCode}).');
    throw ApiException(
      res.statusCode,
      (map['message'] as String?) ?? fallbackMessage,
      code: map['code'] as String?,
      errors: (map['errors'] as Map<String, dynamic>?) ?? const {},
    );
  }

  // Auth
  Future<String> login(String email, String password) async {
    final r = await _send(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password, 'device_name': 'moeslim-mobile'},
    );
    return token = r['token'] as String;
  }

  Future<String> register(String name, String email, String password) async {
    final r = await _send(
      'POST',
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'device_name': 'moeslim-mobile',
      },
    );
    return token = r['token'] as String;
  }

  Future<void> verifyEmail(String code) => _send('POST', '/auth/email/verify', body: {'code': code});
  Future<void> logout() => _send('POST', '/auth/logout');
  Future<Map<String, dynamic>> me() async => Map<String, dynamic>.from(await _send('GET', '/me') as Map);

  // Masjid
  Future<List<Map<String, dynamic>>> myMosques() async =>
      List<Map<String, dynamic>>.from((await _send('GET', '/mosques'))['data'] as List);

  Future<Map<String, dynamic>> registerMosque(Map<String, dynamic> data) async =>
      Map<String, dynamic>.from((await _send('POST', '/mosques', body: data))['data'] as Map);

  Future<Map<String, dynamic>> updateMosque(String mosqueId, Map<String, dynamic> data) async =>
      Map<String, dynamic>.from((await _send('PATCH', '/mosques/$mosqueId', body: data))['data'] as Map);

  Future<Map<String, dynamic>> dashboard(String mosqueId) async =>
      Map<String, dynamic>.from(await _send('GET', '/mosques/$mosqueId/dashboard') as Map);

  Future<Map<String, dynamic>> financeSetup(String mosqueId) async =>
      Map<String, dynamic>.from(await _send('GET', '/mosques/$mosqueId/finance/setup') as Map);

  Future<List<Map<String, dynamic>>> transactions(
    String mosqueId, {
    String? from,
    String? to,
    String? flow,
    String? q,
  }) async {
    final r = await _send(
      'GET',
      '/mosques/$mosqueId/finance/transactions',
      query: {'from': ?from, 'to': ?to, 'flow': ?flow, 'q': ?q},
    );
    return List<Map<String, dynamic>>.from(r['data'] as List);
  }

  Future<Map<String, dynamic>> createTransaction(
    String mosqueId,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) async {
    final r = await _send(
      'POST',
      '/mosques/$mosqueId/finance/transactions',
      body: data,
      headers: {'Idempotency-Key': idempotencyKey},
    );
    return Map<String, dynamic>.from(r['data'] as Map);
  }

  Future<List<Map<String, dynamic>>> events(String mosqueId) async =>
      List<Map<String, dynamic>>.from((await _send('GET', '/mosques/$mosqueId/events'))['data'] as List);

  Future<Map<String, dynamic>> createEvent(String mosqueId, Map<String, dynamic> data) async =>
      Map<String, dynamic>.from((await _send('POST', '/mosques/$mosqueId/events', body: data))['data'] as Map);

  Future<void> toggleEventDisplay(String mosqueId, int eventId, bool show) =>
      _send('PATCH', '/mosques/$mosqueId/events/$eventId/display', body: {'show_on_display': show});

  // Publik (tanpa akun)
  Future<List<Map<String, dynamic>>> searchPublicMosques(String q) async =>
      List<Map<String, dynamic>>.from((await _send('GET', '/public/mosques', query: {'q': q}))['data'] as List);

  Future<List<Map<String, dynamic>>> publicEvents(String slug) async =>
      List<Map<String, dynamic>>.from((await _send('GET', '/public/mosques/$slug/events'))['data'] as List);

  Future<List<Map<String, dynamic>>> publicAnnouncements(String slug) async =>
      List<Map<String, dynamic>>.from((await _send('GET', '/public/mosques/$slug/announcements'))['data'] as List);

  // ── Operasional Mosque ──────────────────────────────────────────────
  Map<String, dynamic> _map(dynamic v) => Map<String, dynamic>.from(v as Map);
  List<Map<String, dynamic>> _list(dynamic v) =>
      List<Map<String, dynamic>>.from((v as List).map((e) => Map<String, dynamic>.from(e as Map)));

  Future<Map<String, dynamic>> members(String id) async => _map(await _send('GET', '/mosques/$id/members'));
  Future<Map<String, dynamic>> inviteMember(String id, String email, String role) async =>
      _map((await _send('POST', '/mosques/$id/members/invite', body: {'email': email, 'role': role}))['data']);
  Future<void> updateMemberRole(String id, int memberId, String role) =>
      _send('PATCH', '/mosques/$id/members/$memberId', body: {'role': role});
  Future<void> deactivateMember(String id, int memberId) => _send('POST', '/mosques/$id/members/$memberId/deactivate');
  Future<void> reactivateMember(String id, int memberId) => _send('POST', '/mosques/$id/members/$memberId/reactivate');
  Future<Map<String, dynamic>> acceptInvitation(String token) async =>
      _map((await _send('POST', '/invitations/accept', body: {'token': token}))['data']);

  Future<List<Map<String, dynamic>>> staffAssignments(String id, {required String from, required String to}) async =>
      _list((await _send('GET', '/mosques/$id/staff-assignments', query: {'from': from, 'to': to}))['data']);
  Future<void> createStaffAssignment(String id, Map<String, dynamic> data) =>
      _send('POST', '/mosques/$id/staff-assignments', body: data);
  Future<void> deleteStaffAssignment(String id, int assignmentId) =>
      _send('DELETE', '/mosques/$id/staff-assignments/$assignmentId');

  Future<List<Map<String, dynamic>>> inventory(String id, {String? q, String? condition}) async =>
      _list((await _send('GET', '/mosques/$id/inventory', query: {'q': ?q, 'condition': ?condition}))['data']);
  Future<Map<String, dynamic>> inventoryItem(String id, int itemId) async =>
      _map((await _send('GET', '/mosques/$id/inventory/$itemId'))['data']);
  Future<void> createInventory(String id, Map<String, dynamic> data) =>
      _send('POST', '/mosques/$id/inventory', body: data);
  Future<void> addMaintenance(String id, int itemId, Map<String, dynamic> data) =>
      _send('POST', '/mosques/$id/inventory/$itemId/maintenance', body: data);

  Future<Map<String, dynamic>> displays(String id) async => _map(await _send('GET', '/mosques/$id/displays'));

  /// Konten TV Display untuk pratinjau desain (sama dengan yang diterima perangkat TV).
  Future<Map<String, dynamic>> displayPreview(String id) async =>
      _map((await _send('GET', '/mosques/$id/displays/preview'))['data']);
  Future<Map<String, dynamic>> createPairingCode(String id, String name) async =>
      _map((await _send('POST', '/mosques/$id/displays/pairing-codes', body: {'name': name}))['data']);
  Future<Map<String, dynamic>> approveDisplaySession(
    String id, {
    String? sessionId,
    String? code,
    String? name,
  }) async => _map(
    (await _send(
      'POST',
      '/mosques/$id/displays/approve-session',
      body: {
        if (sessionId != null && sessionId.isNotEmpty) 'session_id': sessionId,
        if (code != null && code.isNotEmpty) 'code': code,
        if (name != null && name.isNotEmpty) 'name': name,
      },
    ))['data'],
  );
  Future<void> revokeDisplay(String id, int deviceId) => _send('POST', '/mosques/$id/displays/$deviceId/revoke');
  Future<void> updateDisplay(String id, int deviceId, Map<String, dynamic> data) =>
      _send('PATCH', '/mosques/$id/displays/$deviceId', body: data);
  Future<Map<String, dynamic>> updateDisplaySettings(String id, Map<String, dynamic> data) async =>
      _map((await _send('PATCH', '/mosques/$id/displays/settings', body: data))['data']);
  Future<Map<String, dynamic>> setDisplayOverride(String id, Map<String, dynamic> data) async =>
      _map((await _send('POST', '/mosques/$id/displays/override', body: data))['data']);
  Future<void> clearDisplayOverride(String id) => _send('DELETE', '/mosques/$id/displays/override');
  Future<void> deleteDisplayQris(String id) => _send('DELETE', '/mosques/$id/displays/qris');
  Future<Map<String, dynamic>> uploadDisplayQris(
    String id, {
    required List<int> bytes,
    required String filename,
    String? label,
  }) async {
    final uri = Uri.parse('$baseUrl/mosques/$id/displays/qris');
    final req = http.MultipartRequest('POST', uri)
      ..headers.addAll({'Accept': 'application/json', if (token != null) 'Authorization': 'Bearer $token'})
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    if (label != null && label.isNotEmpty) req.fields['label'] = label;
    final res = await http.Response.fromStream(await _client.send(req).timeout(const Duration(seconds: 25)));
    final decoded = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300 && decoded is Map<String, dynamic>) {
      return _map(decoded['data']);
    }
    final map = decoded is Map<String, dynamic> ? decoded : const <String, dynamic>{};
    throw ApiException(
      res.statusCode,
      (map['message'] as String?) ??
          _tr('Gagal mengunggah QRIS (${res.statusCode}).', 'Failed to upload QRIS (${res.statusCode}).'),
    );
  }

  Future<List<Map<String, dynamic>>> announcements(String id) async =>
      _list((await _send('GET', '/mosques/$id/announcements'))['data']);
  Future<void> createAnnouncement(String id, Map<String, dynamic> data) =>
      _send('POST', '/mosques/$id/announcements', body: data);
  Future<void> toggleAnnouncementDisplay(String id, int annId, bool show) =>
      _send('PATCH', '/mosques/$id/announcements/$annId/display', body: {'show_on_display': show});
  Future<void> archiveAnnouncement(String id, int annId) => _send('POST', '/mosques/$id/announcements/$annId/archive');

  Future<Map<String, dynamic>> financeSummary(String id, {required String from, required String to}) async =>
      _map(await _send('GET', '/mosques/$id/finance/summary', query: {'from': from, 'to': to}));
  Future<Map<String, dynamic>> monthlyReport(String id, int year) async =>
      _map(await _send('GET', '/mosques/$id/finance/reports/monthly', query: {'year': '$year'}));
  Future<Map<String, dynamic>> fridayReport(String id, {String? date}) async =>
      _map(await _send('GET', '/mosques/$id/finance/friday-report', query: {'date': ?date}));
  Future<List<Map<String, dynamic>>> donationBoxCounts(String id) async =>
      _list((await _send('GET', '/mosques/$id/finance/donation-box-counts'))['data']);
  Future<Map<String, dynamic>> createDonationBoxCount(
    String id,
    Map<String, dynamic> data, {
    required String idempotencyKey,
  }) async => _map(
    (await _send(
      'POST',
      '/mosques/$id/finance/donation-box-counts',
      body: data,
      headers: {'Idempotency-Key': idempotencyKey},
    ))['data'],
  );
  Future<Map<String, dynamic>> transactionReceipt(String id, int txId) async =>
      _map((await _send('GET', '/mosques/$id/finance/transactions/$txId/receipt'))['data']);
  Future<void> reverseTransaction(String id, int txId, String reason) =>
      _send('POST', '/mosques/$id/finance/transactions/$txId/reverse', body: {'reason': reason});

  /// Ekspor CSV mentah (teks) untuk disimpan di perangkat.
  Future<String> exportCsv(String id, {required String from, required String to}) async {
    final uri = Uri.parse('$baseUrl/mosques/$id/finance/export').replace(queryParameters: {'from': from, 'to': to});
    final req = http.Request('GET', uri)..headers.addAll({'Authorization': 'Bearer $token'});
    final res = await http.Response.fromStream(await _client.send(req));
    if (res.statusCode != 200) {
      throw ApiException(
        res.statusCode,
        _tr('Gagal mengekspor laporan (${res.statusCode}).', 'Failed to export report (${res.statusCode}).'),
      );
    }
    return utf8.decode(res.bodyBytes);
  }

  Future<Map<String, dynamic>> subscription(String id) async => _map(await _send('GET', '/mosques/$id/subscription'));
  Future<List<Map<String, dynamic>>> auditLogs(String id) async =>
      _list((await _send('GET', '/mosques/$id/audit-logs'))['data']);

  // Zakat, Kurban & Kupon QR
  Future<Map<String, dynamic>> zakat(String id, {int? hijriYear}) async =>
      _map(await _send('GET', '/mosques/$id/zakat', query: {if (hijriYear != null) 'hijri_year': '$hijriYear'}));
  Future<Map<String, dynamic>> createZakatCollection(String id, Map<String, dynamic> data) async =>
      _map((await _send('POST', '/mosques/$id/zakat/collections', body: data))['data']);
  Future<Map<String, dynamic>> createZakatMustahik(String id, Map<String, dynamic> data) async =>
      _map((await _send('POST', '/mosques/$id/zakat/mustahiks', body: data))['data']);
  Future<Map<String, dynamic>> distributeMustahik(String id, int mustahikId, {Map<String, dynamic>? data}) async =>
      _map((await _send('POST', '/mosques/$id/zakat/mustahiks/$mustahikId/distribute', body: data ?? const {}))['data']);

  Future<Map<String, dynamic>> qurbanAnimals(String id, {int? hijriYear}) async => _map(
    await _send('GET', '/mosques/$id/qurban/animals', query: {if (hijriYear != null) 'hijri_year': '$hijriYear'}),
  );
  Future<Map<String, dynamic>> createQurbanAnimal(String id, Map<String, dynamic> data) async =>
      _map((await _send('POST', '/mosques/$id/qurban/animals', body: data))['data']);
  Future<Map<String, dynamic>> updateQurbanAnimal(String id, int animalId, Map<String, dynamic> data) async =>
      _map((await _send('PATCH', '/mosques/$id/qurban/animals/$animalId', body: data))['data']);
  Future<Map<String, dynamic>> createQurbanParticipant(String id, int animalId, Map<String, dynamic> data) async =>
      _map((await _send('POST', '/mosques/$id/qurban/animals/$animalId/participants', body: data))['data']);
  Future<Map<String, dynamic>> updateQurbanParticipant(String id, int participantId, Map<String, dynamic> data) async =>
      _map((await _send('PATCH', '/mosques/$id/qurban/participants/$participantId', body: data))['data']);

  Future<Map<String, dynamic>> coupons(String id, {String? program, int? hijriYear, String? status}) async => _map(
    await _send(
      'GET',
      '/mosques/$id/coupons',
      query: {
        'program': ?program,
        if (hijriYear != null) 'hijri_year': '$hijriYear',
        'status': ?status,
      },
    ),
  );
  Future<List<Map<String, dynamic>>> createCoupons(String id, Map<String, dynamic> data) async =>
      _list((await _send('POST', '/mosques/$id/coupons', body: data))['data']);
  Future<Map<String, dynamic>> redeemCoupon(String id, String code) async =>
      _map((await _send('POST', '/mosques/$id/coupons/redeem', body: {'code': code}))['data']);
  Future<Map<String, dynamic>> voidCoupon(String id, int couponId) async =>
      _map((await _send('POST', '/mosques/$id/coupons/$couponId/void'))['data']);

  // ── Moeslim Family Cloud (opt-in lintas perangkat) ──────────────────────
  Future<List<Map<String, dynamic>>> families() async => _list((await _send('GET', '/families'))['data']);
  Future<Map<String, dynamic>> createFamily(String name, {String timezone = 'Asia/Jakarta'}) async =>
      _map((await _send('POST', '/families', body: {'name': name, 'timezone': timezone}))['data']);
  Future<Map<String, dynamic>> familyDetail(String familyId) async =>
      _map((await _send('GET', '/families/$familyId'))['data']);
  Future<Map<String, dynamic>> createFamilyInvite(String familyId) async =>
      _map((await _send('POST', '/families/$familyId/invites'))['data']);
  Future<void> revokeFamilyInvite(String familyId, String inviteId) =>
      _send('DELETE', '/families/$familyId/invites/$inviteId');
  Future<Map<String, dynamic>> acceptFamilyInvite(String token) async =>
      _map((await _send('POST', '/family-invites/accept', body: {'token': token}))['data']);
  Future<Map<String, dynamic>> saveFamilyEvent(String familyId, String eventId, Map<String, dynamic> data) async =>
      _map((await _send('PUT', '/families/$familyId/events/$eventId', body: data))['data']);
  Future<Map<String, dynamic>> saveFamilyGoal(String familyId, Map<String, dynamic> data) async =>
      _map((await _send('POST', '/families/$familyId/goals', body: data))['data']);
  Future<void> deleteFamilyGoal(String familyId, String goalId) =>
      _send('DELETE', '/families/$familyId/goals/$goalId');
  Future<void> leaveFamily(String familyId) => _send('POST', '/families/$familyId/leave');
  Future<void> dissolveFamily(String familyId, String confirmName) =>
      _send('DELETE', '/families/$familyId', body: {'confirm_name': confirmName});

  // ── Ramadan Local & Kelas Masjid (Publik + Pendaftaran Jamaah) ──────────
  Future<Map<String, dynamic>> publicRamadanEvents(String slug, {int? hijriYear}) async => _map(
    await _send(
      'GET',
      '/public/mosques/$slug/ramadan/events',
      query: {if (hijriYear != null) 'hijri_year': '$hijriYear'},
    ),
  );
  Future<Map<String, dynamic>> publicMosqueClasses(String slug, {String? learningPath}) async => _map(
    await _send(
      'GET',
      '/public/mosques/$slug/classes',
      query: {'learning_path': ?learningPath},
    ),
  );
  Future<Map<String, dynamic>> registerEvent(
    int eventId, {
    String? participantName,
    String? contactPhone,
    String? notes,
  }) async => _map(
    (await _send(
      'POST',
      '/events/$eventId/registrations',
      body: {
        if (participantName != null && participantName.isNotEmpty) 'participant_name': participantName,
        if (contactPhone != null && contactPhone.isNotEmpty) 'contact_phone': contactPhone,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    ))['data'],
  );
  Future<Map<String, dynamic>> cancelEventRegistration(int eventId) async =>
      _map((await _send('DELETE', '/events/$eventId/registrations'))['data']);
  Future<List<Map<String, dynamic>>> myEventRegistrations() async =>
      _list((await _send('GET', '/me/registrations'))['data']);
  Future<Map<String, dynamic>> mosqueEventRegistrations(String mosqueId, int eventId) async =>
      _map(await _send('GET', '/mosques/$mosqueId/events/$eventId/registrations'));
  Future<Map<String, dynamic>> updateMosqueEventRegistration(
    String mosqueId,
    int eventId,
    String registrationId,
    String status,
  ) async => _map(
    (await _send('PATCH', '/mosques/$mosqueId/events/$eventId/registrations/$registrationId', body: {'status': status}))['data'],
  );

  // ── Moeslim Services (Jamaah & Pengurus Mosque) ─────────────────────────
  Future<Map<String, dynamic>> publicMosqueServices(String slug) async =>
      _map(await _send('GET', '/public/mosques/$slug/services'));
  Future<Map<String, dynamic>> submitServiceRequest(
    String slug, {
    required String definitionId,
    required Map<String, String> answers,
    required String idempotencyKey,
  }) async => _map(
    (await _send(
      'POST',
      '/public/mosques/$slug/service-requests',
      body: {'service_definition_id': definitionId, 'answers': answers},
      headers: {'Idempotency-Key': idempotencyKey},
    ))['data'],
  );
  Future<List<Map<String, dynamic>>> myServiceRequests() async =>
      _list((await _send('GET', '/me/service-requests'))['data']);
  Future<Map<String, dynamic>> resubmitServiceRequest(
    String requestId,
    Map<String, String> answers, {
    String? message,
  }) async => _map(
    (await _send(
      'POST',
      '/me/service-requests/$requestId/resubmit',
      body: {'answers': answers, if (message != null && message.isNotEmpty) 'message': message},
    ))['data'],
  );
  Future<Map<String, dynamic>> cancelServiceRequest(String requestId, {String? reason}) async => _map(
    (await _send(
      'POST',
      '/me/service-requests/$requestId/cancel',
      body: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    ))['data'],
  );

  Future<List<Map<String, dynamic>>> mosqueServices(String mosqueId) async =>
      _list((await _send('GET', '/mosques/$mosqueId/services'))['data']);
  Future<Map<String, dynamic>> createMosqueService(String mosqueId, Map<String, dynamic> data) async =>
      _map((await _send('POST', '/mosques/$mosqueId/services', body: data))['data']);
  Future<Map<String, dynamic>> updateMosqueService(String mosqueId, String defId, Map<String, dynamic> data) async =>
      _map((await _send('PATCH', '/mosques/$mosqueId/services/$defId', body: data))['data']);
  Future<List<Map<String, dynamic>>> mosqueServiceRequests(String mosqueId, {String? status, String? type}) async =>
      _list((await _send('GET', '/mosques/$mosqueId/service-requests', query: {'status': ?status, 'type': ?type}))['data']);
  Future<Map<String, dynamic>> updateMosqueServiceRequestStatus(
    String mosqueId,
    String requestId,
    String status, {
    String? message,
  }) async => _map(
    (await _send(
      'PATCH',
      '/mosques/$mosqueId/service-requests/$requestId/status',
      body: {'status': status, if (message != null && message.isNotEmpty) 'message': message},
    ))['data'],
  );
}
