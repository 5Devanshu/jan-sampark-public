import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../models/poll_models.dart';
import '../providers/poll_provider.dart';
import '../widgets/multiple_choice_poll.dart';
import '../widgets/yes_no_poll.dart';
import '../widgets/rating_poll.dart';
import '../widgets/open_ended_poll.dart';

class PollVoteScreen extends ConsumerStatefulWidget {
  const PollVoteScreen({super.key, required this.pollId});
  final String pollId;

  @override
  ConsumerState<PollVoteScreen> createState() => _PollVoteScreenState();
}

class _PollVoteScreenState extends ConsumerState<PollVoteScreen> {
  String? _selectedOptionId;
  int? _selectedRating;
  String _openResponse = '';

  VoteRequest? get _buildRequest {
    final poll = ref.read(pollDetailProvider(widget.pollId)).valueOrNull;
    if (poll == null) return null;

    if (poll.isMultipleChoice || poll.isYesNo) {
      if (_selectedOptionId == null) return null;
      return VoteRequest(optionId: _selectedOptionId);
    }
    if (poll.isRating) {
      if (_selectedRating == null) return null;
      return VoteRequest(rating: _selectedRating);
    }
    if (poll.isOpenEnded) {
      if (_openResponse.trim().isEmpty) return null;
      return VoteRequest(openResponse: _openResponse.trim());
    }
    return null;
  }

  bool get _canSubmit => _buildRequest != null;

  Future<void> _onSubmit(PollModel poll) async {
    final request = _buildRequest;
    if (request == null) {
      context.showError('Please make a selection before voting.');
      return;
    }

    final success = await ref
        .read(voteProvider.notifier)
        .vote(pollId: poll.id, request: request);

    if (!mounted) return;

    if (success) {
      ref.read(pollListProvider.notifier).markVoted(poll.id);
      context.showSuccess('Vote submitted!');

      // Navigate to results if show_results=true
      if (poll.showResults) {
        context.goNamed(
          RouteNames.voterPollResults,
          pathParameters: {'id': poll.id},
        );
      } else {
        context.pop();
      }
    } else {
      final error = ref.read(voteProvider).errorMessage;
      if (error.isNotEmpty) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(pollDetailProvider(widget.pollId));
    final voteState = ref.watch(voteProvider);

    return async.when(
      loading: () => const AppScaffold(
        title: 'Poll',
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => AppScaffold(
        title: 'Poll',
        body: EmptyStateWidget(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load poll',
          subtitle: e.toString(),
        ),
      ),
      data: (poll) => AppScaffold(
        title: 'Vote',
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.spaceMD),

                    // Anonymous notice
                    if (poll.isAnonymous)
                      Container(
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
                              'Anonymous — your identity '
                              'will not be stored.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Question
                    Text(poll.question, style: AppTextStyles.heading2),
                    const SizedBox(height: AppDimensions.spaceXXL),

                    // Poll input — adaptive
                    if (poll.isMultipleChoice)
                      MultipleChoicePoll(
                        options: poll.options,
                        selectedOptionId: _selectedOptionId,
                        isEnabled: !voteState.isLoading,
                        onSelected: (id) =>
                            setState(() => _selectedOptionId = id),
                      )
                    else if (poll.isYesNo)
                      YesNoPoll(
                        selectedOptionId: _selectedOptionId,
                        isEnabled: !voteState.isLoading,
                        onSelected: (id) =>
                            setState(() => _selectedOptionId = id),
                      )
                    else if (poll.isRating)
                      RatingPoll(
                        selectedRating: _selectedRating,
                        isEnabled: !voteState.isLoading,
                        onSelected: (r) => setState(() => _selectedRating = r),
                      )
                    else if (poll.isOpenEnded)
                      OpenEndedPoll(
                        isEnabled: !voteState.isLoading,
                        onChanged: (t) => setState(() => _openResponse = t),
                      ),

                    const SizedBox(height: AppDimensions.spaceXXL),
                  ],
                ),
              ),
            ),

            // Submit
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.pagePaddingH,
                AppDimensions.spaceMD,
                AppDimensions.pagePaddingH,
                AppDimensions.spaceMD + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.borderGrey)),
              ),
              child: PrimaryButton(
                label: 'Submit Vote',
                icon: Icons.how_to_vote_outlined,
                isLoading: voteState.isLoading,
                isDisabled: !_canSubmit,
                onPressed: () => _onSubmit(poll),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
