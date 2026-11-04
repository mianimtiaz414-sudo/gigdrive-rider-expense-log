import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/data/local/shared_prefs.dart';
import 'package:rider_expense_tracker/data/remote/firebase_auth_service.dart';
import 'package:rider_expense_tracker/routes/app_routes.dart';
import 'package:rider_expense_tracker/view_models/expense_view_model.dart';
import 'package:rider_expense_tracker/view_models/settings_view_model.dart';

enum PinPurpose {
  login,
  setupCreate,
  settingsEnable,
  settingsChange,
  settingsDisable,
}

enum PinStage { verifyCurrent, enterNew, confirmNew }

class AuthViewModel extends GetxController {
  AuthViewModel(this._auth, this._settings);

  final FirebaseAuthService _auth;
  final SettingsViewModel _settings;

  static const int pinLength = 4;

  final RxString pin = ''.obs;
  final RxString errorText = ''.obs;
  final Rx<PinStage> stage = PinStage.enterNew.obs;
  final Rx<PinPurpose> purpose = PinPurpose.login.obs;

  final RxBool isLoading = false.obs;
  final Rxn<User> firebaseUser = Rxn<User>();

  String _firstPin = '';
  bool _busy = false;
  bool _loggingOut = false;
  Worker? _pinWorker;

  bool get isSignedIn => firebaseUser.value != null;
  bool get isCloudAvailable => _auth.isAvailable;
  String get userEmail => firebaseUser.value?.email ?? '';

  String get title {
    switch (stage.value) {
      case PinStage.verifyCurrent:
        return purpose.value == PinPurpose.login
            ? 'welcome_back'.tr
            : 'enter_current_pin'.tr;
      case PinStage.enterNew:
        return purpose.value == PinPurpose.settingsChange
            ? 'new_pin'.tr
            : 'create_pin'.tr;
      case PinStage.confirmNew:
        return 'confirm_pin'.tr;
    }
  }

  String get subtitle {
    switch (stage.value) {
      case PinStage.verifyCurrent:
        return purpose.value == PinPurpose.login
            ? 'enter_pin_unlock'.tr
            : 'enter_current_pin_sub'.tr;
      case PinStage.enterNew:
        return purpose.value == PinPurpose.settingsChange
            ? 'new_pin_sub'.tr
            : 'create_pin_sub'.tr;
      case PinStage.confirmNew:
        return 'confirm_pin_sub'.tr;
    }
  }

  @override
  void onInit() {
    super.onInit();
    firebaseUser.value = _auth.currentUser;
    firebaseUser.bindStream(_auth.authStateChanges);
    _pinWorker = ever<String>(pin, (String value) {
      _processPin(value);
    });
  }

  @override
  void onClose() {
    _pinWorker?.dispose();
    super.onClose();
  }

  String resolveStartRoute() {
    if (!SharedPrefs.isOnboardingDone) {
      return AppRoutes.onboarding;
    }
    if (!SharedPrefs.isSetupDone) {
      return AppRoutes.setup;
    }
    if (SharedPrefs.isLockActive) {
      return AppRoutes.loginPasscode;
    }
    if (!SharedPrefs.isSessionActive) {
      return AppRoutes.login;
    }
    return AppRoutes.dashboard;
  }

  Future<void> completeOnboarding() async {
    await SharedPrefs.setOnboardingDone(true);
    Get.offAllNamed(resolveStartRoute());
  }

  bool _needsVerification(PinPurpose p) {
    return p == PinPurpose.login ||
        p == PinPurpose.settingsChange ||
        p == PinPurpose.settingsDisable;
  }

  void startPinFlow(PinPurpose p) {
    purpose.value = p;
    _firstPin = '';
    _busy = false;
    errorText.value = '';
    pin.value = '';
    stage.value =
        _needsVerification(p) ? PinStage.verifyCurrent : PinStage.enterNew;
  }

  void onDigit(String digit) {
    if (_busy || pin.value.length >= pinLength) {
      return;
    }
    errorText.value = '';
    pin.value = pin.value + digit;
  }

  void deleteLastDigit() {
    if (_busy || pin.value.isEmpty) {
      return;
    }
    pin.value = pin.value.substring(0, pin.value.length - 1);
  }

