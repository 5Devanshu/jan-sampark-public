import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Compact icon + label button used in action bars and quick action rows.
///
/// Usage:
///   IconActionButton(
///     icon:    Icons.add_circle_outline,
///     label:   'File Complaint',
///     onPressed: () => ...,
///   )
class IconActionButton extends StatelessWidget {
  const IconActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = _defaultSize,
    this.showBackground = true,
  });

  static const double _defaultSize = 44.0;

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.primary;
    final bgColor   = backgroundColor ?? AppColors.primaryLight;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:  size,
            height: size,
            decoration: showBackground
                ? BoxDecoration(
                    color:        bgColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  )
                : null,
            child: Icon(icon, color: iconColor, size: AppDimensions.iconMD),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: iconColor),
            textAlign: TextAlign.center,
            maxLines:  2,
            overflow:  TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}