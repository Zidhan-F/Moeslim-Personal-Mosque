import 'package:shared_prayer/shared_prayer.dart';

/// Pilih teks sesuai bahasa aktif (`id` = Bahasa Indonesia, `en` = English).
String tr(AppLanguage lang, String id, String en) => lang == AppLanguage.en ? en : id;
