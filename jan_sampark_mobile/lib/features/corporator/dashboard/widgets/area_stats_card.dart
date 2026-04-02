import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../models/corporator_models.dart';

/// Hero stats row at the top of the Corporator dashboard.
class AreaStatsCard extends StatelessWidget {
  const AreaStatsCard({super.key, required this.dashboard});
  final AreaDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final c = dashboard.complaints;
    final v = dashboard.voters;
    final cam = dashboard.campaigns;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Area Overview',
              style: AppTextStyles.heading3White),
          const SizedBox(height: AppDimensions.spaceMD),

          // ── Top stats row ──────────────────────
          Row(
            children: [
              _StatBox(
                value: '${v.totalVoters}',
                label: 'Voters',
                icon:  Icons.people_outline,
              ),
              _StatBox(
                value: '${c.total}',
                label: 'Complaints',
                icon:  Icons.report_problem_outlined,
              ),
              _StatBox(
                value: '${c.escalated}',
                label: 'Escalated',
                icon:  Icons.warning_amber_rounded,
                highlight: c.escalated > 0,
              ),
              _StatBox(
                value: '${c.resolutionRate.toStringAsFixed(0)}%',
                label: 'Resolved',
                icon:  Icons.check_circle_outline,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceMD),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: AppDimensions.spaceMD),

          // ── Bottom stats row ───────────────────
          Row(
            children: [
              _StatBox(
                value: CurrencyFormatter.formatCompact(
                    cam.totalRaised),
                label: 'Raised',
                icon:  Icons.volunteer_activism_outlined,
              ),
              _StatBox(
                value: '${cam.totalDonors}',
                label: 'Donors',
                icon:  Icons.favorite_outline,
              ),
              _StatBox(
                value: '${dashboard.eventsCount}',
                label: 'Events',
                icon:  Icons.event_outlined,
              ),
              _StatBox(
                value:
                    '${v.verificationRate.toStringAsFixed(0)}%',
                label: 'Verified',
                icon:  Icons.verified_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    this.highlight = false,
  });

  final String   value;
  final String   label;
  final IconData icon;
  final bool     highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? const Color(0xFFFFD700)
        : Colors.white;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.metricSmall.copyWith(
                  color: color)),
          Text(label,
              style: AppTextStyles.labelSmallWhite,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}