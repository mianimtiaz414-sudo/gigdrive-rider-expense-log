import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/view_models/auth_view_model.dart';
import 'package:rider_expense_tracker/views/wigdets/pin_widgets.dart';

class LoginPasscodeView extends StatefulWidget {
  const LoginPasscodeView({super.key});

  @override
  State<LoginPasscodeView> createState() => _LoginPasscodeViewState();
}

class _LoginPasscodeViewState extends State<LoginPasscodeView> {
  final AuthViewModel _vm = Get.find<AuthViewModel>();

  @override
  void initState() {
    super.initState();
    _vm.startPinFlow(PinPurpose.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => PinScreen(
          icon: Icons.lock_rounded,
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
