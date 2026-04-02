import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/corporator_models.dart';

/// Horizontal bar chart row for complaints by priority and category.
class AnalyticsChartRow extends StatelessWidget {
  const AnalyticsChartRow({
    super.key,
    required this.complaints,
  });
  final ComplaintAnalytics complaints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Priority breakdown ─────────────────
        Text('By Priority', style: AppTextStyles.heading3),
        const SizedBox(height: AppDimensions.spaceMD),
        _PriorityBars(byPriority: complaints.byPriority),

        const SizedBox(height: AppDimensions.spaceXL),

        // ── Status breakdown ───────────────────
        Text('By Status', style: AppTextStyles.heading3),
        const SizedBox(height: AppDimensions.spaceMD),
        _StatusBars(complaints: complaints),

        if (complaints.byCategory.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spaceXL),
          Text('Top Categories', style: AppTextStyles.heading3),
          const SizedBox(height: AppDimensions.spaceMD),
          _CategoryBars(
            categories: complaints.byCategory.take(5).toList(),
          ),
        ],
      ],
    );
  }
}

class _PriorityBars extends StatelessWidget {
  const _PriorityBars({required this.byPriority});
  final Map<String, int> byPriority;

  static const _colors = {
    'emergency': AppColors.priorityEmergencyText,
    'high':      AppColors.priorityHighText,
    'medium':    AppColors.priorityMediumText,
    'low':       AppColors.priorityLowText,
  };

  static const _labels = {
    'emergency': 'Emergency',
    'high':      'High',
    'medium':    'Medium',
    'low':       'Low',
  };

  @override
  Widget build(BuildContext context) {
    final total = byPriority.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    return Column(
      children: ['emergency', 'high', 'medium', 'low'].map((p) {
        final count = byPriority[p] ?? 0;
        final pct   = total > 0 ? count / total : 0.0;
        final color = _colors[p] ?? AppColors.textSecondary;
        return Padding(
          padding: const EdgeInsets.only(
              bottom: AppDimensions.spaceMD),
          child: _Bar(
            label:  _labels[p] ?? p,
            value:  count,
            pct:    pct,
            color:  color,
            total:  total,
          ),
        );
      }).toList(),
    );
  }
}

class _StatusBars extends StatelessWidget {
  const _StatusBars({required this.complaints});
  final ComplaintAnalytics complaints;

  @override
  Widget build(BuildContext context) {
    final total = complaints.total;
    if (total == 0) {
      return Text('No complaint data.',
          style: AppTextStyles.bodySecondary);
    }

    final statuses = [
      ('Pending',     complaints.pending,     AppColors.statusPendingText),
      ('Acknowledged', complaints.acknowledged, AppColors.statusAcknowledgedText),
      ('In Progress', complaints.inProgress,   AppColors.statusInProgressText),
      ('Escalated',   complaints.escalated,    AppColors.statusEscalatedText),
      ('Resolved',    complaints.resolved,     AppColors.statusResolvedText),
      ('Rejected',    complaints.rejected,     AppColors.statusRejectedText),
    ];

    return Column(
      children: statuses.map((s) {
        final pct = total > 0 ? s.$2 / total : 0.0;
        return Padding(
          padding: const EdgeInsets.only(
              bottom: AppDimensions.spaceMD),
          child: _Bar(
            label: s.$1,
            value: s.$2,
            pct:   pct,
            color: s.$3,
            total: total,
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryBars extends StatelessWidget {
  const _CategoryBars({required this.categories});
  final List<CategoryCount> categories;

  @override
  Widget build(BuildContext context) {
    final max = categories.isNotEmpty
        ? categories.map((c) => c.count).reduce((a, b) => a > b ? a : b)
        : 1;

    return Column(
      children: categories.map((cat) {
        final pct = max > 0 ? cat.count / max : 0.0;
        return Padding(
          padding: const EdgeInsets.only(
              bottom: AppDimensions.spaceMD),
          child: _Bar(
            label: cat.categoryName,
            value: cat.count,
            pct:   pct,
            color: AppColors.primary,
            total: max,
          ),
        );
      }).toList(),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.value,
    required this.pct,
    required this.color,
    required this.total,
  });

  final String label;
  final int    value;
  final double pct;
  final Color  color;
  final int    total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: AppTextStyles.bodyMedium,
                  overflow: TextOverflow.ellipsis),
            ),
            Text(
              '$value',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            FractionallySizedBox(
              widthFactor: pct.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}