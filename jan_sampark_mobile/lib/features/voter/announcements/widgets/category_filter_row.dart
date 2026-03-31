import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/constants/app_constants.dart';

/// Horizontally scrolling category filter chips
/// for the announcements list.
class CategoryFilterRow extends StatelessWidget {
  const CategoryFilterRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final void Function(String) onChanged;

  static final _categories = [
    const _Cat('all', 'All', Icons.apps_rounded),
    const _Cat('announcement', 'Announcements', Icons.campaign_outlined),
    const _Cat('policy', 'Policy', Icons.policy_outlined),
    const _Cat('scheme', 'Schemes', Icons.card_giftcard_outlined),
    const _Cat('achievement', 'Achievements', Icons.emoji_events_outlined),
    const _Cat('party_message', 'Party', Icons.groups_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
        ),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isActive = selected == cat.value;
          return GestureDetector(
            onTap: () => onChanged(cat.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.borderGrey,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 14,
                    color: isActive ? AppColors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    cat.label,
                    style: AppTextStyles.captionMedium.copyWith(
                      color: isActive
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Cat {
  const _Cat(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;
}
