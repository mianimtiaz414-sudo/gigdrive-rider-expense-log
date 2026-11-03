import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:printing/printing.dart' show Printing;
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/data/local/pdf_report_service.dart';
import 'package:rider_expense_tracker/data/models/expense_model.dart';
import 'package:rider_expense_tracker/data/repositories/expense_repository.dart';
import 'package:rider_expense_tracker/view_models/settings_view_model.dart';

class ExpenseViewModel extends GetxController {
  ExpenseViewModel(this._repository, this._settings);

  final ExpenseRepository _repository;
  final SettingsViewModel _settings;

  
  final RxList<ExpenseModel> logs = <ExpenseModel>[].obs;
  final RxList<ExpenseModel> monthLogs = <ExpenseModel>[].obs;
  final Rx<DateTime> selectedMonth = _monthOf(DateTime.now()).obs;

  final RxDouble totalEarnings = 0.0.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxDouble netProfit = 0.0.obs;

  
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isSyncing = false.obs;
  final RxBool isExporting = false.obs;

  
  final Rx<DateTime> selectedDate = _dayOf(DateTime.now()).obs;
  final TextEditingController earningsCtrl = TextEditingController();
  final TextEditingController fuelCtrl = TextEditingController();
  final TextEditingController repairsCtrl = TextEditingController();
  final TextEditingController mileageCtrl = TextEditingController();

  late final Worker _recomputeWorker;

  final NumberFormat _distance = NumberFormat('#,##0.##', 'en_US');

  static DateTime _monthOf(DateTime d) => DateTime(d.year, d.month);
  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void onInit() {
    super.onInit();
    _recomputeWorker = everAll(
      <RxInterface<dynamic>>[logs, selectedMonth],
      (dynamic _) => _recompute(),
    );
    loadLogs();
  }

  @override
  void onReady() {
    super.onReady();
    if (_repository.isCloudReady) {
      syncWithCloud(silent: true);
    }
  }

  @override
  void onClose() {
    _recomputeWorker.dispose();
    earningsCtrl.dispose();
    fuelCtrl.dispose();
    repairsCtrl.dispose();
    mileageCtrl.dispose();
    super.onClose();
  }

  
  String get _localeTag => Get.locale?.toString() ?? 'en';

  String _fmt(String pattern, DateTime date) {
    return DateFormat(pattern, _localeTag).format(date);
  }

  
  String get currencyPrefix => _settings.currencySymbol;

  String formatMoney(double value) {
    final NumberFormat f = NumberFormat.currency(
      locale: 'en_US',
      symbol: _settings.currencySymbol,
      decimalDigits: 2,
    );
    final String sign = value < 0 ? '-' : '';
    
    return '\u200E$sign${f.format(value.abs())}';
  }

  String formatDistance(double value) =>
      '\u200E${_distance.format(value)} ${'unit_km'.tr}';

  String formatDate(DateTime date) => _fmt('EEE, dd MMM yyyy', date);

  String dayNumber(DateTime date) => _fmt('dd', date);

  String monthShort(DateTime date) => _fmt('MMM', date).toUpperCase();

  String weekdayName(DateTime date) => _fmt('EEEE', date);

  String get monthLabel => _fmt('MMMM yyyy', selectedMonth.value);

  bool get canGoNextMonth {
    final DateTime current = _monthOf(DateTime.now());
    return selectedMonth.value.isBefore(current);
  }

  
  void previousMonth() {
    final DateTime m = selectedMonth.value;
    selectedMonth.value = DateTime(m.year, m.month - 1);
  }

  void nextMonth() {
    if (!canGoNextMonth) {
      return;
    }
    final DateTime m = selectedMonth.value;
    selectedMonth.value = DateTime(m.year, m.month + 1);
  }

  
  void loadLogs() {
    isLoading.value = true;
    try {
      logs.assignAll(_repository.getLocalLogs());
    } finally {
      isLoading.value = false;
    }
  }

  void _recompute() {
    final DateTime m = selectedMonth.value;
    final List<ExpenseModel> filtered = logs
        .where((ExpenseModel l) =>
            l.date.year == m.year && l.date.month == m.month)
        .toList()
      ..sort((ExpenseModel a, ExpenseModel b) {
        final int byDate = b.date.compareTo(a.date);
        return byDate != 0 ? byDate : b.id.compareTo(a.id);
      });

    double earned = 0;
    double spent = 0;
    for (final ExpenseModel l in filtered) {
      earned += l.earnings;
      spent += l.totalExpenses;
    }

    monthLogs.assignAll(filtered);
    totalEarnings.value = earned;
    totalExpenses.value = spent;
    netProfit.value = earned - spent;
  }

