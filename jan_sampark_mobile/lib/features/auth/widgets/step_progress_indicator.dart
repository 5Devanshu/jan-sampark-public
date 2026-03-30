import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// 4-step registration progress indicator shown at the top
/// of the register screen.
///
/// Usage:
///   StepProgressIndicator(currentStep: 2)  // step 2 of 4
class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = AppConstants.registrationTotalSteps,
  });

  final int currentStep;
  final int totalSteps;

  static const _stepLabels = [
    'Personal',
    'Location',
    'Profile',
    'Documents',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Progress bars ────────────────────────
        Row(
          children: List.generate(totalSteps, (i) {
            final isCompleted = i < currentStep - 1;
            final isActive    = i == currentStep - 1;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                    right: i < totalSteps - 1
                        ? AppDimensions.stepIndicatorSpacing
                        : 0),
                height: AppDimensions.stepIndicatorHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      AppDimensions.stepIndicatorRadius),
                  color: isCompleted || isActive
                      ? AppColors.primary
                      : AppColors.borderGrey,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 10),

        // ── Step label ────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: AppTextStyles.captionMedium
                  .copyWith(color: AppColors.primary),
            ),
            Text(
              _stepLabels[currentStep - 1],
              style: AppTextStyles.captionMedium,
            ),
          ],
        ),
      ],
    );
  }
}