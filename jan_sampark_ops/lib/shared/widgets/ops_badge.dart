import 'package:flutter/material.dart';
import '../../core/theme/ops_colors.dart';
import '../../core/theme/ops_text_styles.dart';
import '../../core/theme/ops_dimensions.dart';

/// Coloured pill badge — used in tables and cards.
///
/// Usage:
///   OpsBadge(label: 'Active',   color: OpsColors.success)
///   OpsBadge(label: 'Inactive', color: OpsColors.error)
///   OpsBadge.status(isActive: true)
class OpsBadge extends StatelessWidget {
  const OpsBadge({
    super.key,
    required this.label,
    required this.color,
    this.bgColor,
    this.icon,
    this.small = false,
  });

  const OpsBadge.status({
    super.key,
    required bool isActive,
    this.small = false,
  })  : label   = isActive ? 'Active' : 'Inactive',
        color   = isActive ? OpsColors.success : OpsColors.error,
        bgColor = isActive ? OpsColors.successLight : OpsColors.errorLight,
        icon    = null;

  const OpsBadge.role({
    super.key,
    required String role,
    this.small = false,
  })  : label   = role,
        color   = OpsColors.primary,
        bgColor = OpsColors.primaryLight,
        icon    = null;

  final String   label;
  final Color    color;
  final Color?   bgColor;
  final IconData? icon;
  final bool     small;

  @override
  Widget build(BuildContext context) {
    final bg   = bgColor ?? color.withValues(alpha: 0.1);
    final style = small
        ? OpsTextStyles.caption.copyWith(
            color: color, fontWeight: FontWeight.w600)
        : OpsTextStyles.bodySmallMedium.copyWith(color: color);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical:   small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(
            OpsDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: small ? 10 : 12),
            const SizedBox(width: 4),
          ],
          Text(label, style: style),
        ],
      ),
    );
  }
}
