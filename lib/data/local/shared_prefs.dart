import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs._();

  static late SharedPreferences _prefs;

  static const String _kPinHash = 'pin_hash';
  static const String _kOnboardingDone = 'onboarding_done';
  static const String _kSetupDone = 'setup_done';
  static const String _kSetupStep = 'setup_step';
  static const String _kSessionActive = 'session_active';
  static const String _kLegacyMigrated = 'legacy_migrated';
  static const String _kDarkTheme = 'is_dark_theme';
  static const String _kLanguage = 'language_code';
  static const String _kCurrencyCode = 'currency_code';
  static const String _kCurrencyCountry = 'currency_country';
  static const String _kLockEnabled = 'lock_enabled';
  static const String _kUpdatedAt = 'settings_updated_at';
  static const String _kDirty = 'settings_dirty';

  static const String defaultLanguage = 'en';
  static const String defaultCurrencyCode = 'USD';
  static const String defaultCurrencyCountry = 'US';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _migrateLegacy();
  }

  static Future<void> _migrateLegacy() async {
    if (_prefs.getBool(_kLegacyMigrated) ?? false) {
      return;
    }
    if (!_prefs.containsKey(_kLockEnabled) && hasPin) {
      await _prefs.setBool(_kLockEnabled, true);
    }
    if (!_prefs.containsKey(_kSetupDone) && isOnboardingDone) {
      await _prefs.setBool(_kSetupDone, true);
    }
    if (!_prefs.containsKey(_kSessionActive) && isSetupDone) {
      await _prefs.setBool(_kSessionActive, true);
    }
    await _prefs.setBool(_kLegacyMigrated, true);
  }

  static bool get isOnboardingDone => _prefs.getBool(_kOnboardingDone) ?? false;

  static Future<void> setOnboardingDone(bool value) async {
    await _prefs.setBool(_kOnboardingDone, value);
  }

  static bool get isSetupDone => _prefs.getBool(_kSetupDone) ?? false;

  static Future<void> setSetupDone(bool value) async {
    await _prefs.setBool(_kSetupDone, value);
  }

  static int get setupStep => _prefs.getInt(_kSetupStep) ?? 0;

  static Future<void> setSetupStep(int value) async {
    await _prefs.setInt(_kSetupStep, value);
  }

  static bool get isSessionActive => _prefs.getBool(_kSessionActive) ?? false;

  static Future<void> setSessionActive(bool value) async {
    await _prefs.setBool(_kSessionActive, value);
  }

  static Future<void> clearSession() async {
    await _prefs.setBool(_kSessionActive, false);
  }

  static bool get isDarkTheme => _prefs.getBool(_kDarkTheme) ?? true;

  static Future<void> setDarkTheme(bool value) async {
    await _prefs.setBool(_kDarkTheme, value);
  }

  static String get languageCode =>
      _prefs.getString(_kLanguage) ?? defaultLanguage;

  static String get currencyCode =>
      _prefs.getString(_kCurrencyCode) ?? defaultCurrencyCode;

  static String get currencyCountry =>
      _prefs.getString(_kCurrencyCountry) ?? defaultCurrencyCountry;

  static bool get isLockEnabled => _prefs.getBool(_kLockEnabled) ?? false;

  static bool get isLockActive => isLockEnabled && hasPin;

  static int get settingsUpdatedAt => _prefs.getInt(_kUpdatedAt) ?? 0;

  static bool get settingsDirty => _prefs.getBool(_kDirty) ?? false;

  static Future<void> setSettingsDirty(bool value) async {
    await _prefs.setBool(_kDirty, value);
  }

  static Future<void> _touch() async {
    await _prefs.setInt(_kUpdatedAt, DateTime.now().millisecondsSinceEpoch);
    await _prefs.setBool(_kDirty, true);
  }

  static Future<void> setLanguageCode(String code) async {
    await _prefs.setString(_kLanguage, code);
    await _touch();
  }

  static Future<void> setCurrency({
    required String countryCode,
    required String currencyCode,
  }) async {
    await _prefs.setString(_kCurrencyCountry, countryCode);
    await _prefs.setString(_kCurrencyCode, currencyCode);
    await _touch();
  }

  static Future<void> setLockEnabled(bool value) async {
    await _prefs.setBool(_kLockEnabled, value);
    await _touch();
  }

  static Map<String, dynamic> settingsToMap() {
    return <String, dynamic>{
      'languageCode': languageCode,
      'currencyCode': currencyCode,
      'currencyCountry': currencyCountry,
      'lockEnabled': isLockActive,
      'updatedAt': settingsUpdatedAt,
    };
  }

  static Future<void> applyRemoteSettings({
    required String languageCode,
    required String currencyCountry,
    required String currencyCode,
    required bool lockEnabled,
    required int updatedAt,
  }) async {
    await _prefs.setString(_kLanguage, languageCode);
    await _prefs.setString(_kCurrencyCountry, currencyCountry);
    await _prefs.setString(_kCurrencyCode, currencyCode);

    final bool lock = hasPin && (isLockEnabled || lockEnabled);
    await _prefs.setBool(_kLockEnabled, lock);

    final bool diverged = lock != lockEnabled;
    await _prefs.setInt(
      _kUpdatedAt,
      diverged ? DateTime.now().millisecondsSinceEpoch : updatedAt,
    );
    await _prefs.setBool(_kDirty, diverged);
  }

  static bool get hasPin => (_prefs.getString(_kPinHash) ?? '').isNotEmpty;

  static Future<void> savePin(String pin) async {
    await _prefs.setString(_kPinHash, _hash(pin));
  }

  static bool verifyPin(String pin) {
    final String? stored = _prefs.getString(_kPinHash);
    if (stored == null || stored.isEmpty) {
      return false;
    }
    return stored == _hash(pin);
  }

  static Future<void> clearPin() async {
    await _prefs.remove(_kPinHash);
  }

  static String _hash(String pin) {
    final List<int> bytes = utf8.encode('rider_ledger_salt_v1_$pin');
    return sha256.convert(bytes).toString();
  }
}
