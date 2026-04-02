import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/corporator_leader_models.dart';

/// Toggle chip grid for selecting leader responsibilities.
/// Used on both Create and Edit screens.
class LeaderResponsibilitySelector extends StatelessWidget {
  const LeaderResponsibilitySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Set<String>                        selected;
  final void Function(Set<String> updated) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Responsibilities',
            style: AppTextStyles.heading3),
        const SizedBox(height: AppDimensions.spaceSM),
        Text(
          'Select what this leader is permitted to do.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        Wrap(
          spacing:    8,
          runSpacing: 8,
          children: kLeaderResponsibilities.entries.map((e) {
            final isSelected = selected.contains(e.key);
            return GestureDetector(
              onTap: () {
                final updated = Set<String>.from(selected);
                if (isSelected) {
                  updated.remove(e.key);
                } else {
                  updated.add(e.key);
                }
                onChanged(updated);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderGrey,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_rounded,
                        size:  13,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      e.value,
                      style: AppTextStyles.captionMedium
                          .copyWith(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        if (selected.isEmpty) ...[
          const SizedBox(height: AppDimensions.spaceSM),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:        AppColors.warningLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.warningBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.warning, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No responsibilities selected — '
                    'this leader will have read-only access.',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}