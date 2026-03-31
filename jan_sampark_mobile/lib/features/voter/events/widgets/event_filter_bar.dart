import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Horizontal scrolling filter chips for event list.
///
/// Usage:
///   EventFilterBar(
///     selected:  'upcoming',
///     onChanged: (filter) => notifier.setFilter(filter),
///   )
class EventFilterBar extends StatelessWidget {
  const EventFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final void Function(String) onChanged;

  static const _filters = [
    _Filter('all', 'All Events'),
    _Filter('upcoming', 'Upcoming'),
    _Filter('ongoing', 'Ongoing'),
    _Filter('completed', 'Past'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
        ),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final filter = _filters[i];
          final isActive = selected == filter.value;
          return GestureDetector(
            onTap: () => onChanged(filter.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.borderGrey,
                ),
              ),
              child: Text(
                filter.label,
                style: AppTextStyles.captionMedium.copyWith(
                  color: isActive ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Filter {
  const _Filter(this.value, this.label);
  final String value;
  final String label;
}
