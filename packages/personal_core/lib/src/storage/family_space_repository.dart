import 'dart:math';

import 'key_value_store.dart';

/// Profil anak lokal yang dikelola wali di perangkat (FAM-08).
/// Tidak pernah diunggah otomatis ke cloud Family maupun Mosque.
class LocalChildProfile {
  final String id;
  final String nickname;
  final String ageGroup; // e.g. '4-6 tahun', '7-9 tahun', '10-12 tahun'
  final String learningLevel; // e.g. 'Hijaiyah L1', 'Kosakata L2'
  final String preferredPathId;
  final String notes;

  const LocalChildProfile({
    required this.id,
    required this.nickname,
    required this.ageGroup,
    required this.learningLevel,
    this.preferredPathId = 'arabic',
    this.notes = '',
  });

  Map<String, Object> toJson() => {
        'id': id,
        'nickname': nickname,
        'ageGroup': ageGroup,
        'learningLevel': learningLevel,
        'preferredPathId': preferredPathId,
        'notes': notes,
      };

  factory LocalChildProfile.fromJson(Map<String, dynamic> j) => LocalChildProfile(
        id: j['id'] as String? ?? 'c_1',
        nickname: j['nickname'] as String? ?? '',
        ageGroup: j['ageGroup'] as String? ?? '7-9 tahun',
        learningLevel: j['learningLevel'] as String? ?? 'L1 Dasar',
        preferredPathId: j['preferredPathId'] as String? ?? 'arabic',
        notes: j['notes'] as String? ?? '',
      );
}

enum FamilySyncState { localOnly, pendingSync, synced, conflict }

/// Agenda bersama keluarga dengan antrean sinkronisasi offline & kontrol versi (FAM-05 / FAM-09).
class FamilyAgendaItem {
  final String id; // UUID v4 stabil untuk sinkronisasi cloud
  final String title;
  final DateTime startsAt;
  final String location;
  final String recurrence; // none, daily, weekly
  final String? learningPath;
  final int version;
  final FamilySyncState syncState;
  final bool deleted;
  final String? conflictServerTitle;

  const FamilyAgendaItem({
    required this.id,
    required this.title,
    required this.startsAt,
    this.location = '',
    this.recurrence = 'none',
    this.learningPath,
    this.version = 0,
    this.syncState = FamilySyncState.localOnly,
    this.deleted = false,
    this.conflictServerTitle,
  });

  FamilyAgendaItem copyWith({
    String? title,
    DateTime? startsAt,
    String? location,
    String? recurrence,
    String? learningPath,
    int? version,
    FamilySyncState? syncState,
    bool? deleted,
    String? conflictServerTitle,
  }) =>
      FamilyAgendaItem(
        id: id,
        title: title ?? this.title,
        startsAt: startsAt ?? this.startsAt,
        location: location ?? this.location,
        recurrence: recurrence ?? this.recurrence,
        learningPath: learningPath ?? this.learningPath,
        version: version ?? this.version,
        syncState: syncState ?? this.syncState,
        deleted: deleted ?? this.deleted,
        conflictServerTitle: conflictServerTitle ?? this.conflictServerTitle,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'startsAt': startsAt.toUtc().toIso8601String(),
        'location': location,
        'recurrence': recurrence,
        if (learningPath != null) 'learningPath': learningPath,
        'version': version,
        'syncState': syncState.name,
        'deleted': deleted,
        if (conflictServerTitle != null) 'conflictServerTitle': conflictServerTitle,
      };

  factory FamilyAgendaItem.fromJson(Map<String, dynamic> j) => FamilyAgendaItem(
        id: j['id'] as String? ?? FamilySpaceRepository.newUuidV4(),
        title: j['title'] as String? ?? '',
        startsAt: DateTime.tryParse(j['startsAt'] as String? ?? '')?.toUtc() ?? DateTime.now().toUtc(),
        location: j['location'] as String? ?? '',
        recurrence: j['recurrence'] as String? ?? 'none',
        learningPath: j['learningPath'] as String?,
        version: (j['version'] as num?)?.toInt() ?? 0,
        syncState: FamilySyncState.values.where((s) => s.name == j['syncState']).firstOrNull ?? FamilySyncState.localOnly,
        deleted: j['deleted'] as bool? ?? false,
        conflictServerTitle: j['conflictServerTitle'] as String?,
      );
}

