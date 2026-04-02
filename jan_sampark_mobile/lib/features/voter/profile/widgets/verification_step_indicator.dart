// lib/features/voter/profile/widgets/verification_step_indicator.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Horizontal step indicator for the verification flow.
class VerificationStepIndicator extends StatelessWidget {
  const VerificationStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels = const [],
  });

  final int currentStep; // 1-based
  final int totalSteps;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final safeTotal = totalSteps < 1 ? 1 : totalSteps;
    final safeCurrent =
        currentStep.clamp(1, safeTotal);

    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical: 12,
      ),
      child: Row(
        children: List.generate(safeTotal * 2 - 1, (index) {
          if (index.isOdd) {
            final isActive = (index ~/ 2) + 1 < safeCurrent;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: isActive
                    ? AppColors.primary
                    : AppColors.borderGrey,
              ),
            );
          }

          final step = (index ~/ 2) + 1;
          final isActive = step <= safeCurrent;
          final label = labels.length >= step
              ? labels[step - 1]
              : 'Step $step';

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.borderGrey,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$step',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive
                        ? AppColors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
