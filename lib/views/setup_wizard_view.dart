import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/data/models/app_language.dart';
import 'package:rider_expense_tracker/data/models/country_currency.dart';
import 'package:rider_expense_tracker/routes/app_routes.dart';
import 'package:rider_expense_tracker/view_models/auth_view_model.dart';
import 'package:rider_expense_tracker/view_models/settings_view_model.dart';
import 'package:rider_expense_tracker/views/wigdets/searchable_picker.dart';

class SetupWizardView extends StatefulWidget {
  const SetupWizardView({super.key});

  @override
  State<SetupWizardView> createState() => _SetupWizardViewState();
}

class _SetupWizardViewState extends State<SetupWizardView> {
  static const int _totalSteps = 3;

  final SettingsViewModel _settings = Get.find<SettingsViewModel>();
  final PageController _pages = PageController();
  final RxInt _step = 0.obs;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _step.value = step;
    _pages.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_step.value < _totalSteps - 1) {
      _goToStep(_step.value + 1);
    }
  }

  void _previous() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_step.value > 0) {
      _goToStep(_step.value - 1);
    }
  }

  Future<void> _skip() async {
    FocusManager.instance.primaryFocus?.unfocus();
    switch (_step.value) {
      case 0:
        await _settings.setLanguage(AppLanguages.english);
        _next();
        break;
      case 1:
        await _settings.setCurrency(CurrencyCatalog.defaultOption);
        _next();
        break;
      default:
        await _settings.skipSecurityAndFinish();
        break;
    }
  }

  void _startPinSetup() {
    Get.toNamed<bool>(
      AppRoutes.setPasscode,
      arguments: PinPurpose.setupCreate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildTopBar(),
            _buildProgress(),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  _buildLanguageStep(keyboardOpen),
                  _buildCurrencyStep(keyboardOpen),
                  _buildSecurityStep(),
                ],
              ),
            ),
            if (!keyboardOpen) _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
      child: Obx(() {
        final int step = _step.value;
        return Row(
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
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'skip'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Obx(() {
        final int step = _step.value;
        return Row(
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
        );
      }),
    );
  }

  Widget _buildLanguageStep(bool keyboardOpen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          if (!keyboardOpen)
            _StepHeader(
              icon: Icons.translate_rounded,
              title: 'setup_language_title'.tr,
              subtitle: 'setup_language_sub'.tr,
            ),
          Expanded(
            child: Obx(() => SearchablePicker(
                  options: PickerCatalog.languages,
                  selectedId: _settings.languageCode.value,
                  hintText: 'search_language'.tr,
                  onSelected: (String code) =>
                      _settings.setLanguage(AppLanguages.byCode(code)),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyStep(bool keyboardOpen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          if (!keyboardOpen)
            _StepHeader(
              icon: Icons.currency_exchange_rounded,
              title: 'setup_currency_title'.tr,
              subtitle: 'setup_currency_sub'.tr,
            ),
          Expanded(
            child: Obx(() => SearchablePicker(
                  options: PickerCatalog.currencies,
                  selectedId: _settings.currencyCountry.value,
                  hintText: 'search_currency'.tr,
                  onSelected: (String countryCode) => _settings
                      .setCurrency(CurrencyCatalog.byCountry(countryCode)),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 24),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.primaryBorder, width: 2),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 58,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'setup_security_title'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                height: 1.3,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'setup_security_sub'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            _Bullet(icon: Icons.wifi_off_rounded, text: 'sec_point_1'.tr),
            const SizedBox(height: 12),
            _Bullet(icon: Icons.tune_rounded, text: 'sec_point_2'.tr),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Obx(() {
        if (_step.value < _totalSteps - 1) {
          return ElevatedButton(
            onPressed: _next,
            child: Text(
              'continue_btn'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: _startPinSetup,
              icon: const Icon(Icons.pin_outlined),
              label: Text(
                'set_pin'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _skip,
              child: Text(
                'skip_for_now'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }),
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

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
