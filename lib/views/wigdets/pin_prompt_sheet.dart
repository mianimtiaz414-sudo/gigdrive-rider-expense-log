import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/view_models/auth_view_model.dart';
import 'package:rider_expense_tracker/views/wigdets/pin_widgets.dart';

class PinPromptSheet extends StatefulWidget {
  const PinPromptSheet({super.key});

  @override
  State<PinPromptSheet> createState() => _PinPromptSheetState();
}

class _PinPromptSheetState extends State<PinPromptSheet> {
  final AuthViewModel controller = Get.find<AuthViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.startPinFlow(PinPurpose.settingsDisable);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Get.back(),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primarySoft,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: AppColors.primaryGlow, blurRadius: 24),
                ],
              ),
              child: const Icon(
                Icons.lock_open_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Obx(() {
              final String error = controller.errorText.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    controller.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: PinKeypad(
                onDigit: controller.onDigit,
                onBackspace: controller.deleteLastDigit,
                size: 62,
                rowGap: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
