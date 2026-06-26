import 'package:flutter/services.dart';

class SoftDecimalTextInputFormatter extends TextInputFormatter {
  final int maxIntegerDigits;
  final int maxDecimalDigits;

  SoftDecimalTextInputFormatter({
    required this.maxIntegerDigits,
    required this.maxDecimalDigits,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    text = text.replaceAll(RegExp(r'[^0-9.]'), '');

    final firstDotIndex = text.indexOf('.');
    if (firstDotIndex != -1) {
      final beforeDot = text.substring(0, firstDotIndex + 1);
      final afterDot = text.substring(firstDotIndex + 1).replaceAll('.', '');
      text = beforeDot + afterDot;
    }

    final parts = text.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    if (integerPart.length > maxIntegerDigits) {
      integerPart = integerPart.substring(0, maxIntegerDigits);
    }

    if (decimalPart.length > maxDecimalDigits) {
      decimalPart = decimalPart.substring(0, maxDecimalDigits);
    }

    String formattedText = integerPart;
    if (text.contains('.') && maxDecimalDigits > 0) {
      formattedText += '.$decimalPart';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
