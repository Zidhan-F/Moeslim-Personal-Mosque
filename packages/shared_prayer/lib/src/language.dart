/// Pilihan bahasa aplikasi untuk ekosistem Moeslim PM (`id` = Bahasa Indonesia, `en` = English).
enum AppLanguage {
  id('id', 'Bahasa Indonesia', 'Indonesian'),
  en('en', 'English', 'English');

  final String code;
  final String nativeName;
  final String englishName;
  const AppLanguage(this.code, this.nativeName, this.englishName);

  bool get isEnglish => this == AppLanguage.en;
  bool get isIndonesian => this == AppLanguage.id;

  String labelFor(AppLanguage current) => switch (this) {
    AppLanguage.id => current == AppLanguage.en ? 'Indonesian' : 'Indonesia',
    AppLanguage.en => current == AppLanguage.en ? 'English' : 'Inggris',
  };

  static AppLanguage fromCode(String? code) => switch (code?.trim().toLowerCase()) {
    'en' || 'en_us' || 'en-us' || 'en_gb' || 'en-gb' => AppLanguage.en,
    _ => AppLanguage.id,
  };
}
