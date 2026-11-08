import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';

class GoogleAuthCard extends StatelessWidget {
  const GoogleAuthCard({
    super.key,
    required this.busy,
    required this.onPressed,
  });

  final RxBool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Obx(() => SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: busy.value ? null : onPressed,
              icon: const Icon(Icons.account_circle_outlined),
              label: Text(
                'continue_google'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )),
    );
  }
}