  Future<void> _processPin(String value) async {
    if (value.length != pinLength || _busy) {
      return;
    }
    _busy = true;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    try {
      switch (stage.value) {
        case PinStage.verifyCurrent:
          await _handleVerify(value);
          break;
        case PinStage.enterNew:
          _firstPin = value;
          errorText.value = '';
          stage.value = PinStage.confirmNew;
          pin.value = '';
          break;
        case PinStage.confirmNew:
          await _handleConfirm(value);
          break;
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> _handleVerify(String value) async {
    if (!SharedPrefs.verifyPin(value)) {
      HapticFeedback.heavyImpact();
      errorText.value = 'pin_incorrect'.tr;
      pin.value = '';
      return;
    }

    switch (purpose.value) {
      case PinPurpose.login:
        Get.offAllNamed(
          SharedPrefs.isSessionActive ? AppRoutes.dashboard : AppRoutes.login,
        );
        break;
      case PinPurpose.settingsDisable:
        await SharedPrefs.clearPin();
        await _settings.applyLockState(false);
        Get.back(result: true);
        AppFeedback.show('security_pin'.tr, 'pin_lock_off_done'.tr);
        break;
      case PinPurpose.settingsChange:
        errorText.value = '';
        stage.value = PinStage.enterNew;
        pin.value = '';
        break;
      case PinPurpose.setupCreate:
      case PinPurpose.settingsEnable:
        break;
    }
  }

  Future<void> _handleConfirm(String value) async {
    if (value != _firstPin) {
      HapticFeedback.heavyImpact();
      errorText.value = 'pin_mismatch'.tr;
      _firstPin = '';
      stage.value = PinStage.enterNew;
      pin.value = '';
      return;
    }

    await SharedPrefs.savePin(value);
    if (purpose.value != PinPurpose.settingsChange) {
      await _settings.applyLockState(true);
    }

    switch (purpose.value) {
      case PinPurpose.setupCreate:
        await _settings.markSetupDone();
        Get.offAllNamed(AppRoutes.dashboard);
        AppFeedback.show('pin_created'.tr, 'pin_created_msg'.tr);
        break;
      case PinPurpose.settingsEnable:
        Get.back(result: true);
        AppFeedback.show('pin_created'.tr, 'pin_created_msg'.tr);
        break;
      case PinPurpose.settingsChange:
        Get.back(result: true);
        AppFeedback.show('pin_changed'.tr, 'pin_changed_msg'.tr);
        break;
      case PinPurpose.login:
      case PinPurpose.settingsDisable:
        break;
    }
  }

  Future<bool> signInWithEmail(String email, String password) {
    return _runAuth(() => _auth.signInWithEmail(email, password));
  }

  Future<bool> registerWithEmail(String email, String password) {
    return _runAuth(() => _auth.registerWithEmail(email, password));
  }

  Future<bool> signInWithGoogle() {
    return _runAuth(() => _auth.signInWithGoogle());
  }

  Future<void> finishLogin() async {
    await SharedPrefs.setSessionActive(true);
    Get.offAllNamed(AppRoutes.dashboard);
    if (isSignedIn) {
      unawaited(Get.find<ExpenseViewModel>().syncWithCloud(silent: true));
    }
  }

  Future<void> clearSessionAndGoToAuth() async {
    if (_loggingOut) return;

    final expenseVM = Get.find<ExpenseViewModel>();

    expenseVM.showInterstitialAd(onAdDismissed: () async {
      _loggingOut = true;
      isLoading.value = true;
      try {
        if (isSignedIn) {
          final bool safe = await expenseVM.backupAndClearLocalData();
          if (!safe) {
            AppFeedback.show('backup_failed_title'.tr, 'backup_failed_msg'.tr,
                isError: true);
            return;
          }
        }

        await _auth.signOut();
        firebaseUser.value = null;
        await SharedPrefs.clearSession();

        Get.offAllNamed(AppRoutes.login);
        AppFeedback.show('signed_out'.tr, 'signed_out_msg'.tr);
      } catch (e) {
        AppFeedback.show('something_wrong'.tr, e.toString(), isError: true);
      } finally {
        isLoading.value = false;
        _loggingOut = false;
      }
    });
  }

  Future<void> signOut() => clearSessionAndGoToAuth();

  Future<bool> _runAuth(Future<UserCredential?> Function() action) async {
    isLoading.value = true;
    try {
      final UserCredential? credential = await action();
      if (credential == null) {
        return false;
      }
      firebaseUser.value = credential.user;
      return true;
    } on FirebaseAuthException catch (e) {
      AppFeedback.show('auth_failed'.tr, e.message ?? e.code, isError: true);
      return false;
    } catch (e) {
      AppFeedback.show('something_wrong'.tr, e.toString(), isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
