import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Shows a floating error snackbar.
/// Convenience wrapper — use context.showError() from extensions.dart
/// directly instead of this function.
///
/// Only use this function outside a BuildContext (e.g. in a notifier
/// when you have a GlobalKey<ScaffoldMessengerState>).
void showErrorSnackbar(
  ScaffoldMessengerState messenger,
  String message, {
  Duration duration = const Duration(seconds: 4),
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: AppTextStyles.bodyWhite),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior:        SnackBarBehavior.floating,
        duration:        duration,
        margin: const EdgeInsets.all(AppDimensions.pagePaddingH),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
      ),
    );
}

void showSuccessSnackbar(
  ScaffoldMessengerState messenger,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: AppTextStyles.bodyWhite),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior:        SnackBarBehavior.floating,
        duration:        duration,
        margin: const EdgeInsets.all(AppDimensions.pagePaddingH),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
      ),
    );
}