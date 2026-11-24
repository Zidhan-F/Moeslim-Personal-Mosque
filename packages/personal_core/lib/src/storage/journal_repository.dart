import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'key_value_store.dart';

/// Jenis entri Moeslim Journal (100% lokal dan privat).
enum JournalEntryKind {
  free('Catatan Bebas', 'Free Note'),
  ayah('Refleksi Ayat', 'Verse Reflection'),
  hadith('Refleksi Hadis', 'Hadith Reflection'),
  kajian('Catatan Kajian', 'Lecture Notes'),
  muhasabah('Muhasabah', 'Muhasabah');

  final String labelId;
  final String labelEn;
  const JournalEntryKind(this.labelId, this.labelEn);
}

/// Prompt refleksi netral opsional (JRN-05): pengguna bebas menutup dan menulis langsung.
class JournalPrompt {
  final String id;
  final String textId;
  final String textEn;
  const JournalPrompt(this.id, this.textId, this.textEn);
}

const List<JournalPrompt> journalReflectionPrompts = [
  JournalPrompt(
    'p1',
    'Hal sederhana apa hari ini yang membuat hati lebih tenang?',
    'What simple moment today brought calm to your heart?',
  ),
  JournalPrompt(
    'p2',
    'Ayat, hadis, atau nasihat apa yang paling mengena pekan ini?',
    'Which verse, hadith, or advice resonated most with you this week?',
  ),
  JournalPrompt(
    'p3',
    'Satu kebiasaan baik apa yang ingin dijaga dengan lembut besok?',
    'What single good habit would you like to nurture gently tomorrow?',
  ),
  JournalPrompt(
    'p4',
    'Doa atau harapan apa yang ingin Anda titipkan hari ini?',
    'What prayer or hope would you like to write down today?',
  ),
];

/// Entri Moeslim Journal dengan pemisahan tegas antara rujukan sumber asli (`sourceRef`, `sourceExcerpt`)
/// dan refleksi pribadi pengguna (`body`).
class JournalEntry {
  final String id;
  final JournalEntryKind kind;
  final String title;
  final String body;
  final List<String> tags;
  final String? sourceRef;
  final String? sourceExcerpt;
  final String? mood;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final DateTime? deletedAt;

  const JournalEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.tags = const [],
    this.sourceRef,
    this.sourceExcerpt,
    this.mood,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  JournalEntry copyWith({
    JournalEntryKind? kind,
    String? title,
    String? body,
    List<String>? tags,
    String? sourceRef,
    String? sourceExcerpt,
    String? mood,
    DateTime? updatedAt,
    bool? isArchived,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) =>
      JournalEntry(
        id: id,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        body: body ?? this.body,
        tags: tags ?? this.tags,
        sourceRef: sourceRef ?? this.sourceRef,
        sourceExcerpt: sourceExcerpt ?? this.sourceExcerpt,
        mood: mood ?? this.mood,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isArchived: isArchived ?? this.isArchived,
        deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind.name,
        'title': title,
        'body': body,
        'tags': tags,
        if (sourceRef != null) 'sourceRef': sourceRef,
        if (sourceExcerpt != null) 'sourceExcerpt': sourceExcerpt,
        if (mood != null) 'mood': mood,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'isArchived': isArchived,
        if (deletedAt != null) 'deletedAt': deletedAt!.toUtc().toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
        id: j['id'] as String? ?? 'j_${DateTime.now().millisecondsSinceEpoch}',
        kind: JournalEntryKind.values.where((k) => k.name == j['kind']).firstOrNull ?? JournalEntryKind.free,
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        tags: (j['tags'] as List? ?? const []).map((e) => '$e').where((e) => e.trim().isNotEmpty).toList(),
        sourceRef: j['sourceRef'] as String?,
        sourceExcerpt: j['sourceExcerpt'] as String?,
        mood: j['mood'] as String?,
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '')?.toUtc() ?? DateTime.now().toUtc(),
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '')?.toUtc() ?? DateTime.now().toUtc(),
        isArchived: j['isArchived'] as bool? ?? false,
        deletedAt: DateTime.tryParse(j['deletedAt'] as String? ?? '')?.toUtc(),
      );
}

class JournalDraft {
  final JournalEntryKind kind;
  final String title;
  final String body;
  final String tagsText;
  final String sourceRef;
  final String sourceExcerpt;
  final DateTime updatedAt;

