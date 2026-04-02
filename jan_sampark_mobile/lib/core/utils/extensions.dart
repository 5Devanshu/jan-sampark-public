import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

// ─────────────────────────────────────────────
// String Extensions
// ─────────────────────────────────────────────

extension StringExtensions on String {
  /// Capitalise first letter only: "hello world" → "Hello world"
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Title case every word: "hello world" → "Hello World"
  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  /// Truncate with ellipsis: "Very long text..."
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Clean mobile number to 10 digits
  String get cleanMobile => replaceAll(RegExp(r'^(\+91|91)'), '').trim();

  /// Returns true if this is a valid MongoDB ObjectId
  bool get isObjectId => RegExp(r'^[a-f0-9]{24}$').hasMatch(this);

  /// Returns true if string is null or empty after trimming
  bool get isNullOrEmpty => trim().isEmpty;
}

extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
  String get orEmpty => this ?? '';
  String get orDash => (this == null || this!.trim().isEmpty) ? '—' : this!;
}

// ─────────────────────────────────────────────
// BuildContext Extensions
// ─────────────────────────────────────────────

extension ContextExtensions on BuildContext {
  // ── Screen dimensions ──────────────────────
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;
  double get topPadding => MediaQuery.paddingOf(this).top;

  // ── Theme shortcuts ────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // ── Navigation ─────────────────────────────
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  // ── Snackbars ──────────────────────────────
  void showSuccess(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: AppTextStyles.bodyWhite),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  void showError(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: AppTextStyles.bodyWhite),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  void showInfo(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: AppTextStyles.bodyWhite),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  // ── Keyboard ───────────────────────────────
  void hideKeyboard() => FocusScope.of(this).unfocus();
}

// ─────────────────────────────────────────────
// DateTime Extensions
// ─────────────────────────────────────────────

extension DateTimeExtensions on DateTime {
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
}

// ─────────────────────────────────────────────
// int / double Extensions
// ─────────────────────────────────────────────

extension IntExtensions on int {
  /// Clamps to a 0–100 percentage range
  double get asPercent => clamp(0, 100).toDouble();

  /// SizedBox height shorthand: 16.h
  SizedBox get h => SizedBox(height: toDouble());

  /// SizedBox width shorthand: 16.w
  SizedBox get w => SizedBox(width: toDouble());
}

extension DoubleExtensions on double {
  double get asPercent => clamp(0.0, 100.0).toDouble();
  SizedBox get h => SizedBox(height: this);
  SizedBox get w => SizedBox(width: this);
}

// ─────────────────────────────────────────────
// List Extensions
// ─────────────────────────────────────────────

extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  List<T> get withoutDuplicates => toSet().toList();
}

// ─────────────────────────────────────────────
// Map Extensions
// ─────────────────────────────────────────────

extension MapExtensions on Map<String, dynamic> {
  String getString(String key, {String defaultValue = ''}) =>
      (this[key] as String?) ?? defaultValue;

  int getInt(String key, {int defaultValue = 0}) =>
      (this[key] as int?) ?? defaultValue;

  double getDouble(String key, {double defaultValue = 0.0}) {
    final v = this[key];
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return defaultValue;
  }

  bool getBool(String key, {bool defaultValue = false}) =>
      (this[key] as bool?) ?? defaultValue;
}
