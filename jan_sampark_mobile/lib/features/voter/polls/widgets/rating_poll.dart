import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// 5-star interactive rating widget for rating polls.
class RatingPoll extends StatelessWidget {
  const RatingPoll({
    super.key,
    required this.selectedRating,
    required this.onSelected,
    this.isEnabled = true,
  });

  final int? selectedRating;
  final void Function(int rating) onSelected;
  final bool isEnabled;

  static const _labels = [
    '',
    'Very Poor',
    'Poor',
    'Average',
    'Good',
    'Excellent',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stars row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final star = i + 1;
            final isFilled = selectedRating != null && star <= selectedRating!;
            return GestureDetector(
              onTap: isEnabled ? () => onSelected(star) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFilled
                      ? const Color(0xFFFACC15)
                      : AppColors.borderGrey,
                  size: 44,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: AppDimensions.spaceMD),

        // Label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            selectedRating != null
                ? _labels[selectedRating!]
                : 'Tap a star to rate',
            key: ValueKey(selectedRating),
            style: selectedRating != null
                ? AppTextStyles.heading3.copyWith(color: AppColors.primary)
                : AppTextStyles.bodySecondary,
          ),
        ),

        if (selectedRating != null) ...[
          const SizedBox(height: AppDimensions.spaceMD),
          // Star indicators row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < selectedRating!
                      ? AppColors.primary
                      : AppColors.borderGrey,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
