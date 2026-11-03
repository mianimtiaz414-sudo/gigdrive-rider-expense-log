import 'package:flutter/material.dart';

class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.isRtl,
  });

  final String code;
  final String englishName;
  final String nativeName;
  final bool isRtl;

  Locale get locale => Locale(code);
}

class AppLanguages {
  AppLanguages._();

  static const AppLanguage english = AppLanguage(
    code: 'en',
    englishName: 'English',
    nativeName: 'English',
    isRtl: false,
  );

  static const AppLanguage urdu = AppLanguage(
    code: 'ur',
    englishName: 'Urdu',
    nativeName: 'اردو',
    isRtl: true,
  );

  static const AppLanguage hindi = AppLanguage(
    code: 'hi',
    englishName: 'Hindi',
    nativeName: 'हिन्दी',
    isRtl: false,
  );

  static const AppLanguage arabic = AppLanguage(
    code: 'ar',
    englishName: 'Arabic',
    nativeName: 'العربية',
    isRtl: true,
  );

  static const List<AppLanguage> all = <AppLanguage>[
    english,
    urdu,
    hindi,
    arabic,
  ];

  static AppLanguage byCode(String code) {
    return all.firstWhere(
      (AppLanguage l) => l.code == code,
      orElse: () => english,
    );
  }
}
