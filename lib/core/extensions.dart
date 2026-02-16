import 'package:flutter/material.dart';

/// Extensões para BuildContext
extension BuildContextExt on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  void showSnackBar(String message, {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[400],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Extensões para String
extension StringExt on String {
  bool get isValidEmail {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(this);
  }

  bool get isValidPassword {
    return length >= 6;
  }

  String get capitalize {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

/// Extensões para Color
extension ColorExt on Color {
  Color withOpacityValue(double opacity) => withOpacity(opacity);
}

/// Extensões para num
extension NumExt on num {
  String toPercentageString() => '${(this * 100).toInt()}%';
  
  int toInt32() => toInt();
  
  double toDouble64() => toDouble();
}

/// Extensões para List
extension ListExt<T> on List<T> {
  List<T> whereNot(bool Function(T) test) => where((e) => !test(e)).toList();
}
