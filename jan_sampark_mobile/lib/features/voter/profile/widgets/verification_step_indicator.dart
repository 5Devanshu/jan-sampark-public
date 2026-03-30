// lib/features/voter/profile/widgets/ocr_status_banner.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/voter_profile_models.dart';

/// Banner inside the profile screen showing OCR ID doc status.
class OcrStatusBanner extends StatelessWidget {
  const OcrStatusBanner({
    super.key,
    required this.ocrStatus,
    required this.onViewDetail,
    required this.onRetry,
  });

  final OcrJobStatus? ocrStatus;
  final VoidCallback  onViewDetail;
  final VoidCallback  onRetry;

  @override
  Widget build(BuildContext context) {
    if (ocrStatus == null) return const SizedBox.shrink();

    final Color bg, border, iconColor;
    final IconData iconData;
    final String   title, subtitle;
    bool showRetry   = false;
    bool showDetails = false;

    switch (ocrStatus!.status) {
      case 'queued':
      case 'processing':
        bg        = AppColors.primaryLight;
        border    = AppColors.primaryFocus;
        iconColor = AppColors.primary;
        iconData  = Icons.hourglass_top_rounded;
        title     = 'ID Verification In Progress';
        subtitle  = 'Your ID document is being processed. '
                    'This may take a few minutes.';
        break;
      case 'completed':
        bg        = AppColors.successLight;
        border    = AppColors.successBorder;
        iconColor = AppColors.success;
        iconData  = Icons.check_circle_outline;
        title     = 'ID Document Verified';
        subtitle  = 'Your ID has been scanned and verified successfully.';
        showDetails = true;
        break;
      case 'failed':
        bg        = AppColors.errorLight;
        border    = AppColors.errorBorder;
        iconColor = AppColors.error;
        iconData  = Icons.error_outline;
        title     = 'ID Verification Failed';
        subtitle  = ocrStatus!.errorMessage ??
                    'We could not read your ID document. '
                    'Please try again with a clearer image.';
        showRetry   = true;
        showDetails = true;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:    const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:  iconColor.withOpacity(0.15),
              shape:  BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: iconColor,
                    )),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTextStyles.caption),
                if (showRetry || showDetails) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (showDetails)
                        GestureDetector(
                          onTap: onViewDetail,
                          child: Text(
                            'View Details',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: iconColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      if (showDetails && showRetry) const SizedBox(width: 16),
                      if (showRetry)
                        GestureDetector(
                          onTap: onRetry,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:        iconColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'Retry OCR',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
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