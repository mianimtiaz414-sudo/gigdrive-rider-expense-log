import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/data/models/app_language.dart';
import 'package:rider_expense_tracker/data/models/country_currency.dart';
import 'package:rider_expense_tracker/routes/app_routes.dart';
import 'package:rider_expense_tracker/view_models/auth_view_model.dart';
import 'package:rider_expense_tracker/view_models/settings_view_model.dart';
import 'package:rider_expense_tracker/views/selection_picker_view.dart';
import 'package:rider_expense_tracker/views/wigdets/cloud_sheet.dart';
import 'package:rider_expense_tracker/views/wigdets/pin_prompt_sheet.dart';
import 'package:rider_expense_tracker/views/wigdets/searchable_picker.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  Future<void> _pickLanguage(SettingsViewModel vm) async {
    final String? code = await openPickerScreen(
      title: 'language'.tr,
      hintText: 'search_language'.tr,
      options: PickerCatalog.languages,
      selectedId: vm.languageCode.value,
    );
    if (code != null) {
      await vm.setLanguage(AppLanguages.byCode(code));
    }
  }

  Future<void> _pickCurrency(SettingsViewModel vm) async {
    final String? countryCode = await openPickerScreen(
      title: 'currency'.tr,
      hintText: 'search_currency'.tr,
      options: PickerCatalog.currencies,
      selectedId: vm.currencyCountry.value,
    );
    if (countryCode != null) {
      await vm.setCurrency(CurrencyCatalog.byCountry(countryCode));
    }
  }

  
  
  
  Future<void> _onLockToggle(bool wantOn) async {
    if (wantOn) {
      await Get.toNamed<bool>(
        AppRoutes.setPasscode,
        arguments: PinPurpose.settingsEnable,
      );
      return;
    }
    await Get.bottomSheet<bool>(
      const PinPromptSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  void _changePin() {
    Get.toNamed<bool>(
      AppRoutes.setPasscode,
      arguments: PinPurpose.settingsChange,
    );
  }

  
  
  void _confirmAccountAction({
    required AuthViewModel auth,
    required String titleKey,
    required String messageKey,
    required String confirmKey,
    required bool destructive,
  }) {
    Get.defaultDialog<void>(
      title: titleKey.tr,
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      middleText: messageKey.tr,
      middleTextStyle: const TextStyle(
        fontSize: 14.5,
        height: 1.45,
        color: AppColors.textSecondary,
      ),
      backgroundColor: AppColors.surface,
      radius: 20,
      barrierDismissible: true,
      cancel: OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: const Size(112, 46)),
        onPressed: () => Get.back<void>(),
        child: Text(
          'cancel'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(112, 46),
          backgroundColor: destructive ? AppColors.expense : AppColors.primary,
          foregroundColor: destructive ? Colors.white : Colors.black,
        ),
        onPressed: () {
          Get.back<void>();
          auth.clearSessionAndGoToAuth();
        },
        child: Text(
          confirmKey.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsViewModel vm = Get.find<SettingsViewModel>();
    final AuthViewModel auth = Get.find<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          _SectionLabel('general'.tr),
          _SettingsCard(
            children: <Widget>[
              Obx(() => _SettingsTile(
                    icon: Icons.translate_rounded,
                    title: 'language'.tr,
                    subtitle: vm.language.nativeName,
                    onTap: () => _pickLanguage(vm),
                  )),
              const _TileDivider(),
              Obx(() {
                final CurrencyOption c = vm.currency;
                return _SettingsTile(
                  icon: Icons.currency_exchange_rounded,
                  title: 'currency'.tr,
                  subtitle:
                      '${c.flag}  ${c.countryName} • ${c.currencyCode} (${c.symbol})',
                  onTap: () => _pickCurrency(vm),
                );
              }),
            ],
          ),
          const SizedBox(height: 24),
          _SectionLabel('security_pin'.tr),
          _SettingsCard(
            children: <Widget>[
              Obx(() {
                final bool on = vm.lockEnabled.value;
                return _SettingsTile(
                  icon: on ? Icons.lock_rounded : Icons.lock_open_rounded,
                  title: 'pin_lock'.tr,
                  subtitle: on ? 'pin_lock_on_sub'.tr : 'pin_lock_off_sub'.tr,
                  trailing: Switch(value: on, onChanged: _onLockToggle),
                  onTap: () => _onLockToggle(!on),
                );
              }),
              Obx(() {
                if (!vm.lockEnabled.value) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: <Widget>[
                    const _TileDivider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: OutlinedButton.icon(
                        onPressed: _changePin,
                        icon: const Icon(Icons.password_rounded),
                        label: Text(
                          'change_pin'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 24),
          _SectionLabel('account'.tr),
          _SettingsCard(
            children: <Widget>[
              Obx(() => _SettingsTile(
                    icon: auth.isSignedIn
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_upload_outlined,
                    title: 'cloud_backup'.tr,
                    subtitle: auth.isSignedIn
                        ? auth.userEmail
                        : 'cloud_not_connected'.tr,
                    onTap: showCloudSheet,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _confirmAccountAction(
              auth: auth,
              titleKey: 'switch_account_title',
              messageKey: 'switch_account_msg',
              confirmKey: 'confirm',
              destructive: false,
            ),
            icon: const Icon(Icons.switch_account_rounded),
            label: Text(
              'switch_account'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.expense,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.surfaceLight,
                ),
                onPressed: auth.isLoading.value
                    ? null
                    : () => _confirmAccountAction(
                          auth: auth,
                          titleKey: 'logout_title',
                          messageKey: 'logout_msg',
                          confirmKey: 'logout',
                          destructive: true,
                        ),
                icon: auth.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.logout_rounded),
                label: Text(
                  'logout'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 6, top: 12, bottom: 10),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.primary,
        ),
      ),
    );
  }
}


class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Column(children: children),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.divider);
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                Icon(
                  rtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
          ],
        ),
      ),
    );
  }
}
