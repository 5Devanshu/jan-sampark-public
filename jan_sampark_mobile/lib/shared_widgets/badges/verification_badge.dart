import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// EPIC verified / unverified badge for voter profile.
///
/// Usage:
///   VerificationBadge(isVerified: voter.epicVerified)
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({
    super.key,
    required this.isVerified,
    this.showLabel = true,
    this.small     = false,
  });

  final bool isVerified;
  final bool showLabel;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final bg    = isVerified ? AppColors.verifiedBg    : AppColors.unverifiedBg;
    final color = isVerified ? AppColors.verifiedText  : AppColors.unverifiedText;
    final icon  = isVerified ? Icons.verified_rounded  : Icons.error_outline_rounded;
    final label = isVerified ? 'Verified' : 'Unverified';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical:   small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(AppDimensions.badgeRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: small ? 12 : 14),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: (small
                      ? AppTextStyles.labelSmall
                      : AppTextStyles.captionMedium)
                  .copyWith(color: color),
            ),
          ],
        ],
      ),
    );
  }
}