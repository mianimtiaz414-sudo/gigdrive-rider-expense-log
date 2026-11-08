import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';

class LoadingBarrier extends StatelessWidget {
  const LoadingBarrier({super.key, required this.visible});

  final RxBool visible;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Obx(() {
        if (!visible.value) {
          return const SizedBox.shrink();
        }
        return const Stack(
          children: <Widget>[
            ModalBarrier(dismissible: false, color: Colors.black45),
            Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
          ],
        );
      }),
    );
  }
}
