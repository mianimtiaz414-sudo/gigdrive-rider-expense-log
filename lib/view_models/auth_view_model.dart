import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/data/local/hive_storage_service.dart';
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
  resetCreate,
}

enum PinStage { verifyCurrent, enterNew, confirmNew }

enum ForgotPinRoute { password, google, signedOut }

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

  bool get isSignedIn => firebaseUser.value != null;
  bool get isCloudAvailable => _auth.isAvailable;
  String get userEmail => firebaseUser.value?.email ?? '';

  ForgotPinRoute get forgotPinRoute {
    if (!isSignedIn) {
      return ForgotPinRoute.signedOut;
    }
    if (_auth.usesPasswordProvider) {
      return ForgotPinRoute.password;
    }
    return ForgotPinRoute.google;
  }

  String get title {
    switch (stage.value) {
      case PinStage.verifyCurrent:
        return purpose.value == PinPurpose.login
            ? 'welcome_back'.tr
            : 'enter_current_pin'.tr;
      case PinStage.enterNew:
        {
          final PinPurpose p = purpose.value;
          return (p == PinPurpose.settingsChange || p == PinPurpose.resetCreate)
              ? 'new_pin'.tr
              : 'create_pin'.tr;
        }
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
        {
          final PinPurpose p = purpose.value;
          if (p == PinPurpose.resetCreate) {
            return 'forgot_pin_ready_msg'.tr;
          }
          return p == PinPurpose.settingsChange
              ? 'new_pin_sub'.tr
              : 'create_pin_sub'.tr;
        }
      case PinStage.confirmNew:
        return 'confirm_pin_sub'.tr;
    }
  }

  @override
  void onInit() {
    super.onInit();
    firebaseUser.value = _auth.currentUser;
    firebaseUser.bindStream(_auth.authStateChanges);
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
    _firstPin = '';
    _busy = false;
    errorText.value = '';
    pin.value = '';
    purpose.value = p;
    stage.value =
        _needsVerification(p) ? PinStage.verifyCurrent : PinStage.enterNew;
  }

  void onDigit(String digit) {
    if (_busy || pin.value.length >= pinLength) {
      return;
    }
    errorText.value = '';
    pin.value = pin.value + digit;
    if (pin.value.length == pinLength) {
      unawaited(_submit());
    }
  }

  void deleteLastDigit() {
    if (_busy || pin.value.isEmpty) {
      return;
    }
    pin.value = pin.value.substring(0, pin.value.length - 1);
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    _busy = true;
    final String value = pin.value;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 150));
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
    } catch (e) {
      pin.value = '';
      AppFeedback.show('something_wrong'.tr, e.toString(), isError: true);
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
        pin.value = '';
        Get.offAllNamed(
          SharedPrefs.isSessionActive ? AppRoutes.dashboard : AppRoutes.login,
        );
        break;
      case PinPurpose.settingsDisable:
        await SharedPrefs.clearPin();
        await _settings.applyLockState(false);
        pin.value = '';
        Get.back();
        AppFeedback.show('security_pin'.tr, 'pin_lock_off_done'.tr);
        break;
      case PinPurpose.settingsChange:
        errorText.value = '';
        stage.value = PinStage.enterNew;
        pin.value = '';
        break;
      case PinPurpose.setupCreate:
      case PinPurpose.settingsEnable:
      case PinPurpose.resetCreate:
        pin.value = '';
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
    _firstPin = '';
    pin.value = '';

    switch (purpose.value) {
      case PinPurpose.setupCreate:
        await _settings.applyLockState(true);
        await _settings.markSetupDone();
        Get.offAllNamed(AppRoutes.dashboard);
        AppFeedback.show('pin_created'.tr, 'pin_created_msg'.tr);
        break;
      case PinPurpose.settingsEnable:
        await _settings.applyLockState(true);
        Get.back();
        AppFeedback.show('pin_created'.tr, 'pin_created_msg'.tr);
        break;
      case PinPurpose.settingsChange:
        Get.back();
        AppFeedback.show('pin_changed'.tr, 'pin_changed_msg'.tr);
        break;
      case PinPurpose.resetCreate:
        await _settings.applyLockState(true);
        Get.offAllNamed(
          SharedPrefs.isSessionActive ? AppRoutes.dashboard : AppRoutes.login,
        );
        AppFeedback.show('pin_created'.tr, 'pin_created_msg'.tr);
        break;
      case PinPurpose.login:
      case PinPurpose.settingsDisable:
        break;
    }
  }

  Future<void> _beginPinRecreation() async {
    await SharedPrefs.clearPin();
    await _settings.applyLockState(false);
    startPinFlow(PinPurpose.resetCreate);
  }

  Future<void> _runVerification(Future<bool> Function() action) async {
    if (isLoading.value) {
      return;
    }
    isLoading.value = true;
    try {
      final bool verified = await action();
      if (!verified) {
        return;
      }
      await _beginPinRecreation();
      AppFeedback.show('forgot_pin_ready_title'.tr, 'forgot_pin_ready_msg'.tr);
    } on FirebaseAuthException catch (e) {
      final bool badCredential = e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-login-credentials';
      AppFeedback.show(
        'auth_failed'.tr,
        badCredential ? 'forgot_pin_verify_failed'.tr : (e.message ?? e.code),
        isError: true,
      );
    } catch (e) {
      AppFeedback.show('something_wrong'.tr, e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPinWithPassword(String password) {
    return _runVerification(() async {
      await _auth.reauthWithPassword(password);
      return true;
    });
  }

  Future<void> resetPinWithGoogle() {
    return _runVerification(() => _auth.reauthWithGoogle());
  }

  Future<void> eraseDataAndResetPin() {
    return _runVerification(() async {
      await Get.find<HiveStorageService>().clearAll();
      Get.find<ExpenseViewModel>().loadLogs();
      return true;
    });
  }

  Future<void> sendPasswordReset(String email) async {
    if (isLoading.value) {
      return;
    }
    final String clean = email.trim();
    if (!GetUtils.isEmail(clean)) {
      AppFeedback.show(
        'forgot_password_need_title'.tr,
        'forgot_password_need_msg'.tr,
        isError: true,
      );
      return;
    }
    isLoading.value = true;
    try {
      await _auth.sendPasswordReset(clean);
      AppFeedback.show(
        'forgot_password_sent_title'.tr,
        'forgot_password_sent_msg'.trParams(<String, String>{'email': clean}),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        AppFeedback.show(
          'forgot_password_sent_title'.tr,
          'forgot_password_sent_msg'.trParams(<String, String>{'email': clean}),
        );
      } else {
        AppFeedback.show('auth_failed'.tr, e.message ?? e.code, isError: true);
      }
    } catch (e) {
      AppFeedback.show('something_wrong'.tr, e.toString(), isError: true);
    } finally {
      isLoading.value = false;
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

  Future<void> submitEmail({
    required String email,
    required String password,
    required bool register,
  }) async {
    if (isLoading.value) {
      return;
    }
    final String cleanEmail = email.trim();
    if (!GetUtils.isEmail(cleanEmail) || password.length < 6) {
      AppFeedback.show(
        'check_details'.tr,
        'check_details_msg'.tr,
        isError: true,
      );
      return;
    }
    final bool ok = register
        ? await registerWithEmail(cleanEmail, password)
        : await signInWithEmail(cleanEmail, password);
    if (ok) {
      await finishLogin();
    }
  }

  Future<void> submitGoogle() async {
    if (isLoading.value) {
      return;
    }
    final bool ok = await signInWithGoogle();
    if (ok) {
      await finishLogin();
    }
  }

  Future<void> continueOffline() async {
    if (isLoading.value) {
      return;
    }
    await finishLogin();
  }

  Future<void> finishLogin() async {
    await SharedPrefs.setSessionActive(true);
    Get.offAllNamed(AppRoutes.dashboard);
    if (isSignedIn) {
      unawaited(Get.find<ExpenseViewModel>().syncWithCloud(silent: true));
    }
  }

  Future<void> clearSessionAndGoToAuth() async {
    if (isLoading.value) {
      return;
    }
    isLoading.value = true;
    try {
      if (isSignedIn) {
        final bool safe =
            await Get.find<ExpenseViewModel>().backupAndClearLocalData();
        if (!safe) {
          AppFeedback.show(
            'backup_failed_title'.tr,
            'backup_failed_msg'.tr,
            isError: true,
          );
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
    }
  }

  Future<void> signOut() => clearSessionAndGoToAuth();

  Future<bool> _runAuth(Future<UserCredential?> Function() action) async {
    if (isLoading.value) {
      return false;
    }
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
      final String message = e.toString();
      if (message.contains('ApiException: 10')) {
        AppFeedback.show('auth_failed'.tr, 'google_error_10'.tr, isError: true);
      } else {
        AppFeedback.show('something_wrong'.tr, message, isError: true);
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
