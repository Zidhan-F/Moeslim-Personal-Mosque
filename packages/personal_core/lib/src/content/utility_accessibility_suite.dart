import '../storage/key_value_store.dart';
import '../storage/tracker_repository.dart';

// ================= 46. MODE LANSIA (SENIOR MODE / AKSESIBILITAS TINGGI) =================

class SeniorModeRepository {
  static const _key = 'senior_mode_enabled';
  final KeyValueStore _store;

  const SeniorModeRepository(this._store);

  Future<bool> isEnabled() async => (await _store.read(_key)) == 'true';

  Future<bool> setEnabled(bool enabled) async {
    await _store.write(_key, enabled ? 'true' : 'false');
    return enabled;
  }
}

// ================= 47. TIMER SESI TILAWAH, DZIKIR & I'TIKAF =================

enum WorshipFocusKind {
  tilawah('Fokus Tilawah Al-Qur\'an'),
  dzikir('Fokus Dzikir & Tadabbur'),
  itikaf('Sesi I\'tikaf & Doa');

  final String label;
  const WorshipFocusKind(this.label);
}

class WorshipTimerLog {
  final String id;
  final String dateKey;
  final WorshipFocusKind kind;
  final int durationMinutes;

  const WorshipTimerLog({
    required this.id,
    required this.dateKey,
    required this.kind,
    required this.durationMinutes,
  });

  Map<String, Object> toJson() => {
        'id': id,
        'dateKey': dateKey,
        'kind': kind.name,
        'durationMinutes': durationMinutes,
      };

  factory WorshipTimerLog.fromJson(Map<String, dynamic> j) {
    final kName = j['kind'] as String?;
    final kind = WorshipFocusKind.values.where((e) => e.name == kName).firstOrNull ?? WorshipFocusKind.tilawah;
    return WorshipTimerLog(
      id: j['id'] as String? ?? 't',
      dateKey: j['dateKey'] as String? ?? '',
      kind: kind,
      durationMinutes: ((j['durationMinutes'] as num?)?.toInt() ?? 15).clamp(1, 1440),
    );
  }
}

class WorshipTimerRepository {
  static const _key = 'worship_timer_logs';
  final KeyValueStore _store;

  const WorshipTimerRepository(this._store);

  Future<List<WorshipTimerLog>> allLogs() async {
    final raw = await _store.readJson(_key);
    if (raw is! List) return const [];
    return [
      for (final e in raw)
        if (e is Map) WorshipTimerLog.fromJson(Map<String, dynamic>.from(e)),
    ];
  }

  Future<List<WorshipTimerLog>> logSession({
    required DateTime now,
    required WorshipFocusKind kind,
    required int durationMinutes,
    TrackerRepository? trackerRepo,
  }) async {
    final list = (await allLogs()).toList();
    list.insert(
      0,
      WorshipTimerLog(
        id: '${now.microsecondsSinceEpoch}',
        dateKey: TrackerRepository.dayKey(now),
        kind: kind,
        durationMinutes: durationMinutes.clamp(1, 1440),
      ),
    );
    await _store.writeJson(_key, [for (final l in list) l.toJson()]);

    if (trackerRepo != null) {
      final todayItems = await trackerRepo.day(now);
      final targetItem = kind == WorshipFocusKind.tilawah ? TrackerItem.tilawah : TrackerItem.dzikir;
      if (!todayItems.contains(targetItem)) {
        await trackerRepo.toggle(now, targetItem);
      }
    }
    return list;
  }
}

// ================= 48. RINGKASAN REFLEKSI IBADAH BULANAN & TAHUNAN =================

class WorshipReflectionSummary {
  final int fullPrayerDaysLast30;
  final int totalTilawahPagesLast30;
  final int totalFastingDaysLogged;
  final int totalSedekahRupiahLogged;
  final int totalFocusMinutesLogged;
  final int currentPrayerStreak;
  final int bestPrayerStreak;

  const WorshipReflectionSummary({
    required this.fullPrayerDaysLast30,
    required this.totalTilawahPagesLast30,
    required this.totalFastingDaysLogged,
    required this.totalSedekahRupiahLogged,
    required this.totalFocusMinutesLogged,
    required this.currentPrayerStreak,
    required this.bestPrayerStreak,
  });
}

// ================= 49. REFERENSI KODE BAHAN PANGAN HALAL (E-NUMBER CHECKER) =================

enum HalalAdditiveStatus {
  halal('Halal'),
  syubhat('Syubhat (Wajib Cek Sertifikat Halal)'),
  haram('Haram');

  final String label;
  const HalalAdditiveStatus(this.label);
}

class ENumberAdditiveItem {
  final String code;
  final String name;
  final String functionInFood;
  final HalalAdditiveStatus status;
  final String sourceExplanation;

