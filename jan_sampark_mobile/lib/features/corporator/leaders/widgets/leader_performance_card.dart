import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/corporator_leader_models.dart';

/// Performance metrics card shown on the leader detail screen.
class LeaderPerformanceCard extends StatelessWidget {
  const LeaderPerformanceCard({
    super.key,
    required this.leader,
  });
  final CorporatorLeaderDetail leader;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text('Performance',
                style: AppTextStyles.heading3),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),

          // Metrics grid
          Padding(
            padding: const EdgeInsets.all(
                AppDimensions.cardPaddingH),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap:     true,
              physics:        const NeverScrollableScrollPhysics(),
              childAspectRatio:  2.6,
              crossAxisSpacing:  AppDimensions.spaceMD,
              mainAxisSpacing:   AppDimensions.spaceMD,
              children: [
                _MetricTile(
                  icon:  Icons.assignment_outlined,
                  label: 'Assigned',
                  value: '${leader.complaintsAssigned}',
                  color: AppColors.primary,
                ),
                _MetricTile(
                  icon:  Icons.thumb_up_outlined,
                  label: 'Acknowledged',
                  value: '${leader.complaintsAcknowledged}',
                  color: AppColors.success,
                ),
                _MetricTile(
                  icon:  Icons.warning_amber_outlined,
                  label: 'Escalated',
                  value: '${leader.complaintsEscalated}',
                  color: AppColors.escalation,
                ),
                _MetricTile(
                  icon:  Icons.location_on_outlined,
                  label: 'Verifications',
                  value: '${leader.groundVerifications}',
                  color: AppColors.primaryAccent,
                ),
              ],
            ),
          ),

          // Resolution rate bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.cardPaddingH,
              0,
              AppDimensions.cardPaddingH,
              AppDimensions.cardPaddingH,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Acknowledgement Rate',
                        style: AppTextStyles.captionMedium,
                      ),
                    ),
                    Text(
                      '${leader.resolutionRate.toStringAsFixed(1)}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (leader.resolutionRate / 100)
                      .clamp(0.0, 1.0),
                  minHeight:       8,
                  backgroundColor: AppColors.primaryLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [
              Text(value,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: color)),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}