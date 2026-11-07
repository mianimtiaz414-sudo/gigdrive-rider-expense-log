import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/view_models/auth_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthViewModel controller = Get.find<AuthViewModel>();

  final TextEditingController _inEmail = TextEditingController();
  final TextEditingController _inPass = TextEditingController();
  final TextEditingController _upEmail = TextEditingController();
  final TextEditingController _upPass = TextEditingController();
  final TextEditingController _upConfirm = TextEditingController();
  final FocusNode _inPassFocus = FocusNode();
  final FocusNode _upPassFocus = FocusNode();
  final FocusNode _upConfirmFocus = FocusNode();

  final RxBool _isRegister = false.obs;
  final RxBool _obscureIn = true.obs;
  final RxBool _obscureUp = true.obs;

  @override
  void dispose() {
    _inEmail.dispose();
    _inPass.dispose();
    _upEmail.dispose();
    _upPass.dispose();
    _upConfirm.dispose();
    _inPassFocus.dispose();
    _upPassFocus.dispose();
    _upConfirmFocus.dispose();
    super.dispose();
  }

  void _setMode(bool register) {
    if (controller.isLoading.value || _isRegister.value == register) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    if (register) {
      if (_upEmail.text.isEmpty) {
        _upEmail.text = _inEmail.text;
      }
    } else {
      if (_inEmail.text.isEmpty) {
        _inEmail.text = _upEmail.text;
      }
    }
    _isRegister.value = register;
  }

  void _submitSignIn() {
    FocusManager.instance.primaryFocus?.unfocus();
    controller.submitEmail(
      email: _inEmail.text,
      password: _inPass.text,
      register: false,
    );
  }

  void _submitRegister() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_upPass.text != _upConfirm.text) {
      AppFeedback.show(
        'check_details'.tr,
        'passwords_mismatch'.tr,
        isError: true,
      );
      return;
    }
    controller.submitEmail(
      email: _upEmail.text,
      password: _upPass.text,
      register: true,
    );
  }

  void _forgotPassword() {
    FocusManager.instance.primaryFocus?.unfocus();
    controller.sendPasswordReset(_inEmail.text);
  }

  void _submitGoogle() {
    FocusManager.instance.primaryFocus?.unfocus();
    controller.submitGoogle();
  }

  void _continueOffline() {
    FocusManager.instance.primaryFocus?.unfocus();
    controller.continueOffline();
  }

  @override
  Widget build(BuildContext context) {
    final bool cloud = controller.isCloudAvailable;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildHeader(),
                      const SizedBox(height: 28),
                      if (cloud) ...<Widget>[
                        _buildEmailCard(),
                        const SizedBox(height: 18),
                        _buildDivider(),
                        const SizedBox(height: 18),
                        _buildGoogleCard(),
                        const SizedBox(height: 18),
                        _buildOfflineLink(),
                      ] else ...<Widget>[
                        _buildUnavailableCard(),
                        const SizedBox(height: 18),
                        _buildOfflinePrimary(),
                      ],
                    ],
                  ),
                ),
              ),
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
    );
  }

  Widget _buildHeader() {
    return Column(
      children: <Widget>[
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(color: AppColors.primaryBorder, width: 2),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryGlow,
                blurRadius: 34,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.two_wheeler_rounded,
            size: 46,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'login_title'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'login_sub'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Obx(() => _ModeSwitch(
                leftLabel: 'sign_in'.tr,
                rightLabel: 'register'.tr,
                rightSelected: _isRegister.value,
                enabled: !controller.isLoading.value,
                onLeft: () => _setMode(false),
                onRight: () => _setMode(true),
              )),
          const SizedBox(height: 16),
          Obx(() =>
              _isRegister.value ? _buildRegisterForm() : _buildSignInForm()),
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _inEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          onSubmitted: (String value) => _inPassFocus.requestFocus(),
          decoration: InputDecoration(
            labelText: 'email'.tr,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => TextField(
              controller: _inPass,
              focusNode: _inPassFocus,
              obscureText: _obscureIn.value,
              textInputAction: TextInputAction.done,
              onSubmitted: (String value) => _submitSignIn(),
              decoration: InputDecoration(
                labelText: 'password'.tr,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureIn.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => _obscureIn.value = !_obscureIn.value,
                ),
              ),
            )),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Obx(() => TextButton(
                onPressed: controller.isLoading.value ? null : _forgotPassword,
                child: Text(
                  'forgot_password'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        ),
        const SizedBox(height: 4),
        Obx(() => SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : _submitSignIn,
                child: Text(
                  'sign_in'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _upEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          onSubmitted: (String value) => _upPassFocus.requestFocus(),
          decoration: InputDecoration(
            labelText: 'email'.tr,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => TextField(
              controller: _upPass,
              focusNode: _upPassFocus,
              obscureText: _obscureUp.value,
              textInputAction: TextInputAction.next,
              onSubmitted: (String value) => _upConfirmFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: 'password'.tr,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureUp.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => _obscureUp.value = !_obscureUp.value,
                ),
              ),
            )),
        const SizedBox(height: 12),
        Obx(() => TextField(
              controller: _upConfirm,
              focusNode: _upConfirmFocus,
              obscureText: _obscureUp.value,
              textInputAction: TextInputAction.done,
              onSubmitted: (String value) => _submitRegister(),
              decoration: InputDecoration(
                labelText: 'confirm_password'.tr,
                prefixIcon: const Icon(Icons.lock_reset_rounded),
              ),
            )),
        const SizedBox(height: 16),
        Obx(() => SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : _submitRegister,
                child: Text(
                  'register'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(color: AppColors.divider, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or_divider'.tr,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider, height: 1)),
      ],
    );
  }

  Widget _buildGoogleCard() {
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
              onPressed: controller.isLoading.value ? null : _submitGoogle,
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

  Widget _buildOfflineLink() {
    return Obx(() => SizedBox(
          height: 52,
          child: TextButton(
            onPressed: controller.isLoading.value ? null : _continueOffline,
            child: Text(
              'continue_offline'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ));
  }

  Widget _buildOfflinePrimary() {
    return Obx(() => SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : _continueOffline,
            child: Text(
              'continue_offline'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ));
  }

  Widget _buildUnavailableCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.cloud_off_rounded, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'cloud_unavailable_msg'.tr,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({
    required this.leftLabel,
    required this.rightLabel,
    required this.rightSelected,
    required this.enabled,
    required this.onLeft,
    required this.onRight,
  });

  final String leftLabel;
  final String rightLabel;
  final bool rightSelected;
  final bool enabled;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ModeSegment(
              label: leftLabel,
              selected: !rightSelected,
              onTap: enabled ? onLeft : null,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ModeSegment(
              label: rightLabel,
              selected: rightSelected,
              onTap: enabled ? onRight : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  const _ModeSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 46,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.black : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
