import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/view_models/auth_view_model.dart';
import 'package:rider_expense_tracker/view_models/expense_view_model.dart';


void showCloudSheet() {
  Get.bottomSheet<void>(
    const CloudSheet(),
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

class CloudSheet extends StatefulWidget {
  const CloudSheet({super.key});

  @override
  State<CloudSheet> createState() => _CloudSheetState();
}

class _CloudSheetState extends State<CloudSheet> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final AuthViewModel _auth = Get.find<AuthViewModel>();
  final ExpenseViewModel _expenses = Get.find<ExpenseViewModel>();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool register}) async {
    final String email = _emailCtrl.text.trim();
    final String password = _passCtrl.text;
    if (!GetUtils.isEmail(email) || password.length < 6) {
      AppFeedback.show(
        'check_details'.tr,
        'check_details_msg'.tr,
        isError: true,
      );
      return;
    }
    final bool ok = register
        ? await _auth.registerWithEmail(email, password)
        : await _auth.signInWithEmail(email, password);
    if (ok) {
      Get.back<void>();
      await _expenses.syncWithCloud();
    }
  }

  Future<void> _google() async {
    final bool ok = await _auth.signInWithGoogle();
    if (ok) {
      Get.back<void>();
      await _expenses.syncWithCloud();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Obx(() {
        if (!_auth.isCloudAvailable) {
          return _buildUnavailable();
        }
        if (_auth.isSignedIn) {
          return _buildSignedIn();
        }
        return _buildSignIn();
      }),
    );
  }

  Widget _header(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _buildUnavailable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _header('cloud_unavailable'.tr, 'cloud_unavailable_msg'.tr),
        ElevatedButton(
          onPressed: () => Get.back<void>(),
          child: Text('got_it'.tr),
        ),
      ],
    );
  }

  Widget _buildSignedIn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _header(
          'cloud_active'.tr,
          'signed_in_as'.trParams(<String, String>{'email': _auth.userEmail}),
        ),
        Obx(() => ElevatedButton.icon(
              onPressed: _expenses.isSyncing.value
                  ? null
                  : () async {
                      Get.back<void>();
                      await _expenses.syncWithCloud();
                    },
              icon: const Icon(Icons.sync_rounded),
              label: Text(
                _expenses.isSyncing.value ? 'syncing'.tr : 'sync_now'.tr,
              ),
            )),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            Get.back<void>();
            await _auth.signOut();
          },
          icon: const Icon(Icons.logout_rounded),
          label: Text('sign_out'.tr),
        ),
      ],
    );
  }

  Widget _buildSignIn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _header('backup_title'.tr, 'backup_sub'.tr),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'email'.tr,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passCtrl,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'password'.tr,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(_obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Obx(() {
          final bool busy = _auth.isLoading.value;
          return Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: busy ? null : () => _submit(register: false),
                      child: busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.black,
                              ),
                            )
                          : Text('sign_in'.tr),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : () => _submit(register: true),
                      child: Text('register'.tr),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: busy ? null : _google,
                icon: const Icon(Icons.account_circle_outlined),
                label: Text('continue_google'.tr),
              ),
            ],
          );
        }),
      ],
    );
  }
}
