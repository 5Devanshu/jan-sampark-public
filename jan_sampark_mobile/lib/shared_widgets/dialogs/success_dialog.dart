import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../buttons/primary_button.dart';

/// Green check success bottom sheet.
///
/// Usage:
///   await showSuccessSheet(
///     context:    context,
///     title:      'Complaint Filed!',
///     message:    'CMP-2025-00012 has been submitted.',
///     buttonLabel: 'View Complaint',
///     onButtonTap: () => context.goNamed(...),
///   );
Future<void> showSuccessSheet({
  required BuildContext context,
  required String title,
  required String message,
  String buttonLabel = 'Done',
  VoidCallback? onButtonTap,
}) {
  return showModalBottomSheet(
    context:           context,
    isDismissible:     false,
    enableDrag:        false,
    isScrollControlled: true,
    builder: (_) => SuccessSheet(
      title:       title,
      message:     message,
      buttonLabel: buttonLabel,
      onButtonTap: onButtonTap,
    ),
  );
}

class SuccessSheet extends StatelessWidget {
  const SuccessSheet({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel = 'Done',
    this.onButtonTap,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onButtonTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Success icon ──────────────────────
            Container(
              width:  80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.successBorder, width: 2),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size:  44,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceXL),

            // ── Title ─────────────────────────────
            Text(title,
                style:     AppTextStyles.heading2,
                textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.spaceSM),

            // ── Message ───────────────────────────
            Text(message,
                style:     AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.spaceXXL),

            // ── Button ────────────────────────────
            PrimaryButton(
              label:     buttonLabel,
              onPressed: onButtonTap ??
                  () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}