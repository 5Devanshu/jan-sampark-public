import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Two large Yes/No buttons for yes_no polls.
class YesNoPoll extends StatelessWidget {
  const YesNoPoll({
    super.key,
    required this.selectedOptionId,
    required this.onSelected,
    this.isEnabled = true,
  });

  final String? selectedOptionId;
  final void Function(String optionId) onSelected;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BigButton(
            optionId: 'yes',
            label: 'Yes',
            icon: Icons.thumb_up_outlined,
            activeColor: AppColors.success,
            isSelected: selectedOptionId == 'yes',
            isEnabled: isEnabled,
            onTap: () => onSelected('yes'),
          ),
        ),
        const SizedBox(width: AppDimensions.spaceMD),
        Expanded(
          child: _BigButton(
            optionId: 'no',
            label: 'No',
            icon: Icons.thumb_down_outlined,
            activeColor: AppColors.error,
            isSelected: selectedOptionId == 'no',
            isEnabled: isEnabled,
            onTap: () => onSelected('no'),
          ),
        ),
      ],
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.optionId,
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final String optionId;
  final String label;
  final IconData icon;
  final Color activeColor;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 90,
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.borderGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? activeColor : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? activeColor : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
