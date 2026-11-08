import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/data/models/app_language.dart';
import 'package:rider_expense_tracker/data/models/country_currency.dart';
import 'package:rider_expense_tracker/view_models/auth_view_model.dart';
import 'package:rider_expense_tracker/view_models/settings_view_model.dart';
import 'package:rider_expense_tracker/views/widgets/pin_widgets.dart';
import 'package:rider_expense_tracker/views/widgets/searchable_picker.dart';

class SetupWizardView extends StatefulWidget {
  const SetupWizardView({super.key});

  @override
  State<SetupWizardView> createState() => _SetupWizardViewState();
}

class _SetupWizardViewState extends State<SetupWizardView> {
  static const int _lastStep = 2;
  static const int _totalSteps = 3;

  final SettingsViewModel _settings = Get.find<SettingsViewModel>();
  final AuthViewModel _auth = Get.find<AuthViewModel>();
  late final RxInt _step;
  bool _busy = false;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    final int saved = _settings.setupStep.clamp(0, _lastStep).toInt();
    _step = saved.obs;
    if (saved == _lastStep) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _auth.startPinFlow(PinPurpose.setupCreate);
        }
      });
    }
  }

  void _goTo(int step) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (step == _lastStep) {
      _auth.startPinFlow(PinPurpose.setupCreate);
    }
    _step.value = step;
    unawaited(_settings.saveSetupStep(step));
  }

  void _next() {
    if (_step.value < _lastStep) {
      _goTo(_step.value + 1);
    }
  }

  void _previous() {
    if (_step.value > 0) {
      _goTo(_step.value - 1);
    }
  }

  Future<void> _skipStep() async {
    if (_busy) {
      return;
    }
    _busy = true;
    try {
      if (_step.value == 0) {
        await _settings.setLanguage(AppLanguages.english);
        _next();
      } else if (_step.value == 1) {
        await _settings.setCurrency(CurrencyCatalog.defaultOption);
        _next();
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> _finishWithoutPin() async {
    if (_finishing) {
      return;
    }
    _finishing = true;
    try {
      await _settings.skipSecurityAndFinish();
    } finally {
      _finishing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _previous();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Obx(() {
            final int step = _step.value;
            return Column(
              children: <Widget>[
                _buildTopBar(step),
                _buildProgress(step),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    layoutBuilder: (Widget? current, List<Widget> previous) {
                      return Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          ...previous,
                          if (current != null) current,
                        ],
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(step),
                      child: _buildStep(step, keyboardOpen),
                    ),
                  ),
                ),
                if (step != _lastStep && !keyboardOpen) _buildContinue(),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTopBar(int step) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 72,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: step > 0 ? BackButton(onPressed: _previous) : null,
              ),
            ),
            Expanded(
              child: Text(
                'step_of'.trParams(<String, String>{
                  'current': '${step + 1}',
                  'total': '$_totalSteps',
                }),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 72,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: step < _lastStep
                    ? TextButton(
                        onPressed: _skipStep,
                        child: Text(
                          'skip'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress(int step) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: List<Widget>.generate(_totalSteps, (int i) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: i <= step ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep(int step, bool keyboardOpen) {
    switch (step) {
      case 0:
        return _buildPickerStep(
          keyboardOpen: keyboardOpen,
          icon: Icons.translate_rounded,
          title: 'setup_language_title'.tr,
          subtitle: 'setup_language_sub'.tr,
          picker: Obx(() => SearchablePicker(
                options: PickerCatalog.languages,
                selectedId: _settings.languageCode.value,
                hintText: 'search_language'.tr,
                onSelected: (String code) =>
                    _settings.setLanguage(AppLanguages.byCode(code)),
              )),
        );
      case 1:
        return _buildPickerStep(
          keyboardOpen: keyboardOpen,
          icon: Icons.currency_exchange_rounded,
          title: 'setup_currency_title'.tr,
          subtitle: 'setup_currency_sub'.tr,
          picker: Obx(() => SearchablePicker(
                options: PickerCatalog.currencies,
                selectedId: _settings.currencyCountry.value,
                hintText: 'search_currency'.tr,
                onSelected: (String countryCode) => _settings
                    .setCurrency(CurrencyCatalog.byCountry(countryCode)),
              )),
        );
      default:
        return _buildSecurityStep();
    }
  }

  Widget _buildPickerStep({
    required bool keyboardOpen,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget picker,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          if (!keyboardOpen)
            _StepHeader(icon: icon, title: title, subtitle: subtitle),
          Expanded(child: picker),
        ],
      ),
    );
  }

  Widget _buildSecurityStep() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double keySize =
            ((box.maxHeight - 380) / 4.4).clamp(44.0, 74.0).toDouble();
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 8),
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primarySoft,
                    boxShadow: <BoxShadow>[
                      BoxShadow(color: AppColors.primaryGlow, blurRadius: 30),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'setup_security_title'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final String error = _auth.errorText.value;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        _auth.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _auth.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      PinDots(
                        length: _auth.pin.value.length,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PinKeypad(
                    onDigit: _auth.onDigit,
                    onBackspace: _auth.deleteLastDigit,
                    size: keySize,
                    rowGap: keySize * 0.2,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _finishWithoutPin,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      'skip_security_finish'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinue() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _next,
          child: Text(
            'continue_btn'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySoft,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

