import 'package:flutter/services.dart';

/// Converts all typed text to UPPERCASE
/// Used for: IFSC Code, PAN, GSTIN, PIN Code, etc.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Converts all typed text to lowercase
/// Used for: Email, Username, URLs, etc.
class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

/// Only allows alphanumeric characters (A-Z, a-z, 0-9)
class AlphanumericFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9]*$');
    if (alphanumeric.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

/// Only allows letters (A-Z, a-z)
class LettersOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final RegExp lettersOnly = RegExp(r'^[a-zA-Z\s]*$');
    if (lettersOnly.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

/// Formats phone number as: +91 XXXXX XXXXX
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '';
    if (text.length <= 2) {
      formatted = '+91 $text';
    } else if (text.length <= 7) {
      formatted = '+91 ${text.substring(0, 2)} ${text.substring(2)}';
    } else {
      formatted = '+91 ${text.substring(0, 2)} ${text.substring(2, 7)} ${text.substring(7, 10)}';
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.fromPosition(
        TextPosition(offset: formatted.length),
      ),
    );
  }
}

/// Capitalizes first letter of each word
/// Used for: Names, Titles, etc.
class CapitalizeFirstLetterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final String text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    final List<String> words = text.split(' ');
    final String formatted = words
        .map((word) => word.isEmpty
        ? word
        : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');

    return newValue.copyWith(text: formatted);
  }
}