/// Target belajar bersama (FAM-06) — tanpa ranking atau tracker sholat individu.
class FamilyLearningGoal {
  final String id;
  final String learningPath;
  final String title;
  final String targetDescription;
  final String? deadlineIso;
  final bool completed;

  const FamilyLearningGoal({
    required this.id,
    required this.learningPath,
    required this.title,
    this.targetDescription = '',
    this.deadlineIso,
    this.completed = false,
  });

  FamilyLearningGoal copyWith({bool? completed}) => FamilyLearningGoal(
        id: id,
        learningPath: learningPath,
        title: title,
        targetDescription: targetDescription,
        deadlineIso: deadlineIso,
        completed: completed ?? this.completed,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'learningPath': learningPath,
        'title': title,
        'targetDescription': targetDescription,
        if (deadlineIso != null) 'deadlineIso': deadlineIso,
        'completed': completed,
      };

  factory FamilyLearningGoal.fromJson(Map<String, dynamic> j) => FamilyLearningGoal(
        id: j['id'] as String? ?? FamilySpaceRepository.newUuidV4(),
        learningPath: j['learningPath'] as String? ?? 'arabic',
        title: j['title'] as String? ?? '',
        targetDescription: j['targetDescription'] as String? ?? '',
        deadlineIso: j['deadlineIso'] as String?,
        completed: j['completed'] as bool? ?? false,
      );
}

class LocalFamilySpace {
  final String id;
  final String name;
  final String timezone;
  final String? cloudFamilyId;
  final String role; // admin | member

  const LocalFamilySpace({
    required this.id,
    required this.name,
    this.timezone = 'Asia/Jakarta',
    this.cloudFamilyId,
    this.role = 'admin',
  });

  bool get isCloudLinked => cloudFamilyId != null && cloudFamilyId!.isNotEmpty;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'timezone': timezone,
        if (cloudFamilyId != null) 'cloudFamilyId': cloudFamilyId,
        'role': role,
      };

  factory LocalFamilySpace.fromJson(Map<String, dynamic> j) => LocalFamilySpace(
        id: j['id'] as String? ?? 'local_family',
        name: j['name'] as String? ?? 'Keluarga Kami',
        timezone: j['timezone'] as String? ?? 'Asia/Jakarta',
        cloudFamilyId: j['cloudFamilyId'] as String?,
        role: j['role'] as String? ?? 'admin',
      );
}

/// Penyimpanan Moeslim Family (mode lokal tanpa akun + antrean sinkronisasi Family Cloud).
/// Menjaga batas privasi tegas: TIDAK menyentuh data Journal atau tracker sholat pribadi (FAM-AC05).
class FamilySpaceRepository {
  static const _spaceKey = 'family_space_v1';
  static const _eventsKey = 'family_events_v1';
  static const _goalsKey = 'family_goals_v1';
  static const _childrenKey = 'family_children_local_v1';

  final KeyValueStore _store;

  const FamilySpaceRepository(this._store);

