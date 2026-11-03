import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/core/app_theme.dart';
import 'package:rider_expense_tracker/decimal_input_formatter.dart';
import 'package:rider_expense_tracker/view_models/expense_view_model.dart';

class AddLogView extends StatefulWidget {
  const AddLogView({super.key});

  @override
  State<AddLogView> createState() => _AddLogViewState();
}

class _AddLogViewState extends State<AddLogView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ExpenseViewModel _vm = Get.find<ExpenseViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _vm.resetForm());
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await _vm.saveLog();
  }

  @override
  Widget build(BuildContext context) {
    final String currency = _vm.currencyPrefix;
    return Scaffold(
      appBar: AppBar(title: Text('add_daily_log'.tr)),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'date'.tr,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _vm.pickDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primaryBorder),
                          ),
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.calendar_month_rounded,
                                  color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _vm.formatDate(_vm.selectedDate.value),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 22),
                  _NumberField(
                    controller: _vm.earningsCtrl,
                    label: 'earnings'.tr,
                    icon: Icons.payments_rounded,
                    prefix: currency,
                    action: TextInputAction.next,
                    validator: (String? v) => _vm.validateNumber(v, 'earnings'),
                  ),
                  const SizedBox(height: 16),
                  _NumberField(
                    controller: _vm.fuelCtrl,
                    label: 'fuel_expense'.tr,
                    icon: Icons.local_gas_station_rounded,
                    prefix: currency,
                    action: TextInputAction.next,
                    validator: (String? v) =>
                        _vm.validateNumber(v, 'fuel_expense'),
                  ),
                  const SizedBox(height: 16),
                  _NumberField(
                    controller: _vm.repairsCtrl,
                    label: 'other_repairs'.tr,
                    icon: Icons.build_rounded,
                    prefix: currency,
                    action: TextInputAction.next,
                    validator: (String? v) =>
                        _vm.validateNumber(v, 'other_repairs'),
                  ),
                  const SizedBox(height: 16),
                  _NumberField(
                    controller: _vm.mileageCtrl,
                    label: 'speedometer_mileage'.tr,
                    icon: Icons.speed_rounded,
                    suffix: 'unit_km'.tr,
                    action: TextInputAction.done,
                    validator: (String? v) =>
                        _vm.validateNumber(v, 'speedometer_mileage'),
                  ),
                  const SizedBox(height: 32),
                  Obx(() => ElevatedButton(
                        onPressed: _vm.isSaving.value ? null : _onSave,
                        child: _vm.isSaving.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.6,
                                  color: Colors.black,
                                ),
                              )
                            : Text('save_log'.tr),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    required this.action,
    this.prefix,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputAction action;
  final String? prefix;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: action,
      inputFormatters: <TextInputFormatter>[DecimalInputFormatter()],
      validator: validator,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: '0',
        prefixIcon: Icon(icon, color: AppColors.primary),
        prefixText: prefix,
        suffixText: suffix,
      ),
    );
  }
}
