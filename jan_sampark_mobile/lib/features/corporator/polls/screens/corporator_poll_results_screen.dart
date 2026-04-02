import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../voter/polls/providers/poll_provider.dart';
import '../../../voter/polls/widgets/poll_results_chart.dart';

/// Corporator poll results — full analytics view.
class CorporatorPollResultsScreen extends ConsumerWidget {
  const CorporatorPollResultsScreen({
    super.key,
    required this.pollId,
  });
  final String pollId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollAsync    = ref.watch(pollDetailProvider(pollId));
    final resultsAsync = ref.watch(pollResultsProvider(pollId));

    return AppScaffold(
      title: 'Poll Results',
      body: resultsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
              color: AppColors.primary),
        ),
        error: (e, _) => EmptyStateWidget(
          icon:        Icons.error_outline_rounded,
          title:       'Failed to load results',
          subtitle:    e.toString(),
          actionLabel: 'Retry',
          onAction:    () =>
              ref.invalidate(pollResultsProvider(pollId)),
        ),
        data: (results) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(pollResultsProvider(pollId)),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(
                AppDimensions.pagePaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spaceMD),

                // Question
                pollAsync.maybeWhen(
                  data: (poll) => Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(poll.question,
                          style: AppTextStyles.heading2),
                      const SizedBox(
                          height: AppDimensions.spaceSM),
                      Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius:
                                  BorderRadius.circular(4),
                            ),
                            child: Text(
                              poll.pollType
                                  .replaceAll('_', ' '),
                              style: AppTextStyles.labelSmall
                                  .copyWith(
                                      color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (poll.isAnonymous)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceGrey,
                                borderRadius:
                                    BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.lock_outline_rounded,
                                    size:  12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('Anonymous',
                                      style: AppTextStyles
                                          .labelSmall),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),

                const SizedBox(height: AppDimensions.spaceXL),
                const Divider(height: 1),
                const SizedBox(height: AppDimensions.spaceXL),

                // Results chart
                PollResultsChart(results: results),

                const SizedBox(height: AppDimensions.spaceXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}