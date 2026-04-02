import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/corporator_models.dart';

/// Voter demographic breakdown section on the dashboard.
class DemographicBreakdown extends StatelessWidget {
  const DemographicBreakdown({
    super.key,
    required this.voters,
  });
  final VoterDemographics voters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── EPIC verification ──────────────────
        _MetricCard(
          icon:  Icons.verified_outlined,
          title: 'EPIC Verification',
          value: '${voters.verifiedVoters} / ${voters.totalVoters}',
          subtitle:
              '${voters.verificationRate.toStringAsFixed(1)}% verified',
          progressPct: voters.verificationRate / 100,
          color: AppColors.success,
        ),

        const SizedBox(height: AppDimensions.spaceMD),

        // ── Gender split ───────────────────────
        if (voters.byGender.isNotEmpty) ...[
          Text('Gender Split', style: AppTextStyles.heading3),
          const SizedBox(height: AppDimensions.spaceMD),
          _PieRow(
            data:   voters.byGender,
            colors: const {
              'male':   AppColors.primary,
              'female': AppColors.statusEscalatedText,
              'other':  AppColors.textSecondary,
            },
            labels: const {
              'male':   'Male',
              'female': 'Female',
              'other':  'Other',
            },
          ),
          const SizedBox(height: AppDimensions.spaceXL),
        ],

        // ── Religion ──────────────────────────
        if (voters.byReligion.isNotEmpty) ...[
          Text('Religion', style: AppTextStyles.heading3),
          const SizedBox(height: AppDimensions.spaceMD),
          _ReligionBars(byReligion: voters.byReligion),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progressPct,
    required this.color,
  });

  final IconData icon;
  final String   title;
  final String   value;
  final String   subtitle;
  final double   progressPct;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            width:  48,
            height: 48,
            decoration: BoxDecoration(
              color:        color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.caption),
                Text(value, style: AppTextStyles.heading3),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value:           progressPct.clamp(0.0, 1.0),
                  minHeight:       6,
                  backgroundColor: AppColors.primaryLight,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(color),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PieRow extends StatelessWidget {
  const _PieRow({
    required this.data,
    required this.colors,
    required this.labels,
  });
  final Map<String, int> data;
  final Map<String, Color>  colors;
  final Map<String, String> labels;

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    return Row(
      children: data.entries.map((e) {
        final pct    = e.value / total * 100;
        final color  = colors[e.key] ?? AppColors.textSecondary;
        final label  = labels[e.key] ?? e.key;
        return Expanded(
          flex: e.value > 0 ? e.value : 1,
          child: Column(
            children: [
              Container(
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color:        color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$label\n${pct.toStringAsFixed(0)}%',
                style: AppTextStyles.caption.copyWith(
                    color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ReligionBars extends StatelessWidget {
  const _ReligionBars({required this.byReligion});
  final Map<String, int> byReligion;

  @override
  Widget build(BuildContext context) {
    final total = byReligion.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final sorted = byReligion.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.take(6).map((e) {
        final pct = total > 0 ? e.value / total : 0.0;
        return Padding(
          padding: const EdgeInsets.only(
              bottom: AppDimensions.spaceMD),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  e.key.length > 10
                      ? e.key.substring(0, 10)
                      : e.key,
                  style: AppTextStyles.caption,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(100),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: pct.clamp(0.0, 1.0),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent,
                          borderRadius:
                              BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('${e.value}',
                  style: AppTextStyles.captionMedium),
            ],
          ),
        );
      }).toList(),
    );
  }
}