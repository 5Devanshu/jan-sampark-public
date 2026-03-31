import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/leader_models.dart';

/// Summary metrics row on the Leader home screen.
/// Shows this-week performance numbers.
class LeaderSummaryRow extends StatelessWidget {
  const LeaderSummaryRow({
    super.key,
    required this.performance,
    required this.summary,
  });

  final LeaderPerformance performance;
  final WardComplaintSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ward Overview', style: AppTextStyles.heading3White),
          const SizedBox(height: AppDimensions.spaceMD),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  value: '${summary.total}',
                  label: 'Total',
                  icon: Icons.report_problem_outlined,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: _MetricTile(
                  value: '${summary.pending}',
                  label: 'Pending',
                  icon: Icons.hourglass_empty_rounded,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: _MetricTile(
                  value: '${summary.escalated}',
                  label: 'Escalated',
                  icon: Icons.warning_amber_rounded,
                  color: summary.escalated > 0
                      ? const Color(0xFFFFD700)
                      : Colors.white,
                ),
              ),
              Expanded(
                child: _MetricTile(
                  value: '${summary.resolved}',
                  label: 'Resolved',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF86EFAC),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: AppDimensions.spaceMD),

          // My performance row
          Text(
            'My Activity',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Row(
            children: [
              _PerformancePill(
                icon: Icons.thumb_up_outlined,
                value: '${performance.complaintsAcknowledged}',
                label: 'Acknowledged',
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              _PerformancePill(
                icon: Icons.arrow_upward_rounded,
                value: '${performance.complaintsEscalated}',
                label: 'Escalated',
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              _PerformancePill(
                icon: Icons.event_outlined,
                value: '${performance.eventsCreated}',
                label: 'Events',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.metricSmall.copyWith(color: color)),
        Text(label, style: AppTextStyles.labelSmallWhite),
      ],
    );
  }
}

class _PerformancePill extends StatelessWidget {
  const _PerformancePill({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text('$value $label', style: AppTextStyles.labelSmallWhite),
        ],
      ),
    );
  }
}
