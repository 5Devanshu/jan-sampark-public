import 'package:flutter/material.dart';
import '../constants/ops_constants.dart';
import '../theme/ops_colors.dart';
import '../theme/ops_text_styles.dart';
import '../theme/ops_dimensions.dart';

extension OpsContextExtensions on BuildContext {
  // ─────────────────────────────────────────────
  // Snackbars
  // ─────────────────────────────────────────────

  void showSuccess(String message) {
    _showSnackbar(
      message:   message,
      icon:      Icons.check_circle_outline_rounded,
      bgColor:   OpsColors.success,
    );
  }

  void showError(String message) {
    _showSnackbar(
      message:   message,
      icon:      Icons.error_outline_rounded,
      bgColor:   OpsColors.error,
    );
  }

  void showWarning(String message) {
    _showSnackbar(
      message:   message,
      icon:      Icons.warning_amber_rounded,
      bgColor:   OpsColors.warning,
    );
  }

  void showInfo(String message) {
    _showSnackbar(
      message:   message,
      icon:      Icons.info_outline_rounded,
      bgColor:   OpsColors.info,
    );
  }

  void _showSnackbar({
    required String   message,
    required IconData icon,
    required Color    bgColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: OpsTextStyles.bodySmall.copyWith(
                      color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: bgColor,
          duration:        duration,
          behavior:        SnackBarBehavior.floating,
          margin: const EdgeInsets.all(
              OpsDimensions.space16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                OpsDimensions.radiusMD),
          ),
        ),
      );
  }

  // ─────────────────────────────────────────────
  // Media query helpers
  // ─────────────────────────────────────────────

  Size   get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth  => screenSize.width;
  double get screenHeight => screenSize.height;

  bool get isWideScreen =>
      screenWidth >= OpsConstants.sidebarBreakpoint;
}

extension OpsStringExtensions on String {
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : w.capitalised)
      .join(' ');

  /// Converts snake_case to human-readable Title Case.
  String get fromSnakeCase => replaceAll('_', ' ').titleCase;

  bool get isValidMobile =>
      RegExp(r'^[6-9]\d{9}$').hasMatch(this);

  bool get isValidEmail =>
      RegExp(r'^[\w.]+@[\w]+\.[\w.]+$').hasMatch(this);
}

extension OpsDoubleExtensions on double {
  String get compact {
    if (this >= 1e7)   return '${(this / 1e7).toStringAsFixed(1)}Cr';
    if (this >= 1e5)   return '${(this / 1e5).toStringAsFixed(1)}L';
    if (this >= 1000)  return '${(this / 1000).toStringAsFixed(1)}K';
    return toStringAsFixed(0);
  }

  String get inr => '₹${compact}';
}

extension OpsIntExtensions on int {
  String get compact => toDouble().compact;
}