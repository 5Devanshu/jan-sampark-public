import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/inputs/search_field.dart';
import '../../../../shared_widgets/badges/verification_badge.dart';
import '../providers/leader_voter_provider.dart';
import '../models/leader_voter_models.dart';

class LeaderVotersScreen extends ConsumerStatefulWidget {
  const LeaderVotersScreen({super.key});

  @override
  ConsumerState<LeaderVotersScreen> createState() => _LeaderVotersScreenState();
}

class _LeaderVotersScreenState extends ConsumerState<LeaderVotersScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(leaderVoterListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderVoterListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: AppColors.appBarWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Ward Voters', style: AppTextStyles.appBarTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePaddingH,
              0,
              AppDimensions.pagePaddingH,
              10,
            ),
            child: SearchField(
              controller: _searchCtrl,
              hint: 'Search by name or mobile',
              onChanged: (q) =>
                  ref.read(leaderVoterListProvider.notifier).search(q),
            ),
          ),
        ),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, VoterListState state) {
    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 80);
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
              onPressed: () =>
                  ref.read(leaderVoterListProvider.notifier).load(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'No Voters Found',
        subtitle: state.searchQuery.isNotEmpty
            ? 'No results for "${state.searchQuery}".'
            : 'Ward voters will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(leaderVoterListProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical: AppDimensions.pagePaddingTop,
        ),
        itemCount: state.voters.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceSM),
        itemBuilder: (context, i) {
          if (i == state.voters.length) {
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
          final v = state.voters[i];
          return _VoterTile(
            voter: v,
            onTap: () => context.goNamed(
              RouteNames.voterProfileView,
              pathParameters: {'id': v.id},
            ),
          );
        },
      ),
    );
  }
}

class _VoterTile extends StatelessWidget {
  const _VoterTile({required this.voter, required this.onTap});

  final VoterListItem voter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: voter.epicVerified
                    ? AppColors.primary
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  voter.initials,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: voter.epicVerified
                        ? AppColors.white
                        : AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ── Info ─────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          voter.fullName,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      VerificationBadge(
                        isVerified: voter.epicVerified,
                        small: true,
                        showLabel: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(voter.mobile, style: AppTextStyles.caption),
                      const SizedBox(width: 10),
                      if (voter.complaintsCount > 0) ...[
                        const Icon(
                          Icons.report_problem_outlined,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${voter.complaintsCount} complaint'
                          '${voter.complaintsCount == 1 ? '' : 's'}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
