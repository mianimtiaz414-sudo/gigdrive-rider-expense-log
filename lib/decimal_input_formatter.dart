import 'package:flutter/services.dart';

class DecimalInputFormatter extends TextInputFormatter {
  DecimalInputFormatter({this.decimalRange = 2});

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }
    final RegExp regex = RegExp('^\\d*\\.?\\d{0,$decimalRange}\$');
    return regex.hasMatch(text) ? newValue : oldValue;
  }
}
