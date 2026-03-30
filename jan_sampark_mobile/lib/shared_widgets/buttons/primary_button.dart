import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Full-width primary blue button.
///
/// Usage:
///   PrimaryButton(
///     label: 'Login',
///     onPressed: () => ...,
///     isLoading: state.isLoading,
///   )
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.height = AppDimensions.buttonHeightLG,
    this.width,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double height;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final isActive = !isLoading && !isDisabled && onPressed != null;

    return SizedBox(
      height: height,
      width:  width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isActive ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? (backgroundColor ?? AppColors.primary)
              : AppColors.primaryLight,
          foregroundColor: isActive
              ? (textColor ?? AppColors.textOnPrimary)
              : AppColors.primaryAccent,
          disabledBackgroundColor: AppColors.primaryLight,
          disabledForegroundColor: AppColors.primaryAccent,
          elevation:    0,
          shadowColor:  Colors.transparent,
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
                  color: textColor ?? AppColors.textOnPrimary,
                ),
              )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize:      MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.buttonLarge),
        ],
      );
    }
    return Text(label, style: AppTextStyles.buttonLarge);
  }
}