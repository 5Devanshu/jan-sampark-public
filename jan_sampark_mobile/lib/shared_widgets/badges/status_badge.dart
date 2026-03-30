import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Status badge pill for complaints, donations, events.
///
/// Usage:
///   StatusBadge(status: 'pending')
///   StatusBadge(status: 'resolved')
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  final String status;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final config = _config(status.toLowerCase());
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small
            ? AppDimensions.badgePaddingHSM
            : AppDimensions.badgePaddingH,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color:        config.bg,
        borderRadius: BorderRadius.circular(AppDimensions.badgeRadius),
      ),
      child: Text(
        config.label,
        style: (small ? AppTextStyles.labelSmall : AppTextStyles.captionMedium)
            .copyWith(color: config.text),
      ),
    );
  }

  _BadgeConfig _config(String s) {
    return switch (s) {
      'pending'        => _BadgeConfig(
          AppColors.statusPendingBg,
          AppColors.statusPendingText,
          'Pending'),
      'acknowledged'   => _BadgeConfig(
          AppColors.statusAcknowledgedBg,
          AppColors.statusAcknowledgedText,
          'Acknowledged'),
      'in_progress'    => _BadgeConfig(
          AppColors.statusInProgressBg,
          AppColors.statusInProgressText,
          'In Progress'),
      'resolved'       => _BadgeConfig(
          AppColors.statusResolvedBg,
          AppColors.statusResolvedText,
          'Resolved'),
      'closed'         => _BadgeConfig(
          AppColors.statusClosedBg,
          AppColors.statusClosedText,
          'Closed'),
      'rejected'       => _BadgeConfig(
          AppColors.statusRejectedBg,
          AppColors.statusRejectedText,
          'Rejected'),
      'escalated'      => _BadgeConfig(
          AppColors.statusEscalatedBg,
          AppColors.statusEscalatedText,
          'Escalated'),
      'accepted'       => _BadgeConfig(
          AppColors.statusAcceptedBg,
          AppColors.statusAcceptedText,
          'Accepted'),
      'pending_review' => _BadgeConfig(
          AppColors.statusReviewBg,
          AppColors.statusReviewText,
          'Under Review'),
      'active'         => _BadgeConfig(
          AppColors.statusResolvedBg,
          AppColors.statusResolvedText,
          'Active'),
      'upcoming'       => _BadgeConfig(
          AppColors.statusAcknowledgedBg,
          AppColors.statusAcknowledgedText,
          'Upcoming'),
      'completed'      => _BadgeConfig(
          AppColors.statusClosedBg,
          AppColors.statusClosedText,
          'Completed'),
      'cancelled'      => _BadgeConfig(
          AppColors.statusRejectedBg,
          AppColors.statusRejectedText,
          'Cancelled'),
      'draft'          => _BadgeConfig(
          AppColors.statusClosedBg,
          AppColors.statusClosedText,
          'Draft'),
      'published'      => _BadgeConfig(
          AppColors.statusResolvedBg,
          AppColors.statusResolvedText,
          'Published'),
      'closed'         => _BadgeConfig(
          AppColors.statusClosedBg,
          AppColors.statusClosedText,
          'Closed'),
      _                => _BadgeConfig(
          AppColors.statusClosedBg,
          AppColors.statusClosedText,
          s.capitalised),
    };
  }
}

class _BadgeConfig {
  const _BadgeConfig(this.bg, this.text, this.label);
  final Color  bg;
  final Color  text;
  final String label;
}

import '../../core/utils/extensions.dart';