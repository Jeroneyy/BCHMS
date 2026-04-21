import 'package:flutter/material.dart';

/// Useful Dart/Flutter extensions.

extension StringExtension on String {
  /// Capitalize first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Title case every word.
  String get titleCase {
    return split(' ').map((w) => w.capitalize).join(' ');
  }

  /// Extract initials from a name.
  String get initials {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return length >= 2 ? substring(0, 2).toUpperCase() : toUpperCase();
  }
}

extension DateTimeExtension on DateTime {
  /// Returns true if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Returns true if this date is in the future.
  bool get isFuture => isAfter(DateTime.now());

  /// Date only (no time component).
  DateTime get dateOnly => DateTime(year, month, day);
}

extension ContextExtension on BuildContext {
  /// Access theme easily.
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Screen dimensions.
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Responsive breakpoints.
  bool get isMobile => screenWidth < 768;
  bool get isTablet => screenWidth >= 768 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;

  /// Show snackbar.
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}

extension ListExtension<T> on List<T> {
  /// Safe element access.
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
}
