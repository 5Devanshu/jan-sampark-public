import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Inline text link button with no padding or background.
///
/// Usage:
///   TextButtonLink(label: 'Resend OTP', onPressed: ...)
class TextButtonLink extends StatelessWidget {
  const TextButtonLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDisabled = false,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.underline = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    final textColor = isDisabled
        ? AppColors.textDisabled
        : (color ?? AppColors.primary);

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Text(
        label,
        style: AppTextStyles.buttonPrimary.copyWith(
          color:      textColor,
          fontSize:   fontSize,
          fontWeight: fontWeight,
          decoration: underline ? TextDecoration.underline : null,
          decorationColor: textColor,
        ),
      ),
    );
  }
}