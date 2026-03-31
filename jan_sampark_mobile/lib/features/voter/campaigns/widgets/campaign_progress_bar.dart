import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Detailed campaign progress section used on the detail screen.
///
/// Shows the progress bar with amount raised, target,
/// donor count and days remaining.
class CampaignProgressBar extends StatelessWidget {
  const CampaignProgressBar({
    super.key,
    required this.amountCollected,
    required this.targetAmount,
    required this.progressPct,
    required this.donationCount,
    required this.daysRemaining,
    this.showLabels = true,
  });

  final double amountCollected;
  final double targetAmount;
  final double progressPct;
  final int donationCount;
  final int daysRemaining;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final clampedPct = (progressPct / 100).clamp(0.0, 1.0);
    final pctLabel = '${progressPct.toStringAsFixed(1)}%';
    final isGoalMet = progressPct >= 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Progress bar ─────────────────────────
        Stack(
          children: [
            // Background track
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            // Fill
            FractionallySizedBox(
              widthFactor: clampedPct,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isGoalMet
                        ? [AppColors.success, AppColors.success]
                        : [AppColors.primaryAccent, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── Amount row ───────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CurrencyFormatter.formatCompact(amountCollected),
                    style: AppTextStyles.metricSmall,
                  ),
                  Text(
                    'raised of '
                    '${CurrencyFormatter.formatCompact(targetAmount)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // Percentage badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isGoalMet
                    ? AppColors.successLight
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                pctLabel,
                style: AppTextStyles.captionMedium.copyWith(
                  color: isGoalMet ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          ],
        ),

        if (showLabels) ...[
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // ── Stats row ─────────────────────────
          Row(
            children: [
              _StatItem(
                icon: Icons.people_outline,
                value: '$donationCount',
                label: 'Donors',
              ),
              const SizedBox(width: AppDimensions.spaceXXL),
              _StatItem(
                icon: Icons.schedule_outlined,
                value: daysRemaining > 0 ? '$daysRemaining days' : 'Ended',
                label: daysRemaining > 0 ? 'Remaining' : '',
                valueColor: daysRemaining <= 3 && daysRemaining > 0
                    ? AppColors.warning
                    : null,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 3),
          Text(label, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}
