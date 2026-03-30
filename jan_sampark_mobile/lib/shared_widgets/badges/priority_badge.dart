import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Priority badge for complaint cards.
///
/// Usage:
///   PriorityBadge(priority: 'high')
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final config = _config(priority.toLowerCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        config.bg,
        borderRadius: BorderRadius.circular(AppDimensions.badgeRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: config.dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: AppTextStyles.labelSmall.copyWith(color: config.text),
          ),
        ],
      ),
    );
  }

  _PriorityConfig _config(String p) {
    return switch (p) {
      'low'       => _PriorityConfig(
          AppColors.priorityLowBg,
          AppColors.priorityLowText,
          AppColors.priorityLowText,
          'Low'),
      'medium'    => _PriorityConfig(
          AppColors.priorityMediumBg,
          AppColors.priorityMediumText,
          AppColors.priorityMediumText,
          'Medium'),
      'high'      => _PriorityConfig(
          AppColors.priorityHighBg,
          AppColors.priorityHighText,
          AppColors.priorityHighText,
          'High'),
      'emergency' => _PriorityConfig(
          AppColors.priorityEmergencyBg,
          AppColors.priorityEmergencyText,
          AppColors.priorityEmergencyText,
          'Emergency'),
      _           => _PriorityConfig(
          AppColors.priorityLowBg,
          AppColors.priorityLowText,
          AppColors.priorityLowText,
          p),
    };
  }
}

class _PriorityConfig {
  const _PriorityConfig(this.bg, this.text, this.dot, this.label);
  final Color  bg;
  final Color  text;
  final Color  dot;
  final String label;
}