  const ENumberAdditiveItem({
    required this.code,
    required this.name,
    required this.functionInFood,
    required this.status,
    required this.sourceExplanation,
  });

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return code.toLowerCase().contains(q) ||
        name.toLowerCase().contains(q) ||
        functionInFood.toLowerCase().contains(q) ||
        sourceExplanation.toLowerCase().contains(q);
  }
}

const List<ENumberAdditiveItem> halalENumberCatalog = [
  ENumberAdditiveItem(
    code: 'E100',
    name: 'Kurkumin (Kunyit)',
    functionInFood: 'Pewarna kuning alami',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Berasal dari ekstrak rimpang kunyit nabati (Curcuma longa); halal dikonsumsi.',
  ),
  ENumberAdditiveItem(
    code: 'E120',
    name: 'Karmin / Cochineal (Asam Karminat)',
    functionInFood: 'Pewarna merah makanan & kosmetik',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Diekstrak dari serangga Cochineal. Terdapat perbedaan fatwa ulama; periksa logo Halal resmi pada kemasan.',
  ),
  ENumberAdditiveItem(
    code: 'E160a',
    name: 'Beta-Karoten',
    functionInFood: 'Pewarna oranye/kuning',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Pigmen alami dari wortel dan tumbuhan hijau (pastikan pelarut kapsul bukan gelatin non-halal).',
  ),
  ENumberAdditiveItem(
    code: 'E300',
    name: 'Asam Askorbat (Vitamin C)',
    functionInFood: 'Antioksidan & pengatur keasaman',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Berasal dari sintesis glukosa nabati; halal.',
  ),
  ENumberAdditiveItem(
    code: 'E322',
    name: 'Lesitin (Lecithin)',
    functionInFood: 'Pengemulsi cokelat, roti & susu',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Umumnya halal karena dari kacang kedelai (Soy Lecithin) atau bunga matahari, namun syubhat bila berasal dari lemak hewani tidak bersertifikat.',
  ),
  ENumberAdditiveItem(
    code: 'E330',
    name: 'Asam Sitrat (Citric Acid)',
    functionInFood: 'Pengatur keasaman minuman & permen',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Berasal dari buah jeruk atau fermentasi tetes tebu/tapioka; halal.',
  ),
  ENumberAdditiveItem(
    code: 'E406',
    name: 'Agar-Agar',
    functionInFood: 'Pembentuk gel & pengental',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: '100% nabati dari rumput laut merah; pengganti terbaik gelatin hewani.',
  ),
  ENumberAdditiveItem(
    code: 'E407',
    name: 'Karagenan',
    functionInFood: 'Pengental es krim & produk susu',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Ekstrak rumput laut alami; halal.',
  ),
  ENumberAdditiveItem(
    code: 'E422',
    name: 'Gliserol / Gliserin',
    functionInFood: 'Pemanis & pelembap makanan/obat',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Halal bila dari minyak nabati (kelapa sawit), namun haram/syubhat bila hasil sampingan hidrolisis lemak babi atau hewan tak disembelih syar\'i.',
  ),
  ENumberAdditiveItem(
    code: 'E441',
    name: 'Gelatin',
    functionInFood: 'Pembentuk gel permen kenyal, kapsul & marshmallow',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Titik kritis tinggi: berasal dari kolagen tulang/kulit hewan. Wajib memastikan bersertifikat Halal (sapi sembelihan syar\'i atau gelatin ikan).',
  ),
  ENumberAdditiveItem(
    code: 'E471',
    name: 'Mono- dan Digliserida Asam Lemak',
    functionInFood: 'Pengemulsi margarin, es krim & roti',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Dapat dibuat dari minyak nabati (halal) maupun lemak hewani (haram/syubhat). Pastikan produk berlabel Halal resmi.',
  ),
  ENumberAdditiveItem(
    code: 'E542',
    name: 'Fosfat Tulang (Edible Bone Phosphate)',
    functionInFood: 'Anti-kempal suplemen',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Berasal dari ekstrak tulang hewan; haram bila dari babi atau bangkai hewan yang tidak disembelih secara syar\'i.',
  ),
  ENumberAdditiveItem(
    code: 'E621',
    name: 'Mononatrium Glutamat (MSG)',
    functionInFood: 'Penguat rasa gurih (umami)',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Diproduksi melalui fermentasi bakteri atas tetes tebu/tapioka (periksa sertifikat halal untuk media enzim fermentasinya).',
  ),
  ENumberAdditiveItem(
    code: 'E904',
    name: 'Syelak (Shellac)',
    functionInFood: 'Pelapis mengilap permen & cokelat',
    status: HalalAdditiveStatus.halal,
    sourceExplanation: 'Resin alami yang disekresikan serangga Laccifer lacca (halal bila pelarut alkoholnya telah menguap/bersertifikat halal).',
  ),
  ENumberAdditiveItem(
    code: 'E920',
    name: 'L-Sistein (L-Cysteine)',
    functionInFood: 'Pelembut adonan tepung & roti',
    status: HalalAdditiveStatus.syubhat,
    sourceExplanation: 'Haram bila diekstrak dari rambut manusia; syubhat bila dari bulu unggas; halal bila dari fermentasi nabati/sintetis.',
  ),
  ENumberAdditiveItem(
    code: 'MIRIN',
    name: 'Mirin / Angciu / Rhum / Khamr Masak',
    functionInFood: 'Penyedap masakan beralkohol (khamr)',
    status: HalalAdditiveStatus.haram,
    sourceExplanation: 'Termasuk khamr (minuman beralkohol memabukkan) yang haram digunakan meskipun hanya sedikit dalam masakan.',
  ),
];

// ================= 50. PENGINGAT SUNNAH KONTEKSTUAL BERBASIS WAKTU =================

class ContextualSunnahAdvice {
  final String id;
  final String timeWindowLabel;
  final String title;
  final String subtitle;
  final String actionType; // 'dzikir_pagi' | 'dhuha' | 'alkahfi' | 'dzikir_petang' | 'almulk' | 'tahajud'

  const ContextualSunnahAdvice({
    required this.id,
    required this.timeWindowLabel,
    required this.title,
    required this.subtitle,
    required this.actionType,
  });
}

List<ContextualSunnahAdvice> evaluateContextualSunnahForTime(DateTime now) {
  final hour = now.hour;
  final isFridayOrThursdayNight =
      now.weekday == DateTime.friday || (now.weekday == DateTime.thursday && hour >= 18);

  final list = <ContextualSunnahAdvice>[];

  if (hour >= 3 && hour < 5) {
    list.add(const ContextualSunnahAdvice(
      id: 'tahajud_sahur',
      timeWindowLabel: 'Sepertiga Malam Terakhir & Sahur',
      title: 'Waktu Mustajab Tahajud, Witir & Istighfar Sahur',
      subtitle: 'Allah turun ke langit dunia mengabulkan doa dan mengampuni hamba yang memohon ampun di waktu sahur.',
      actionType: 'tahajud',
    ));
  } else if (hour >= 5 && hour < 8) {
    list.add(const ContextualSunnahAdvice(
      id: 'dzikir_pagi',
      timeWindowLabel: 'Waktu Pagi Ba\'da Subuh',
      title: 'Amalkan Dzikir Pagi & Sedekah Subuh',
      subtitle: 'Bentengi hari Anda dengan Ayat Kursi, Sayyidul Istighfar, dan dzikir pagi terpandu.',
      actionType: 'dzikir_pagi',
    ));
  } else if (hour >= 8 && hour < 11) {
    list.add(const ContextualSunnahAdvice(
      id: 'salat_dhuha',
      timeWindowLabel: 'Waktu Pagi Menjelang Siang',
      title: 'Saatnya Salat Sunnah Dhuha (2–8 Rakaat)',
      subtitle: 'Dua rakaat Dhuha mencukupi sedekah bagi 360 persendian tubuh Anda hari ini.',
      actionType: 'dhuha',
    ));
  } else if (hour >= 15 && hour < 18) {
    list.add(const ContextualSunnahAdvice(
      id: 'dzikir_petang',
      timeWindowLabel: 'Waktu Petang Ba\'da Ashar',
      title: 'Amalkan Dzikir Petang Terpandu',
      subtitle: 'Sempurnakan penjagaan sore dan malam hari dengan rangkaian dzikir petang shahih.',
      actionType: 'dzikir_petang',
    ));
  } else if (hour >= 20 || hour < 3) {
    list.add(const ContextualSunnahAdvice(
      id: 'almulk_muhasabah',
      timeWindowLabel: 'Menjelang Istirahat Malam',
      title: 'Baca Surah Al-Mulk, Berwudhu & Muhasabah',
      subtitle: 'Surah Al-Mulk (30 ayat) menjadi penyelamat dari siksa kubur, ditutup dengan evaluasi diri sebelum tidur.',
      actionType: 'almulk',
    ));
  } else {
    list.add(const ContextualSunnahAdvice(
      id: 'dzikrullah_siang',
      timeWindowLabel: 'Pertengahan Hari',
      title: 'Jaga Salat Tepat Waktu & Basahi Lisan dengan Dzikir',
      subtitle: 'Siapkan diri menyambut panggilan adzan Dzuhur/Ashar dan perbanyak istighfar di sela aktivitas.',
      actionType: 'dzikir_pagi',
    ));
  }

  if (isFridayOrThursdayNight) {
    list.insert(
      0,
      const ContextualSunnahAdvice(
        id: 'sunnah_jumat',
        timeWindowLabel: 'Keberkahan Malam & Hari Jumat',
        title: 'Baca Surah Al-Kahfi & Perbanyak Shalawat Nabi',
        subtitle: 'Hari terbaik di mana matahari terbit adalah hari Jumat. Jangan lewatkan Al-Kahfi, shalawat, dan doa akhir Ashar.',
        actionType: 'alkahfi',
      ),
    );
  }

  return list;
}
