import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/data/models/expense_model.dart';
import 'package:rider_expense_tracker/routes/app_routes.dart';
import 'package:rider_expense_tracker/view_models/auth_view_model.dart';
import 'package:rider_expense_tracker/view_models/expense_view_model.dart';
import 'package:rider_expense_tracker/view_models/settings_view_model.dart';
import 'package:rider_expense_tracker/views/wigdets/cloud_sheet.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseViewModel vm = Get.find<ExpenseViewModel>();
    final AuthViewModel auth = Get.find<AuthViewModel>();
    final SettingsViewModel settings = Get.find<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          AppConstants.appName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: <Widget>[
          Obx(() => IconButton(
                tooltip: 'export_pdf'.tr,
                onPressed: vm.isExporting.value ? null : vm.exportDataToPdf,
                icon: vm.isExporting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf, color: Colors.white),
              )),
          Obx(() {
            final bool signedIn = auth.isSignedIn;
            return IconButton(
              tooltip: 'cloud_backup'.tr,
              icon: vm.isSyncing.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      signedIn
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_upload_outlined,
                      color: signedIn
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
              onPressed: showCloudSheet,
            );
          }),
          Obx(() {
            if (!settings.lockEnabled.value) {
              return const SizedBox.shrink();
            }
            return IconButton(
              tooltip: 'lock_app'.tr,
              icon: const Icon(Icons.lock_outline_rounded),
              onPressed: () => Get.offAllNamed<void>(AppRoutes.loginPasscode),
            );
          }),
          IconButton(
            tooltip: 'settings'.tr,
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Get.toNamed<void>(AppRoutes.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed<void>(AppRoutes.addLog),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'add_log'.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: Obx(() {
        return vm.isAdLoaded.value && vm.myBanner != null
            ? Container(
                alignment: Alignment.center,
                width: vm.myBanner!.size.width.toDouble(),
                height: vm.myBanner!.size.height.toDouble(),
                child: AdWidget(ad: vm.myBanner!),
              )
            : const SizedBox
                .shrink(); // Agar ad load na ho toh jagah khali rahegi
      }),
      body: Column(
        children: <Widget>[
          _MonthSelector(vm: vm),
          _SummarySection(vm: vm),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 22, 20, 10),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'recent_entries'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final int count = vm.monthLogs.length;
              if (count == 0) {
                return const _EmptyState();
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: count,
                itemBuilder: (BuildContext context, int index) {
                  final ExpenseModel log = vm.monthLogs[index];
                  return _LogTile(
                    key: ValueKey<String>(log.id),
                    log: log,
                    vm: vm,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.vm});

  final ExpenseViewModel vm;

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    return Obx(() {
      final String label = vm.monthLabel;
      final bool canNext = vm.canGoNextMonth;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: vm.previousMonth,
              icon: Icon(
                rtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                size: 30,
              ),
            ),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              onPressed: canNext ? vm.nextMonth : null,
              icon: Icon(
                rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                size: 30,
                color: canNext ? AppColors.textPrimary : AppColors.divider,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.vm});

  final ExpenseViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          Obx(() {
            final double profit = vm.netProfit.value;
            final Color color =
                profit >= 0 ? AppColors.primary : AppColors.expense;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primaryBorder),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: 26,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.trending_up_rounded, color: color, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'net_profit'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      vm.formatMoney(profit),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: Obx(() => _StatCard(
                      label: 'total_earnings'.tr,
                      value: vm.formatMoney(vm.totalEarnings.value),
                      icon: Icons.south_west_rounded,
                      color: AppColors.earning,
                      softColor: AppColors.earningSoft,
                    )),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Obx(() => _StatCard(
                      label: 'total_expenses'.tr,
                      value: vm.formatMoney(vm.totalExpenses.value),
                      icon: Icons.north_east_rounded,
                      color: AppColors.expense,
                      softColor: AppColors.expenseSoft,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.softColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color softColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: softColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.receipt_long_outlined,
                size: 64, color: AppColors.divider),
            const SizedBox(height: 14),
            Text(
              'no_entries_title'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'no_entries_msg'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({super.key, required this.log, required this.vm});

  final ExpenseModel log;
  final ExpenseViewModel vm;

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('delete_entry'.tr),
        content: Text('delete_entry_msg'.tr),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double profit = log.netProfit;
    final Color profitColor =
        profit >= 0 ? AppColors.primary : AppColors.expense;
    final double amountsMaxWidth = MediaQuery.of(context).size.width * 0.38;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey<String>('dismiss_${log.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (DismissDirection d) => _confirmDelete(context),
        onDismissed: (DismissDirection d) => vm.deleteLog(log.id),
        background: Container(
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsetsDirectional.only(end: 24),
          decoration: BoxDecoration(
            color: AppColors.expenseSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: AppColors.expense, size: 28),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      vm.dayNumber(log.date),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      vm.monthShort(log.date),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            vm.weekdayName(log.date),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          log.synced
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_off_outlined,
                          size: 15,
                          color: log.synced
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${'fuel_short'.tr} ${vm.formatMoney(log.fuel)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${'repairs_short'.tr} ${vm.formatMoney(log.otherRepairs)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${'odometer'.tr} ${vm.formatDistance(log.mileage)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: amountsMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      vm.formatMoney(profit),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: profitColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${'earned'.tr} ${vm.formatMoney(log.earnings)}',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
