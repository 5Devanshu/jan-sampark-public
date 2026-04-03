import 'package:flutter/material.dart';
import '../../core/theme/ops_colors.dart';
import '../../core/theme/ops_text_styles.dart';
import '../../core/theme/ops_dimensions.dart';

/// Metric card shown in the dashboard stats row.
///
/// Usage:
///   OpsStatCard(
///     title:    'Total Voters',
///     value:    '1,24,593',
///     icon:     Icons.people_outline,
///     color:    OpsColors.primary,
///     trend:    12.4,      // +12.4% vs last period
///     subtitle: 'vs last 30 days',
///   )
class OpsStatCard extends StatelessWidget {
  const OpsStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.subtitle,
    this.onTap,
    this.isLoading = false,
  });

  final String   title;
  final String   value;
  final IconData icon;
  final Color    color;
  final double?  trend;
  final String?  subtitle;
  final VoidCallback? onTap;
  final bool     isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(OpsDimensions.cardPadding),
        decoration: BoxDecoration(
          color:        OpsColors.white,
          borderRadius: BorderRadius.circular(
              OpsDimensions.cardRadius),
          border: Border.all(color: OpsColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? const _CardSkeleton()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row ─────────────────────────
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width:  40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:        color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              OpsDimensions.radiusMD + 2),
                        ),
                        child: Icon(icon,
                            color: color,
                            size:  OpsDimensions.iconLG),
                      ),

                      const Spacer(),

                      // Trend badge
                      if (trend != null)
                        _TrendBadge(trend: trend!),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Value ──────────────────────────────
                  Text(value,
                      style: OpsTextStyles.display),

                  const SizedBox(height: 4),

                  // ── Title ──────────────────────────────
                  Text(title,
                      style: OpsTextStyles.body.copyWith(
                        color: OpsColors.textSecondary,
                      )),

                  // ── Subtitle ───────────────────────────
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!,
                        style: OpsTextStyles.caption),
                  ],
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Trend badge
// ─────────────────────────────────────────────

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.trend});
  final double trend;

  @override
  Widget build(BuildContext context) {
    if (trend == 0) return const SizedBox.shrink();

    final isPositive = trend > 0;
    final color      = isPositive ? OpsColors.success : OpsColors.error;
    final bgColor    = isPositive
        ? OpsColors.successLight
        : OpsColors.errorLight;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: color,
            size:  12,
          ),
          const SizedBox(width: 4),
          Text(
            '${trend.abs().toStringAsFixed(1)}%',
            style: OpsTextStyles.caption.copyWith(
              color:      color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Loading skeleton
// ─────────────────────────────────────────────

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Shimmer(width: 40, height: 40,
            radius: OpsDimensions.radiusMD + 2),
        const SizedBox(height: 16),
        _Shimmer(width: 100, height: 28),
        const SizedBox(height: 6),
        _Shimmer(width: 80, height: 14),
      ],
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({
    required this.width,
    required this.height,
    this.radius = 6,
  });
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width,
      height: height,
      decoration: BoxDecoration(
        color:        OpsColors.borderGrey,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
