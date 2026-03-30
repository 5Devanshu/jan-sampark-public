import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

/// Reusable Yes/No confirmation dialog.
///
/// Usage:
///   final confirmed = await showConfirmDialog(
///     context:     context,
///     title:       'Reject Complaint',
///     message:     'Are you sure you want to reject this complaint?',
///     confirmLabel: 'Yes, Reject',
///     isDestructive: true,
///   );
///   if (confirmed == true) { ... }
Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel  = 'Confirm',
  String cancelLabel   = 'Cancel',
  bool isDestructive   = false,
  IconData? icon,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ConfirmDialog(
      title:         title,
      message:       message,
      confirmLabel:  confirmLabel,
      cancelLabel:   cancelLabel,
      isDestructive: isDestructive,
      icon:          icon,
    ),
  );
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel  = 'Confirm',
    this.cancelLabel   = 'Cancel',
    this.isDestructive = false,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──────────────────────────────
            if (icon != null) ...[
              Container(
                width:  56, height: 56,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.errorLight
                      : AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDestructive
                      ? AppColors.error
                      : AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMD),
            ],

            // ── Title ─────────────────────────────
            Text(title,
                style:     AppTextStyles.heading2,
                textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.spaceSM),

            // ── Message ───────────────────────────
            Text(message,
                style:     AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.spaceXL),

            // ── Actions ───────────────────────────
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label:     cancelLabel,
                    height:    AppDimensions.buttonHeightMD,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  child: PrimaryButton(
                    label:           confirmLabel,
                    height:          AppDimensions.buttonHeightMD,
                    backgroundColor: isDestructive
                        ? AppColors.error
                        : AppColors.primary,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}