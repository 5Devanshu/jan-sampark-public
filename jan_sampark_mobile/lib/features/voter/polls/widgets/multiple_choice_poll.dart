import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/poll_models.dart';

/// Radio-button option list for multiple_choice and yes_no polls.
class MultipleChoicePoll extends StatelessWidget {
  const MultipleChoicePoll({
    super.key,
    required this.options,
    required this.selectedOptionId,
    required this.onSelected,
    this.isEnabled = true,
  });

  final List<PollOption> options;
  final String? selectedOptionId;
  final void Function(String optionId) onSelected;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((opt) {
        final isSelected = opt.optionId == selectedOptionId;
        return GestureDetector(
          onTap: isEnabled ? () => onSelected(opt.optionId) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderGrey,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Radio indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.inputBorder,
                      width: isSelected ? 6 : 2,
                    ),
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    opt.optionText,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