  Future<void> deleteLog(String id) async {
    logs.removeWhere((ExpenseModel l) => l.id == id);
    try {
      await _repository.deleteLog(id);
    } catch (e) {
      AppFeedback.show('delete_failed'.tr, e.toString(), isError: true);
    }
  }

  
  void resetForm() {
    earningsCtrl.clear();
    fuelCtrl.clear();
    repairsCtrl.clear();
    mileageCtrl.clear();
    selectedDate.value = _dayOf(DateTime.now());
  }

  
  String? validateNumber(String? value, String labelKey) {
    final String text = value?.trim() ?? '';
    final String label = labelKey.tr;
    if (text.isEmpty) {
      return 'enter_value'.trParams(<String, String>{'field': label});
    }
    final double? parsed = double.tryParse(text);
    if (parsed == null) {
      return 'valid_number'.tr;
    }
    if (parsed < 0) {
      return 'no_negative'.trParams(<String, String>{'field': label});
    }
    return null;
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime today = _dayOf(DateTime.now());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDate.value.isAfter(today) ? today : selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: today,
      builder: (BuildContext ctx, Widget? child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = _dayOf(picked);
    }
  }

  double _parse(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  Future<void> saveLog() async {
    if (isSaving.value) {
      return;
    }
    isSaving.value = true;
    try {
      final DateTime d = selectedDate.value;
      final ExpenseModel log = ExpenseModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: DateTime(d.year, d.month, d.day),
        earnings: _parse(earningsCtrl),
        fuel: _parse(fuelCtrl),
        otherRepairs: _parse(repairsCtrl),
        mileage: _parse(mileageCtrl),
      );
      await _repository.addLog(log, onSynced: loadLogs);
      loadLogs();
      selectedMonth.value = _monthOf(log.date);
      Get.back<void>();
      AppFeedback.show('saved'.tr, 'log_added'.tr);
    } catch (e) {
      AppFeedback.show('could_not_save'.tr, e.toString(), isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  
  
  
  
  Future<void> exportDataToPdf() async {
    if (isExporting.value) {
      return;
    }
    isExporting.value = true;
    try {
      final List<ExpenseModel> records = _repository.getLocalLogs();
      if (records.isEmpty) {
        AppFeedback.show(
          'pdf_no_data_title'.tr,
          'pdf_no_data_msg'.tr,
          isError: true,
        );
        return;
      }

      final DateTime now = DateTime.now();
      final Uint8List bytes = await PdfReportService.buildLedgerReport(
        logs: records,
        currencyCode: _settings.currency.currencyCode,
        appName: AppConstants.appName,
        generatedAt: now,
      );

      final String stamp = DateFormat('yyyyMMdd_HHmm', 'en').format(now);
      await Printing.layoutPdf(
        name: 'rider_ledger_$stamp.pdf',
        onLayout: (PdfPageFormat format) async => bytes,
      );
    } catch (e) {
      AppFeedback.show('pdf_failed'.tr, e.toString(), isError: true);
    } finally {
      isExporting.value = false;
    }
  }

  
  
  Future<void> syncWithCloud({bool silent = false}) async {
    if (!_repository.isCloudReady) {
      if (!silent) {
        AppFeedback.show('sign_in_required'.tr, 'sign_in_required_msg'.tr,
            isError: true);
      }
      return;
    }
    if (isSyncing.value) {
      return;
    }
    isSyncing.value = true;
    try {
      final int pushed = await _repository.syncPending();
      final int restored = await _repository.restoreFromCloud();
      await _settings.syncFromCloud();
      loadLogs();
      if (!silent) {
        AppFeedback.show(
          'sync_complete'.tr,
          'sync_complete_msg'.trParams(<String, String>{
            'pushed': '$pushed',
            'restored': '$restored',
          }),
        );
      }
    } catch (e) {
      if (!silent) {
        AppFeedback.show('sync_failed'.tr, e.toString(), isError: true);
      }
    } finally {
      isSyncing.value = false;
    }
  }

  
  
  
  Future<bool> backupAndClearLocalData() async {
    if (_repository.isCloudReady) {
      await _repository.syncPending();
    }
    if (_repository.pendingCount > 0) {
      return false;
    }
    await _repository.clearLocal();
    loadLogs();
    return true;
  }
}
