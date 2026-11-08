import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/views/widgets/searchable_picker.dart';

class SelectionPickerView extends StatelessWidget {
  const SelectionPickerView({
    super.key,
    required this.title,
    required this.hintText,
    required this.options,
    required this.selectedId,
  });

  final String title;
  final String hintText;
  final List<PickerOption> options;
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SearchablePicker(
            options: options,
            selectedId: selectedId,
            hintText: hintText,
            onSelected: (String id) => Get.back<String>(result: id),
          ),
        ),
      ),
    );
  }
}



Future<String?> openPickerScreen({
  required String title,
  required String hintText,
  required List<PickerOption> options,
  required String selectedId,
}) async {
  final String? result = await Get.to<String>(
    () => SelectionPickerView(
      title: title,
      hintText: hintText,
      options: options,
      selectedId: selectedId,
    ),
    transition: Transition.downToUp,
  );
  return result;
}

