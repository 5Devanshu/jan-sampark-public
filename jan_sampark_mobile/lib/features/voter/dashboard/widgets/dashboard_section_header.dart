// lib/features/voter/dashboard/widgets/dashboard_section_header.dart
//
// Reusable section header used between every dashboard card group.
// Shows a section title on the left and an optional "See all →" link.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.seeAllLabel = 'See all',
    this.onSeeAll,
  });

  final String    title;
  final String?   subtitle;
  final String    seeAllLabel;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.heading3),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTextStyles.bodySecondary),
                ],
              ],
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  '$seeAllLabel →',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}