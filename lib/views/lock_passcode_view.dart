import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/view_models/auth_view_model.dart';
import 'package:rider_expense_tracker/views/wigdets/password_confirm_dialog.dart';
import 'package:rider_expense_tracker/views/wigdets/pin_widgets.dart';

class LockPasscodeView extends StatefulWidget {
  const LockPasscodeView({super.key, this.purpose = PinPurpose.login});

  final PinPurpose purpose;

  @override
  State<LockPasscodeView> createState() => _LockPasscodeViewState();
}

class _LockPasscodeViewState extends State<LockPasscodeView> {
  final AuthViewModel controller = Get.find<AuthViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.startPinFlow(widget.purpose);
      }
    });
  }

  void _confirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      middleText: message,
      middleTextStyle: const TextStyle(
        fontSize: 14.5,
        height: 1.45,
        color: AppColors.textSecondary,
      ),
      backgroundColor: AppColors.surface,
      radius: 20,
      barrierDismissible: true,
      cancel: OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: const Size(112, 46)),
        onPressed: () => Get.back(),
        child: Text(
          'cancel'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(112, 46),
          backgroundColor: AppColors.expense,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Get.back();
          onConfirm();
        },
        child: Text(
          confirmLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _onForgotPin() {
    if (controller.isLoading.value) {
      return;
    }
    switch (controller.forgotPinRoute) {
      case ForgotPinRoute.password:
        Get.dialog(
          PasswordConfirmDialog(
            title: 'forgot_pin_password_title'.tr,
            message: 'forgot_pin_password_msg'
                .trParams(<String, String>{'email': controller.userEmail}),
            onSubmit: controller.resetPinWithPassword,
          ),
        );
        break;
      case ForgotPinRoute.google:
        _confirmDialog(
          title: 'forgot_pin_password_title'.tr,
          message: 'forgot_pin_google_msg'.tr,
          confirmLabel: 'verify'.tr,
          onConfirm: controller.resetPinWithGoogle,
        );
        break;
      case ForgotPinRoute.signedOut:
        _confirmDialog(
          title: 'forgot_pin_title'.tr,
          message: 'forgot_pin_signed_out_msg'.tr,
          confirmLabel: 'erase_reset'.tr,
          onConfirm: controller.eraseDataAndResetPin,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canLeave = widget.purpose != PinPurpose.login;
    return PopScope(
      canPop: canLeave,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            SafeArea(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 56,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: canLeave
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Get.back(),
                            )
                          : null,
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints box) {
                        final double keySize = math
                            .min(
                              box.maxWidth / 4.8,
                              (box.maxHeight - 340) / 4.4,
                            )
                            .clamp(48.0, 76.0)
                            .toDouble();
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minHeight: box.maxHeight),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _buildHeader(),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: PinKeypad(
                                    onDigit: controller.onDigit,
                                    onBackspace: controller.deleteLastDigit,
                                    size: keySize,
                                    rowGap: keySize * 0.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildForgotPin(),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Obx(() {
                if (!controller.isLoading.value) {
                  return const SizedBox.shrink();
                }
                return const Stack(
                  children: <Widget>[
                    ModalBarrier(dismissible: false, color: Colors.black54),
                    Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(() {
        final bool verifying = controller.stage.value == PinStage.verifyCurrent;
        final String error = controller.errorText.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primarySoft,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: AppColors.primaryGlow, blurRadius: 30),
                ],
              ),
              child: Icon(
                verifying ? Icons.lock_rounded : Icons.shield_outlined,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              controller.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            PinDots(
              length: controller.pin.value.length,
              hasError: error.isNotEmpty,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 22,
              child: Text(
                error,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.expense,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildForgotPin() {
    return Obx(() {
      final bool visible = controller.purpose.value == PinPurpose.login &&
          controller.stage.value == PinStage.verifyCurrent;
      if (!visible) {
        return const SizedBox(height: 48);
      }
      return SizedBox(
        height: 48,
        child: TextButton(
          onPressed: controller.isLoading.value ? null : _onForgotPin,
          child: Text(
            'forgot_pin'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    });
  }
}
