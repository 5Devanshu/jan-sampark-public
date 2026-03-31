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
import '../providers/poll_provider.dart';
import '../models/poll_models.dart';

class PollsScreen extends ConsumerStatefulWidget {
  const PollsScreen({super.key});

  @override
  ConsumerState<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends ConsumerState<PollsScreen> {
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
        backgroundColor: AppColors.appBarWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Polls', style: AppTextStyles.appBarTitle),
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
            const Icon(
              Icons.wifi_off_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              state.errorMessage,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => ref.read(pollListProvider.notifier).load(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.poll_outlined,
        title: 'No Polls Available',
        subtitle:
            'Active polls from your representative '
            'will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(pollListProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical: AppDimensions.pagePaddingTop,
        ),
        itemCount: state.polls.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceMD),
        itemBuilder: (context, i) {
          if (i == state.polls.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          return _PollCard(poll: state.polls[i]);
        },
      ),
    );
  }
}

class _PollCard extends StatelessWidget {
  const _PollCard({required this.poll});
  final PollModel poll;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (poll.hasVoted && poll.showResults) {
          context.goNamed(
            RouteNames.voterPollResults,
            pathParameters: {'id': poll.id},
          );
        } else if (!poll.hasVoted && poll.isOpen) {
          context.goNamed(
            RouteNames.voterPollVote,
            pathParameters: {'id': poll.id},
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poll type chip
              Row(
                children: [
                  _TypeChip(pollType: poll.pollType),
                  const Spacer(),
                  if (poll.hasVoted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 12,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Voted',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (!poll.isOpen)
                    StatusBadge(status: 'closed', small: true),
                ],
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Question
              Text(poll.question, style: AppTextStyles.heading3),

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Footer
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 3),
                  Text(poll.createdByName, style: AppTextStyles.caption),
                  const Spacer(),
                  const Icon(
                    Icons.people_outline,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${poll.totalResponses} votes',
                    style: AppTextStyles.caption,
                  ),
                  if (poll.closesAt != null) ...[
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Ends ${DateFormatter.toDisplayDate(DateFormatter.fromDateString(poll.closesAt))}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // CTA
              if (!poll.hasVoted && poll.isOpen)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('Vote Now', style: AppTextStyles.buttonMedium),
                  ),
                )
              else if (poll.hasVoted && poll.showResults)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Center(
                    child: Text(
                      'View Results',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              else if (poll.isAnonymous)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text('Anonymous poll', style: AppTextStyles.caption),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.pollType});
  final String pollType;

  @override
  Widget build(BuildContext context) {
    final config = switch (pollType) {
      'multiple_choice' => (
        icon: Icons.check_box_outlined,
        label: 'Multiple Choice',
      ),
      'yes_no' => (icon: Icons.thumbs_up_down_outlined, label: 'Yes / No'),
      'rating' => (icon: Icons.star_outline_rounded, label: 'Rating'),
      'open_ended' => (icon: Icons.edit_outlined, label: 'Open Ended'),
      _ => (icon: Icons.poll_outlined, label: pollType),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