  const JournalDraft({
    required this.kind,
    required this.title,
    required this.body,
    this.tagsText = '',
    this.sourceRef = '',
    this.sourceExcerpt = '',
    required this.updatedAt,
  });

  bool get isEmpty => title.trim().isEmpty && body.trim().isEmpty && sourceRef.trim().isEmpty;

  Map<String, Object> toJson() => {
        'kind': kind.name,
        'title': title,
        'body': body,
        'tagsText': tagsText,
        'sourceRef': sourceRef,
        'sourceExcerpt': sourceExcerpt,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory JournalDraft.fromJson(Map<String, dynamic> j) => JournalDraft(
        kind: JournalEntryKind.values.where((k) => k.name == j['kind']).firstOrNull ?? JournalEntryKind.free,
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        tagsText: j['tagsText'] as String? ?? '',
        sourceRef: j['sourceRef'] as String? ?? '',
        sourceExcerpt: j['sourceExcerpt'] as String? ?? '',
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '')?.toUtc() ?? DateTime.now().toUtc(),
      );
}

/// Penyimpanan Moeslim Journal 100% lokal:
/// - Tidak pernah mengirim entri ke server Family maupun Mosque (JRN-AC02).
/// - Kunci PIN disimpan sebagai hash SHA-256 bersalt, bukan plaintext (JRN-06).
/// - Mendukung autosave draft offline, pencarian lokal, arsip, pemulihan hapus, dan ekspor/impor terenkripsi.
class JournalRepository {
  static const _entriesKey = 'moeslim_journal_entries_v1';
  static const _draftKey = 'moeslim_journal_draft_v1';
  static const _pinHashKey = 'moeslim_journal_pin_hash_v1';
  static const _legacyPinKey = 'muhasabah_pin';

  final KeyValueStore _store;
  final DateTime Function() _now;

