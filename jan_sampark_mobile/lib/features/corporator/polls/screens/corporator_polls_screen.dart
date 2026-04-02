import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/badges/status_badge.dart';
import '../../../voter/polls/providers/poll_provider.dart';
import '../../../voter/polls/models/poll_models.dart';

class CorporatorPollsScreen extends ConsumerStatefulWidget {
  const CorporatorPollsScreen({super.key});

  @override
  ConsumerState<CorporatorPollsScreen> createState() =>
      _CorporatorPollsScreenState();
}

class _CorporatorPollsScreenState
    extends ConsumerState<CorporatorPollsScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(pollListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pollListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor:        AppColors.appBarWhite,
        elevation:              0,
        scrolledUnderElevation: 0,
        title: Text('Polls', style: AppTextStyles.appBarTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.goNamed(RouteNames.createPoll),
        backgroundColor: AppColors.primary,
        icon:  const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Create Poll',
            style: AppTextStyles.buttonMedium),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, PollListState state) {
    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 140);
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(state.errorMessage,
                style:     AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () =>
                  ref.read(pollListProvider.notifier).load(),
              icon:  const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return EmptyStateWidget(
        icon:        Icons.poll_outlined,
        title:       'No Polls Yet',
        subtitle:    'Create a poll to gather voter opinions.',
        actionLabel: 'Create Poll',
        onAction:    () =>
            context.goNamed(RouteNames.createPoll),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(pollListProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH,
          AppDimensions.pagePaddingTop,
          AppDimensions.pagePaddingH,
          100,
        ),
        itemCount:
            state.polls.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceMD),
        itemBuilder: (context, i) {
          if (i == state.polls.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          final p = state.polls[i];
          return _CorporatorPollCard(poll: p);
        },
      ),
    );
  }
}

class _CorporatorPollCard extends StatelessWidget {
  const _CorporatorPollCard({required this.poll});
  final PollModel poll;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goNamed(
        RouteNames.corpPollResults,
        pathParameters: {'id': poll.id},
      ),
      child: Container(
        decoration: BoxDecoration(
          color:        AppColors.white,
          borderRadius: BorderRadius.circular(
              AppDimensions.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color:      AppColors.shadow,
              blurRadius: 4,
              offset:     const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(
              AppDimensions.cardPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poll type + status row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:        AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      poll.pollType.replaceAll('_', ' '),
                      style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary),
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(status: poll.status, small: true),
                ],
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Question
              Text(poll.question,
                  style: AppTextStyles.heading3),

              const SizedBox(height: AppDimensions.spaceSM),

              // Stats
              Row(
                children: [
                  const Icon(Icons.people_outline,
                      size: 13,
                      color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(
                    '${poll.totalResponses} response'
                    '${poll.totalResponses == 1 ? '' : 's'}',
                    style: AppTextStyles.caption,
                  ),
                  const Spacer(),
                  if (poll.closesAt != null)
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 13,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          'Closes ${DateFormatter.toDisplayDate(
                            DateFormatter.fromDateString(
                                poll.closesAt),
                          )}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // View results CTA
              Container(
                width:   double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    'View Results',
                    style: AppTextStyles.captionMedium.copyWith(
                        color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
