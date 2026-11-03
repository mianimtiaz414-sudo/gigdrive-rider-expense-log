import 'package:get/get.dart';
import 'package:rider_expense_tracker/data/local/shared_prefs.dart';
import 'package:rider_expense_tracker/data/local/translation_service.dart';
import 'package:rider_expense_tracker/data/models/app_language.dart';
import 'package:rider_expense_tracker/data/models/country_currency.dart';
import 'package:rider_expense_tracker/data/repositories/settings_repository.dart';
import 'package:rider_expense_tracker/routes/app_routes.dart';

class SettingsViewModel extends GetxController {
  SettingsViewModel(this._repository);

  final SettingsRepository _repository;

  final RxString languageCode = SharedPrefs.languageCode.obs;
  final RxString currencyCountry = SharedPrefs.currencyCountry.obs;
  final RxBool lockEnabled = SharedPrefs.isLockActive.obs;

  AppLanguage get language => AppLanguages.byCode(languageCode.value);

  CurrencyOption get currency =>
      CurrencyCatalog.byCountry(currencyCountry.value);

  
  String get currencySymbol => currency.displaySymbol;

  
  Future<void> setLanguage(AppLanguage lang) async {
    languageCode.value = lang.code;
    await SharedPrefs.setLanguageCode(lang.code);
    Get.updateLocale(lang.locale);
    _repository.pushInBackground();
  }

  
  Future<void> setCurrency(CurrencyOption option) async {
    currencyCountry.value = option.countryCode;
    await SharedPrefs.setCurrency(
      countryCode: option.countryCode,
      currencyCode: option.currencyCode,
    );
    _repository.pushInBackground();
  }

  
  Future<void> applyLockState(bool enabled) async {
    lockEnabled.value = enabled;
    await SharedPrefs.setLockEnabled(enabled);
    _repository.pushInBackground();
  }

  
  
  Future<void> markSetupDone() async {
    await SharedPrefs.setSetupDone(true);
    await SharedPrefs.setSessionActive(true);
  }

  
  Future<void> skipSecurityAndFinish() async {
    await SharedPrefs.clearPin();
    await applyLockState(false);
    await markSetupDone();
    Get.offAllNamed<void>(AppRoutes.dashboard);
  }

  
  
  Future<void> syncFromCloud() async {
    final bool changed = await _repository.reconcile();
    if (!changed) {
      return;
    }
    languageCode.value = SharedPrefs.languageCode;
    currencyCountry.value = SharedPrefs.currencyCountry;
    lockEnabled.value = SharedPrefs.isLockActive;
    Get.updateLocale(TranslationService.localeFor(languageCode.value));
  }
}