  JournalRepository(this._store, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  // ── PIN LOKAL BER-HASH (TANPA PLAINTEXT) ────────────────────────────────

  Future<bool> hasPin() async {
    final hashed = await _store.read(_pinHashKey);
    if (hashed != null && hashed.contains(':')) return true;
    final legacy = await _store.read(_legacyPinKey);
    return legacy != null && legacy.trim().isNotEmpty;
  }

  Future<void> setPin(String? pin) async {
    await _store.delete(_legacyPinKey);
    if (pin == null || pin.trim().isEmpty) {
      await _store.delete(_pinHashKey);
      return;
    }
    final salt = _randomHex(16);
    final digest = _hashPin(pin.trim(), salt);
    await _store.write(_pinHashKey, '$salt:$digest');
  }

  Future<bool> verifyPin(String input) async {
    final trimmed = input.trim();
    final stored = await _store.read(_pinHashKey);
    if (stored != null && stored.contains(':')) {
      final parts = stored.split(':');
      final expected = parts[1];
      final actual = _hashPin(trimmed, parts[0]);
      return _constantTimeEq(expected, actual);
    }
    // Migrasi otomatis PIN lama (plaintext) ke hash bersalt pada verifikasi pertama.
    final legacy = await _store.read(_legacyPinKey);
    if (legacy == null || legacy.trim().isEmpty) return true;
    if (legacy.trim() == trimmed) {
      await setPin(trimmed);
      return true;
    }
    return false;
  }

  // ── ENTRI, PENCARIAN, ARSIP, HAPUS & PEMULIHAN ──────────────────────────

  Future<List<JournalEntry>> allEntries({bool includeArchived = false, bool includeDeleted = false}) async {
    final all = await _loadAllRaw();
    return all
        .where((e) => (includeDeleted || !e.isDeleted) && (includeArchived || !e.isArchived))
        .toList();
  }

  Future<List<JournalEntry>> deletedEntries() async {
    final all = await _loadAllRaw();
    return all.where((e) => e.isDeleted).toList();
  }

  Future<List<JournalEntry>> archivedEntries() async {
    final all = await _loadAllRaw();
    return all.where((e) => !e.isDeleted && e.isArchived).toList();
  }

  Future<List<JournalEntry>> search({
    String query = '',
    String? tag,
    JournalEntryKind? kind,
    bool archived = false,
  }) async {
    final q = query.trim().toLowerCase();
    final t = tag?.trim().toLowerCase();
    final base = archived ? await archivedEntries() : await allEntries();
    return base.where((e) {
      if (kind != null && e.kind != kind) return false;
      if (t != null && t.isNotEmpty && !e.tags.any((x) => x.toLowerCase() == t)) return false;
      if (q.isEmpty) return true;
      return e.title.toLowerCase().contains(q) ||
          e.body.toLowerCase().contains(q) ||
          (e.sourceRef?.toLowerCase().contains(q) ?? false) ||
          (e.sourceExcerpt?.toLowerCase().contains(q) ?? false) ||
          e.tags.any((x) => x.toLowerCase().contains(q));
    }).toList();
  }

  Future<List<String>> allTags() async {
    final list = await allEntries(includeArchived: true);
    final set = <String>{};
    for (final e in list) {
      for (final tag in e.tags) {
        set.add(tag);
      }
    }
    final sorted = set.toList()..sort();
    return sorted;
  }

  Future<JournalEntry> saveEntry({
    String? id,
    required JournalEntryKind kind,
    required String title,
    required String body,
    List<String> tags = const [],
    String? sourceRef,
    String? sourceExcerpt,
    String? mood,
  }) async {
    final now = _now().toUtc();
    final all = await _loadAllRaw();
    final cleanTags = {
      for (final t in tags)
        if (t.trim().isNotEmpty) t.trim().replaceFirst(RegExp(r'^#'), ''),
    }.toList();

    final existingIdx = id == null ? -1 : all.indexWhere((e) => e.id == id);
    final entry = existingIdx >= 0
        ? all[existingIdx].copyWith(
            kind: kind,
            title: title.trim(),
            body: body.trim(),
            tags: cleanTags,
            sourceRef: sourceRef?.trim().isEmpty == true ? null : sourceRef?.trim(),
            sourceExcerpt: sourceExcerpt?.trim().isEmpty == true ? null : sourceExcerpt?.trim(),
            mood: mood,
            updatedAt: now,
          )
        : JournalEntry(
            id: id ?? 'j_${now.millisecondsSinceEpoch}_${_randomHex(4)}',
            kind: kind,
            title: title.trim(),
            body: body.trim(),
            tags: cleanTags,
            sourceRef: sourceRef?.trim().isEmpty == true ? null : sourceRef?.trim(),
            sourceExcerpt: sourceExcerpt?.trim().isEmpty == true ? null : sourceExcerpt?.trim(),
            mood: mood,
            createdAt: now,
            updatedAt: now,
          );

    if (existingIdx >= 0) {
      all[existingIdx] = entry;
    } else {
      all.insert(0, entry);
    }
    await _saveAllRaw(all);
    return entry;
  }

  Future<void> setArchived(String id, bool archived) async {
    final all = await _loadAllRaw();
    final idx = all.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    all[idx] = all[idx].copyWith(isArchived: archived, updatedAt: _now().toUtc());
    await _saveAllRaw(all);
  }

  Future<void> softDelete(String id) async {
    final all = await _loadAllRaw();
    final idx = all.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    all[idx] = all[idx].copyWith(deletedAt: _now().toUtc(), updatedAt: _now().toUtc());
    await _saveAllRaw(all);
  }

  Future<void> restoreEntry(String id) async {
    final all = await _loadAllRaw();
    final idx = all.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    all[idx] = all[idx].copyWith(clearDeletedAt: true, updatedAt: _now().toUtc());
    await _saveAllRaw(all);
  }

  Future<void> purgePermanent(String id) async {
    final all = (await _loadAllRaw()).where((e) => e.id != id).toList();
    await _saveAllRaw(all);
  }

  // ── AUTOSAVE DRAFT OFFLINE ──────────────────────────────────────────────

  Future<void> saveDraft(JournalDraft draft) async {
    if (draft.isEmpty) {
      await clearDraft();
      return;
    }
    await _store.writeJson(_draftKey, draft.toJson());
  }

  Future<JournalDraft?> loadDraft() async {
    final raw = await _store.readJson(_draftKey);
    if (raw is! Map) return null;
    final d = JournalDraft.fromJson(Map<String, dynamic>.from(raw));
    return d.isEmpty ? null : d;
  }

  Future<void> clearDraft() => _store.delete(_draftKey);

  // ── EKSPOR & IMPOR TERENKRIPSI LOKAL (JRN-07) ───────────────────────────

  Future<String> exportEncrypted(String passphrase) async {
    final pass = passphrase.trim();
    if (pass.length < 4) {
      throw ArgumentError('Kata sandi ekspor minimal 4 karakter.');
    }
    final all = await _loadAllRaw();
    final plainJson = jsonEncode({
      'version': 1,
      'exportedAt': _now().toUtc().toIso8601String(),
      'entries': [for (final e in all) e.toJson()],
    });
    final plainBytes = Uint8List.fromList(utf8.encode(plainJson));
    final salt = _randomBytes(16);
    final key = _deriveKey(pass, salt);
    final cipher = _xorStream(plainBytes, key, salt);
    final mac = _hmacSha256(key, Uint8List.fromList([...salt, ...cipher]));

    return jsonEncode({
      'format': 'moeslim-journal-encrypted',
      'version': 1,
      'salt': base64Encode(salt),
      'mac': base64Encode(mac),
      'ciphertext': base64Encode(cipher),
    });
  }

  Future<int> importEncrypted(String envelopeJson, String passphrase) async {
    final decoded = jsonDecode(envelopeJson);
    if (decoded is! Map || decoded['format'] != 'moeslim-journal-encrypted' || decoded['version'] != 1) {
      throw const FormatException('Format berkas jurnal terenkripsi tidak dikenali.');
    }
    final salt = base64Decode(decoded['salt'] as String);
    final expectedMac = base64Decode(decoded['mac'] as String);
    final cipher = base64Decode(decoded['ciphertext'] as String);
    final key = _deriveKey(passphrase.trim(), salt);
    final actualMac = _hmacSha256(key, Uint8List.fromList([...salt, ...cipher]));

    if (!_bytesEqual(expectedMac, actualMac)) {
      throw const FormatException('Kata sandi salah atau berkas ekspor telah rusak.');
    }
    final plainBytes = _xorStream(cipher, key, salt);
    final payload = jsonDecode(utf8.decode(plainBytes));
    if (payload is! Map || payload['entries'] is! List) {
      throw const FormatException('Isi berkas jurnal tidak valid.');
    }

    final existing = await _loadAllRaw();
    final byId = {for (final e in existing) e.id: e};
    var imported = 0;
    for (final raw in payload['entries'] as List) {
      if (raw is! Map) continue;
      final entry = JournalEntry.fromJson(Map<String, dynamic>.from(raw));
      final cur = byId[entry.id];
      if (cur == null || entry.updatedAt.isAfter(cur.updatedAt)) {
        byId[entry.id] = entry;
        imported++;
      }
    }
    final merged = byId.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _saveAllRaw(merged);
    return imported;
  }

  // ── INTERNAL STORAGE & PURE-DART SHA-256 ────────────────────────────────

  Future<List<JournalEntry>> _loadAllRaw() async {
    final raw = await _store.readJson(_entriesKey);
    if (raw is! List) return <JournalEntry>[];
    final list = <JournalEntry>[
      for (final e in raw)
        if (e is Map) JournalEntry.fromJson(Map<String, dynamic>.from(e)),
    ];
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> _saveAllRaw(List<JournalEntry> entries) =>
      _store.writeJson(_entriesKey, [for (final e in entries) e.toJson()]);

  static String _randomHex(int bytes) => _bytesToHex(_randomBytes(bytes));

  static Uint8List _randomBytes(int n) {
    final r = Random.secure();
    return Uint8List.fromList(List<int>.generate(n, (_) => r.nextInt(256)));
  }

  static String _hashPin(String pin, String salt) {
    var acc = Uint8List.fromList(utf8.encode('moeslim-jrn-pin:$salt:$pin'));
    for (var i = 0; i < 200; i++) {
      acc = _sha256(acc);
    }
    return _bytesToHex(acc);
  }

  static Uint8List _deriveKey(String pass, Uint8List salt) {
    var acc = Uint8List.fromList([...utf8.encode('moeslim-jrn-key:$pass:'), ...salt]);
    for (var i = 0; i < 400; i++) {
      acc = _sha256(acc);
    }
    return acc;
  }

  static Uint8List _xorStream(Uint8List data, Uint8List key, Uint8List nonce) {
    final out = Uint8List(data.length);
    var offset = 0;
    var counter = 0;
    while (offset < data.length) {
      final blockInput = Uint8List(key.length + nonce.length + 4);
      blockInput.setRange(0, key.length, key);
      blockInput.setRange(key.length, key.length + nonce.length, nonce);
      blockInput[key.length + nonce.length] = (counter >> 24) & 0xff;
      blockInput[key.length + nonce.length + 1] = (counter >> 16) & 0xff;
      blockInput[key.length + nonce.length + 2] = (counter >> 8) & 0xff;
      blockInput[key.length + nonce.length + 3] = counter & 0xff;
      final ks = _sha256(blockInput);
      final chunk = min(ks.length, data.length - offset);
      for (var i = 0; i < chunk; i++) {
        out[offset + i] = data[offset + i] ^ ks[i];
      }
      offset += chunk;
      counter++;
    }
    return out;
  }

  static Uint8List _hmacSha256(Uint8List key, Uint8List msg) {
    final k = key.length > 64 ? _sha256(key) : key;
    final ipad = Uint8List(64);
    final opad = Uint8List(64);
    for (var i = 0; i < 64; i++) {
      final kb = i < k.length ? k[i] : 0;
      ipad[i] = kb ^ 0x36;
      opad[i] = kb ^ 0x5c;
    }
    final inner = _sha256(Uint8List.fromList([...ipad, ...msg]));
    return _sha256(Uint8List.fromList([...opad, ...inner]));
  }

  static bool _constantTimeEq(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  static String _bytesToHex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  /// Implementasi standar FIPS 180-4 SHA-256 (pure Dart, tanpa dependensi tambahan).
  static Uint8List _sha256(Uint8List input) {
    const k = <int>[
      0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
      0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
      0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
      0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
      0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
      0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
      0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
      0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    ];
    var h0 = 0x6a09e667, h1 = 0xbb67ae85, h2 = 0x3c6ef372, h3 = 0xa54ff53a;
    var h4 = 0x510e527f, h5 = 0x9b05688c, h6 = 0x1f83d9ab, h7 = 0x5be0cd19;

    final bitLen = input.length * 8;
    final padLen = ((56 - (input.length + 1) % 64) + 64) % 64;
    final padded = Uint8List(input.length + 1 + padLen + 8);
    padded.setRange(0, input.length, input);
    padded[input.length] = 0x80;
    final bd = ByteData.sublistView(padded);
    bd.setUint32(padded.length - 8, (bitLen ~/ 0x100000000) & 0xffffffff);
    bd.setUint32(padded.length - 4, bitLen & 0xffffffff);

    int rotr(int x, int n) => ((x & 0xffffffff) >>> n) | ((x << (32 - n)) & 0xffffffff);

    final w = Uint32List(64);
    for (var offset = 0; offset < padded.length; offset += 64) {
      for (var i = 0; i < 16; i++) {
        w[i] = bd.getUint32(offset + i * 4);
      }
      for (var i = 16; i < 64; i++) {
        final s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >>> 3);
        final s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >>> 10);
        w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xffffffff;
      }
      var a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, h = h7;
      for (var i = 0; i < 64; i++) {
        final s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25);
        final ch = (e & f) ^ ((~e & 0xffffffff) & g);
        final t1 = (h + s1 + ch + k[i] + w[i]) & 0xffffffff;
        final s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final t2 = (s0 + maj) & 0xffffffff;
        h = g;
        g = f;
        f = e;
        e = (d + t1) & 0xffffffff;
        d = c;
        c = b;
        b = a;
        a = (t1 + t2) & 0xffffffff;
      }
      h0 = (h0 + a) & 0xffffffff;
      h1 = (h1 + b) & 0xffffffff;
      h2 = (h2 + c) & 0xffffffff;
      h3 = (h3 + d) & 0xffffffff;
      h4 = (h4 + e) & 0xffffffff;
      h5 = (h5 + f) & 0xffffffff;
      h6 = (h6 + g) & 0xffffffff;
      h7 = (h7 + h) & 0xffffffff;
    }

    final out = Uint8List(32);
    final outBd = ByteData.sublistView(out);
    final hs = [h0, h1, h2, h3, h4, h5, h6, h7];
    for (var i = 0; i < 8; i++) {
      outBd.setUint32(i * 4, hs[i]);
    }
    return out;
  }
}
