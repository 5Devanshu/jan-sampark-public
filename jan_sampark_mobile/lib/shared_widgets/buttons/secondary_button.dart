import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Full-width outlined secondary button.
///
/// Usage:
///   SecondaryButton(
///     label: 'Cancel',
///     onPressed: () => context.pop(),
///   )
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.height = AppDimensions.buttonHeightLG,
    this.width,
    this.borderColor,
    this.textColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double height;
  final double? width;
  final Color? borderColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final isActive = !isLoading && !isDisabled && onPressed != null;
    final fgColor  = textColor ?? AppColors.primary;
    final bdColor  = borderColor ?? AppColors.primary;

    return SizedBox(
      height: height,
      width:  width ?? double.infinity,
      child: OutlinedButton(
        onPressed: isActive ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: fgColor,
          disabledForegroundColor: AppColors.textDisabled,
          side: BorderSide(
            color: isActive ? bdColor : AppColors.borderGrey,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width:  22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: fgColor,
                ),
              )
            : _buildContent(fgColor),
      ),
    );
  }

  Widget _buildContent(Color color) {
    final style = AppTextStyles.buttonLarge.copyWith(color: color);
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize:      MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(label, style: style),
        ],
      );
    }
    return Text(label, style: style);
  }
}