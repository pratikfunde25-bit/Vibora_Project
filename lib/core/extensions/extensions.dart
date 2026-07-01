import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  // Theme
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Size
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  // Navigation
  NavigatorState get navigator => Navigator.of(this);
  void pop([dynamic result]) => Navigator.of(this).pop(result);

  // Snackbar
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Spacing helpers
  SizedBox get h4 => const SizedBox(height: 4);
  SizedBox get h8 => const SizedBox(height: 8);
  SizedBox get h12 => const SizedBox(height: 12);
  SizedBox get h16 => const SizedBox(height: 16);
  SizedBox get h20 => const SizedBox(height: 20);
  SizedBox get h24 => const SizedBox(height: 24);
  SizedBox get h32 => const SizedBox(height: 32);
  SizedBox get w8 => const SizedBox(width: 8);
  SizedBox get w12 => const SizedBox(width: 12);
  SizedBox get w16 => const SizedBox(width: 16);
}

extension StringX on String {
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  bool get isValidPhone => RegExp(r'^\+?[0-9]{10,13}$').hasMatch(this);
  bool get isValidPassword => length >= 8;
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');
}

extension DateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());

  String get friendlyDate {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${day} ${months[month - 1]}, $year';
  }
}

extension NumX on num {
  SizedBox get hGap => SizedBox(height: toDouble());
  SizedBox get wGap => SizedBox(width: toDouble());
}
