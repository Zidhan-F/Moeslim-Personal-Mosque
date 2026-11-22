import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_core/personal_core.dart';
import 'package:shared_prayer/shared_prayer.dart';

import 'format.dart';
import 'providers.dart';

/// Bahasa aktif aplikasi (diambil dari [settingsProvider], default Bahasa Indonesia).
final appLanguageProvider = Provider<AppLanguage>(
  (ref) => ref.watch(settingsProvider.select((v) => v.value?.language ?? AppLanguage.id)),
);

/// InheritedWidget agar seluruh halaman (termasuk StatelessWidget) otomatis membangun ulang
/// saat bahasa diganti antara `id` dan `en`.
class AppLangScope extends InheritedWidget {
  final AppLanguage language;

  const AppLangScope({
    super.key,
    required this.language,
    required super.child,
  });

  static AppLanguage of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLangScope>();
    return scope?.language ?? AppLanguage.id;
  }

  static AppLanguage read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppLangScope>();
    return scope?.language ?? AppLanguage.id;
  }

  @override
  bool updateShouldNotify(AppLangScope oldWidget) => oldWidget.language != language;
}

/// Ekstensi ringkas pada [BuildContext] untuk seluruh teks UI dwibahasa (`id` / `en`).
extension AppLangContext on BuildContext {
  AppLanguage get lang => AppLangScope.of(this);
  bool get isEn => lang == AppLanguage.en;
  String tr(String id, String en) => lang == AppLanguage.en ? en : id;

  String prayerLabel(Prayer p) => p.labelFor(lang);
  String methodLabel(CalculationMethod m) => m.labelFor(lang);
  String madhabLabel(AsrMadhab m) => m.labelFor(lang);
  String hijriText(HijriDate h) => h.format(lang);
  String surahRev(Surah s) => s.revelationFor(lang);
  String longDateText(DateTime d) => longDate(d, lang: lang);
  String shortDateText(DateTime d) => shortDate(d, lang: lang);
}

/// Ekstensi ringkas pada [WidgetRef] untuk callback async atau di luar build.
extension AppLangRef on WidgetRef {
  AppLanguage get lang => watch(appLanguageProvider);
  AppLanguage get readLang => read(appLanguageProvider);
  String tr(String id, String en) => lang == AppLanguage.en ? en : id;
}
