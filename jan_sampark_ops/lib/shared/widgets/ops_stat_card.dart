import 'package:flutter/material.dart';
import '../../core/theme/ops_colors.dart';
import '../../core/theme/ops_text_styles.dart';

class OpsStatCard extends StatelessWidget {
  const OpsStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.subtitle,
  });

  final String   title;
  final String   value;
  final IconData icon;
  final Color    color;
  final double?  trend;
  final String?  subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        OpsColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: OpsColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width:  38,
                height: 38,
                decoration: BoxDecoration(
                  color:        color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (trend != null) _TrendBadge(trend: trend!),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: OpsTextStyles.display),
          const SizedBox(height: 4),
          Text(title, style: OpsTextStyles.bodySecondary),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: OpsTextStyles.caption),
          ],
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.trend});
  final double trend;

  @override
  Widget build(BuildContext context) {
    if (trend == 0) return const SizedBox.shrink();
    final isUp  = trend > 0;
    final color = isUp ? OpsColors.success : OpsColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: color,
            size:  12,
          ),
          const SizedBox(width: 3),
          Text(
            '${trend.abs().toStringAsFixed(1)}%',
            style: OpsTextStyles.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}