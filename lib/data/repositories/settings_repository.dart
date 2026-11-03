import 'dart:async';

import 'package:rider_expense_tracker/data/local/shared_prefs.dart';
import 'package:rider_expense_tracker/data/models/app_language.dart';
import 'package:rider_expense_tracker/data/models/country_currency.dart';
import 'package:rider_expense_tracker/data/remote/firebase_auth_service.dart';
import 'package:rider_expense_tracker/data/remote/firebase_db_service.dart';



class SettingsRepository {
  SettingsRepository({
    required FirebaseDbService db,
    required FirebaseAuthService auth,
  })  : _db = db,
        _auth = auth;

  final FirebaseDbService _db;
  final FirebaseAuthService _auth;

  bool get isCloudReady => _auth.isAvailable && _auth.uid != null;

  
  void pushInBackground() {
    unawaited(pushSettings());
  }

  
  Future<bool> pushSettings() async {
    final String? uid = _auth.uid;
    if (uid == null || !_db.isAvailable) {
      return false;
    }
    try {
      await _db.saveSettings(uid, SharedPrefs.settingsToMap());
      await SharedPrefs.setSettingsDirty(false);
      return true;
    } catch (_) {
      
      return false;
    }
  }

  
  
  Future<bool> reconcile() async {
    final String? uid = _auth.uid;
    if (uid == null || !_db.isAvailable) {
      return false;
    }
    try {
      final Map<String, dynamic>? remote = await _db.fetchSettings(uid);
      if (remote == null) {
        await pushSettings();
        return false;
      }

      final int remoteAt = (remote['updatedAt'] as num?)?.toInt() ?? 0;
      if (remoteAt > SharedPrefs.settingsUpdatedAt) {
        final AppLanguage lang = AppLanguages.byCode(
          (remote['languageCode'] as String?) ?? SharedPrefs.defaultLanguage,
        );
        final CurrencyOption currency = CurrencyCatalog.byCountry(
          (remote['currencyCountry'] as String?) ??
              SharedPrefs.defaultCurrencyCountry,
        );
        await SharedPrefs.applyRemoteSettings(
          languageCode: lang.code,
          currencyCountry: currency.countryCode,
          currencyCode: currency.currencyCode,
          lockEnabled: (remote['lockEnabled'] as bool?) ?? false,
          updatedAt: remoteAt,
        );
        if (SharedPrefs.settingsDirty) {
          await pushSettings();
        }
        return true;
      }

      if (SharedPrefs.settingsDirty ||
          remoteAt < SharedPrefs.settingsUpdatedAt) {
        await pushSettings();
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