  static String newUuidV4() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    String h(int s, int e) => b.sublist(s, e).map((v) => v.toRadixString(16).padLeft(2, '0')).join();
    return '${h(0, 4)}-${h(4, 6)}-${h(6, 8)}-${h(8, 10)}-${h(10, 16)}';
  }

  Future<LocalFamilySpace?> loadSpace() async {
    final raw = await _store.readJson(_spaceKey);
    if (raw is! Map) return null;
    return LocalFamilySpace.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> saveSpace(LocalFamilySpace space) => _store.writeJson(_spaceKey, space.toJson());

  Future<void> clearSpace() async {
    await _store.delete(_spaceKey);
    await _store.delete(_eventsKey);
    await _store.delete(_goalsKey);
  }

  // ── AGENDA BERSAMA & OFFLINE QUEUE (FAM-AC04) ───────────────────────────

  Future<List<FamilyAgendaItem>> loadEvents({bool includeDeleted = false}) async {
    final raw = await _store.readJson(_eventsKey);
    if (raw is! List) return const [];
    final list = [
      for (final e in raw)
        if (e is Map) FamilyAgendaItem.fromJson(Map<String, dynamic>.from(e)),
    ].where((e) => includeDeleted || !e.deleted).toList();
    list.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return list;
  }

  Future<List<FamilyAgendaItem>> pendingSyncEvents() async =>
      (await loadEvents(includeDeleted: true)).where((e) => e.syncState == FamilySyncState.pendingSync).toList();

  Future<FamilyAgendaItem> upsertEvent(FamilyAgendaItem item) async {
    final all = (await loadEvents(includeDeleted: true)).where((e) => e.id != item.id).toList();
    all.add(item);
    await _store.writeJson(_eventsKey, [for (final e in all) e.toJson()]);
    return item;
  }

  Future<void> replaceFromCloudEvents(List<Map<String, dynamic>> serverRows) async {
    final localAll = await loadEvents(includeDeleted: true);
    final pendingById = {
      for (final e in localAll)
        if (e.syncState == FamilySyncState.pendingSync || e.syncState == FamilySyncState.conflict) e.id: e,
    };
    final merged = <String, FamilyAgendaItem>{};
    for (final row in serverRows) {
      final id = '${row['id']}';
      final serverItem = FamilyAgendaItem(
        id: id,
        title: '${row['title'] ?? ''}',
        startsAt: DateTime.tryParse('${row['starts_at'] ?? ''}')?.toUtc() ?? DateTime.now().toUtc(),
        location: '${row['location'] ?? ''}',
        recurrence: '${row['recurrence'] ?? 'none'}',
        learningPath: row['learning_path'] as String?,
        version: (row['version'] as num?)?.toInt() ?? 1,
        syncState: FamilySyncState.synced,
        deleted: row['deleted_at'] != null,
      );
      if (pendingById.containsKey(id)) {
        final local = pendingById[id]!;
        merged[id] = local.version != serverItem.version
            ? local.copyWith(syncState: FamilySyncState.conflict, conflictServerTitle: serverItem.title)
            : local;
      } else {
        merged[id] = serverItem;
      }
    }
    for (final e in pendingById.entries) {
      merged.putIfAbsent(e.key, () => e.value);
    }
    await _store.writeJson(_eventsKey, [for (final e in merged.values) e.toJson()]);
  }

  // ── TARGET BELAJAR BERSAMA (FAM-06) ─────────────────────────────────────

  Future<List<FamilyLearningGoal>> loadGoals() async {
    final raw = await _store.readJson(_goalsKey);
    if (raw is! List) return const [];
    return [
      for (final g in raw)
        if (g is Map) FamilyLearningGoal.fromJson(Map<String, dynamic>.from(g)),
    ];
  }

  Future<List<FamilyLearningGoal>> saveGoal(FamilyLearningGoal goal) async {
    final list = (await loadGoals()).where((g) => g.id != goal.id).toList()..insert(0, goal);
    await _store.writeJson(_goalsKey, [for (final g in list) g.toJson()]);
    return list;
  }

  Future<List<FamilyLearningGoal>> deleteGoal(String id) async {
    final list = (await loadGoals()).where((g) => g.id != id).toList();
    await _store.writeJson(_goalsKey, [for (final g in list) g.toJson()]);
    return list;
  }

  // ── PROFIL ANAK LOKAL DI PERANGKAT WALI (FAM-08) ────────────────────────

  Future<List<LocalChildProfile>> loadLocalChildren() async {
    final raw = await _store.readJson(_childrenKey);
    if (raw is! List) return const [];
    return [
      for (final c in raw)
        if (c is Map) LocalChildProfile.fromJson(Map<String, dynamic>.from(c)),
    ];
  }

  Future<List<LocalChildProfile>> saveLocalChild(LocalChildProfile child) async {
    final list = (await loadLocalChildren()).where((c) => c.id != child.id).toList()..insert(0, child);
    await _store.writeJson(_childrenKey, [for (final c in list) c.toJson()]);
    return list;
  }

  Future<List<LocalChildProfile>> deleteLocalChild(String id) async {
    final list = (await loadLocalChildren()).where((c) => c.id != id).toList();
    await _store.writeJson(_childrenKey, [for (final c in list) c.toJson()]);
    return list;
  }
}

/// Draft permohonan Moeslim Services di perangkat Personal (SVC-03 / SVC-AC06).
class ServiceRequestDraft {
  final String id;
  final String mosqueSlug;
  final String mosqueName;
  final String definitionId;
  final String serviceTitle;
  final String idempotencyKey;
  final Map<String, String> answers;
  final DateTime updatedAt;

  const ServiceRequestDraft({
    required this.id,
    required this.mosqueSlug,
    required this.mosqueName,
    required this.definitionId,
    required this.serviceTitle,
    required this.idempotencyKey,
    required this.answers,
    required this.updatedAt,
  });

