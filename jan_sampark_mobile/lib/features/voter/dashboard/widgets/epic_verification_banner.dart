// lib/features/voter/dashboard/widgets/epic_verification_banner.dart
//
// Prominent amber banner shown when the voter has NOT yet verified
// their EPIC (Voter ID card). Shown between the greeting and quick actions.
// Dismissed when the voter taps "Verify Now".

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';

class EpicVerificationBanner extends StatelessWidget {
  const EpicVerificationBanner({
    super.key,
    required this.ocrStatus,
  });

  /// OCR status from the profile: null | 'pending' | 'processing' | 'completed' | 'failed'
  final String? ocrStatus;

  @override
  Widget build(BuildContext context) {
    // If OCR completed, verification should be accessible — show nudge.
    // If OCR is processing, show a different message.
    final isProcessing = ocrStatus == 'pending' || ocrStatus == 'processing';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical:   AppDimensions.spaceMD,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        isProcessing ? AppColors.primaryLight : AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: isProcessing ? AppColors.primaryFocus : AppColors.warningBorder,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon ───────────────────────────────
          Container(
            padding:     const EdgeInsets.all(8),
            decoration:  BoxDecoration(
              color:        isProcessing
                  ? AppColors.primary.withOpacity(0.12)
                  : AppColors.warning.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isProcessing ? Icons.hourglass_top_rounded : Icons.warning_amber_rounded,
              color: isProcessing ? AppColors.primary : AppColors.warning,
              size:  20,
            ),
          ),

          const SizedBox(width: 12),

          // ── Text + CTA ─────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isProcessing
                      ? 'ID Verification In Progress'
                      : 'Verify Your Voter ID',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isProcessing ? AppColors.primary : AppColors.warning,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isProcessing
                      ? 'Your ID document is being processed. '
                        'We\'ll notify you when it\'s done.'
                      : 'Link your EPIC card to confirm your identity '
                        'and access all features.',
                  style: AppTextStyles.caption.copyWith(
                    color: isProcessing
                        ? AppColors.textSecondary
                        : AppColors.warning,
                  ),
                ),
                if (!isProcessing) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => context.pushNamed(RouteNames.verificationResult),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:        AppColors.warning,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'Verify Now →',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}