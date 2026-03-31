import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../providers/poll_provider.dart';
import '../widgets/poll_results_chart.dart';

class PollResultsScreen extends ConsumerWidget {
  const PollResultsScreen({super.key, required this.pollId});
  final String pollId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollAsync = ref.watch(pollDetailProvider(pollId));
    final resultsAsync = ref.watch(pollResultsProvider(pollId));

    return AppScaffold(
      title: 'Poll Results',
      body: resultsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => EmptyStateWidget(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load results',
          subtitle: e.toString(),
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(pollResultsProvider(pollId)),
        ),
        data: (results) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spaceMD),

              // Question
              pollAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (poll) =>
                    Text(poll.question, style: AppTextStyles.heading2),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Anonymous notice
              pollAsync.maybeWhen(
                data: (poll) => poll.isAnonymous
                    ? Container(
                        margin: const EdgeInsets.only(
                          bottom: AppDimensions.spaceMD,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Anonymous poll — '
                              'results are aggregated only.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              ),

              const Divider(height: 1),
              const SizedBox(height: AppDimensions.spaceXL),

              // Results chart — adaptive
              PollResultsChart(results: results),

              const SizedBox(height: AppDimensions.spaceXXL),
            ],
          ),
        ),
      ),
    );
  }
}
