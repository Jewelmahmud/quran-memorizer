import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selected_language';

  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  final List<Locale> supportedLocales = const [
    Locale('en', ''), // English
    Locale('ar', ''), // Arabic
    Locale('ur', ''), // Urdu
    Locale('fr', ''), // French
  ];

  final List<LanguageOption> languageOptions = const [
    LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    LanguageOption(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
    ),
    LanguageOption(
      code: 'ur',
      name: 'Urdu',
      nativeName: 'اردو',
      flag: '🇵🇰',
    ),
    LanguageOption(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
    ),
  ];

  Locale get currentLocale => _currentLocale;
  Locale _currentLocale = const Locale('en', '');

  /// Initialize the localization service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
    } else {
      // Try to get system language
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final supportedLocale = supportedLocales.firstWhere(
        (locale) => locale.languageCode == systemLocale.languageCode,
        orElse: () => const Locale('en', ''),
      );
      _currentLocale = supportedLocale;
    }
  }

  /// Change the app language
  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    _currentLocale = Locale(languageCode);
  }

  /// Get language option by code
  LanguageOption? getLanguageOption(String code) {
    try {
      return languageOptions.firstWhere((option) => option.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Check if language is RTL
  bool isRTL(String languageCode) {
    return languageCode == 'ar' || languageCode == 'ur';
  }

  /// Check if current language is RTL
  bool get isCurrentLanguageRTL => isRTL(_currentLocale.languageCode);
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}
