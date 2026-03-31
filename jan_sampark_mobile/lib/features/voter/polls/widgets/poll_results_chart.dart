import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/poll_models.dart';

/// Adaptive results chart — renders differently for each poll type.
class PollResultsChart extends StatelessWidget {
  const PollResultsChart({super.key, required this.results});
  final PollResults results;

  @override
  Widget build(BuildContext context) {
    return switch (results.pollType) {
      'multiple_choice' || 'yes_no' => _BarResults(results: results),
      'rating' => _RatingResults(results: results),
      'open_ended' => _OpenResults(results: results),
      _ => const SizedBox.shrink(),
    };
  }
}

// ─── Bar chart for multiple choice / yes_no ──

class _BarResults extends StatelessWidget {
  const _BarResults({required this.results});
  final PollResults results;

  @override
  Widget build(BuildContext context) {
    if (results.optionResults.isEmpty) {
      return Center(
        child: Text('No votes yet.', style: AppTextStyles.bodySecondary),
      );
    }

    return Column(
      children: [
        // Total responses
        _TotalBadge(total: results.totalResponses),
        const SizedBox(height: AppDimensions.spaceXL),

        ...results.optionResults.map((opt) {
          final pct = (opt.percentage / 100).clamp(0.0, 1.0);
          final isWinner =
              opt ==
              results.optionResults.reduce(
                (a, b) => a.voteCount >= b.voteCount ? a : b,
              );
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        opt.optionText,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    if (isWinner && opt.voteCount > 0)
                      const Icon(
                        Icons.emoji_events_outlined,
                        size: 16,
                        color: Color(0xFFFACC15),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      '${opt.percentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: pct,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: isWinner && opt.voteCount > 0
                              ? AppColors.primary
                              : AppColors.primaryAccent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${opt.voteCount} vote'
                  '${opt.voteCount == 1 ? '' : 's'}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─── Star average for rating polls ──────────

class _RatingResults extends StatelessWidget {
  const _RatingResults({required this.results});
  final PollResults results;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TotalBadge(total: results.totalResponses),
        const SizedBox(height: AppDimensions.spaceXL),

        // Average
        if (results.averageRating != null) ...[
          Text(
            results.averageRating!.toStringAsFixed(1),
            style: AppTextStyles.metricLarge.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = results.averageRating! >= (i + 1);
              return Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                color: filled ? const Color(0xFFFACC15) : AppColors.borderGrey,
                size: 28,
              );
            }),
          ),
          const SizedBox(height: 4),
          Text('Average rating', style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppDimensions.spaceXL),
        ],

        // Distribution bars
        ...results.ratingDistribution.entries.toList().reversed.map((entry) {
          final star = int.tryParse(entry.key) ?? 0;
          final count = entry.value;
          final pct = results.totalResponses > 0
              ? count / results.totalResponses
              : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text('$star ★', style: AppTextStyles.captionMedium),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: pct,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFACC15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('$count', style: AppTextStyles.caption),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─── Text list for open ended polls ─────────

class _OpenResults extends StatelessWidget {
  const _OpenResults({required this.results});
  final PollResults results;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TotalBadge(total: results.totalResponses),
        const SizedBox(height: AppDimensions.spaceXL),
        Text('Recent Responses', style: AppTextStyles.heading3),
        const SizedBox(height: AppDimensions.spaceMD),
        if (results.openResponses.isEmpty)
          Text('No responses yet.', style: AppTextStyles.bodySecondary)
        else
          ...results.openResponses.map(
            (response) => Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
              padding: const EdgeInsets.all(AppDimensions.spaceMD),
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(response, style: AppTextStyles.body)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Total response badge ────────────────────

class _TotalBadge extends StatelessWidget {
  const _TotalBadge({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              '$total response${total == 1 ? '' : 's'}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