  Map<String, Object> toJson() => {
        'id': id,
        'mosqueSlug': mosqueSlug,
        'mosqueName': mosqueName,
        'definitionId': definitionId,
        'serviceTitle': serviceTitle,
        'idempotencyKey': idempotencyKey,
        'answers': answers,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory ServiceRequestDraft.fromJson(Map<String, dynamic> j) => ServiceRequestDraft(
        id: j['id'] as String? ?? FamilySpaceRepository.newUuidV4(),
        mosqueSlug: j['mosqueSlug'] as String? ?? '',
        mosqueName: j['mosqueName'] as String? ?? '',
        definitionId: j['definitionId'] as String? ?? '',
        serviceTitle: j['serviceTitle'] as String? ?? '',
        idempotencyKey: j['idempotencyKey'] as String? ?? FamilySpaceRepository.newUuidV4(),
        answers: Map<String, String>.from(
          ((j['answers'] as Map?) ?? const {}).map((k, v) => MapEntry('$k', '$v')),
        ),
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '')?.toUtc() ?? DateTime.now().toUtc(),
      );
}

/// Cache offline Ramadan Local, Kelas Masjid, dan Draft Moeslim Services (RAM-07 / SVC-03).
class CommunityCacheRepository {
  static const _ramadanPrefix = 'ramadan_local_cache_';
  static const _classesPrefix = 'mosque_classes_cache_';
  static const _draftsKey = 'service_request_drafts_v1';
  static const _remindersKey = 'ramadan_local_reminders_v1';

  final KeyValueStore _store;
  const CommunityCacheRepository(this._store);

  Future<void> saveRamadanCache(String slug, List<Map<String, dynamic>> events, DateTime syncedAt) =>
      _store.writeJson('$_ramadanPrefix$slug', {
        'syncedAt': syncedAt.toUtc().toIso8601String(),
        'events': events,
      });

  Future<({List<Map<String, dynamic>> events, DateTime syncedAt})?> loadRamadanCache(String slug) async {
    final raw = await _store.readJson('$_ramadanPrefix$slug');
    if (raw is! Map) return null;
    final at = DateTime.tryParse('${raw['syncedAt'] ?? ''}')?.toUtc();
    if (at == null) return null;
    final list = [
      for (final e in (raw['events'] as List? ?? const []))
        if (e is Map) Map<String, dynamic>.from(e),
    ];
    return (events: list, syncedAt: at);
  }

  Future<void> saveClassesCache(String slug, List<Map<String, dynamic>> classes, DateTime syncedAt) =>
      _store.writeJson('$_classesPrefix$slug', {
        'syncedAt': syncedAt.toUtc().toIso8601String(),
        'classes': classes,
      });

  Future<({List<Map<String, dynamic>> classes, DateTime syncedAt})?> loadClassesCache(String slug) async {
    final raw = await _store.readJson('$_classesPrefix$slug');
    if (raw is! Map) return null;
    final at = DateTime.tryParse('${raw['syncedAt'] ?? ''}')?.toUtc();
    if (at == null) return null;
    final list = [
      for (final e in (raw['classes'] as List? ?? const []))
        if (e is Map) Map<String, dynamic>.from(e),
    ];
    return (classes: list, syncedAt: at);
  }

  Future<Set<int>> savedReminderEventIds() async {
    final raw = await _store.readJson(_remindersKey);
    if (raw is! List) return {};
    return raw.map((e) => (e as num).toInt()).toSet();
  }

  Future<Set<int>> toggleReminderEvent(int eventId) async {
    final cur = await savedReminderEventIds();
    if (!cur.remove(eventId)) cur.add(eventId);
    await _store.writeJson(_remindersKey, cur.toList());
    return cur;
  }

  Future<List<ServiceRequestDraft>> loadServiceDrafts() async {
    final raw = await _store.readJson(_draftsKey);
    if (raw is! List) return const [];
    return [
      for (final d in raw)
        if (d is Map) ServiceRequestDraft.fromJson(Map<String, dynamic>.from(d)),
    ];
  }

  Future<List<ServiceRequestDraft>> saveServiceDraft(ServiceRequestDraft draft) async {
    final list = (await loadServiceDrafts()).where((d) => d.id != draft.id).toList()..insert(0, draft);
    await _store.writeJson(_draftsKey, [for (final d in list) d.toJson()]);
    return list;
  }

  Future<List<ServiceRequestDraft>> deleteServiceDraft(String id) async {
    final list = (await loadServiceDrafts()).where((d) => d.id != id).toList();
    await _store.writeJson(_draftsKey, [for (final d in list) d.toJson()]);
    return list;
  }
}
