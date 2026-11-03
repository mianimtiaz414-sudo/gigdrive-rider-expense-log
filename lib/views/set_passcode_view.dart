import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/view_models/auth_view_model.dart';
import 'package:rider_expense_tracker/views/wigdets/pin_widgets.dart';

class SetPasscodeView extends StatefulWidget {
  const SetPasscodeView({super.key});

  @override
  State<SetPasscodeView> createState() => _SetPasscodeViewState();
}

class _SetPasscodeViewState extends State<SetPasscodeView> {
  final AuthViewModel _vm = Get.find<AuthViewModel>();

  @override
  void initState() {
    super.initState();
    final Object? args = Get.arguments;
    final PinPurpose purpose =
        args is PinPurpose ? args : PinPurpose.setupCreate;
    _vm.startPinFlow(purpose);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(
        () => PinScreen(
          icon: _vm.stage.value == PinStage.verifyCurrent
              ? Icons.lock_rounded
              : Icons.shield_outlined,
          title: _vm.title,
          subtitle: _vm.subtitle,
          pinLength: _vm.pin.value.length,
          errorText: _vm.errorText.value,
          onDigit: _vm.onDigit,
          onDelete: _vm.onDelete,
        ),
      ),
    );
  }
}
