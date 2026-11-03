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
  final AuthViewModel _vm = Get.find<AuthViewModel>();

  @override
  void initState() {
    super.initState();
    _vm.startPinFlow(PinPurpose.settingsDisable);
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height * 0.94;
    return SizedBox(
      height: height,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
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
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Get.back<bool>(result: false),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => PinScreen(
                compact: true,
                icon: Icons.lock_open_rounded,
                title: _vm.title,
                subtitle: _vm.subtitle,
                pinLength: _vm.pin.value.length,
                errorText: _vm.errorText.value,
                onDigit: _vm.onDigit,
                onDelete: _vm.onDelete,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
