import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared_widgets/inputs/search_field.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/badges/verification_badge.dart';
import '../providers/corporator_leader_provider.dart';
import '../models/corporator_leader_models.dart';

class CorporatorLeadersScreen extends ConsumerStatefulWidget {
  const CorporatorLeadersScreen({super.key});

  @override
  ConsumerState<CorporatorLeadersScreen> createState() =>
      _CorporatorLeadersScreenState();
}

class _CorporatorLeadersScreenState
    extends ConsumerState<CorporatorLeadersScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref
            .read(corporatorLeaderListProvider.notifier)
            .loadMore();
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
    final state = ref.watch(corporatorLeaderListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor:        AppColors.appBarWhite,
        elevation:              0,
        scrolledUnderElevation: 0,
        title: Text('Leaders', style: AppTextStyles.appBarTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePaddingH, 0,
              AppDimensions.pagePaddingH, 10,
            ),
            child: SearchField(
              controller: _searchCtrl,
              hint:       'Search by name or mobile',
              onChanged:  (q) => ref
                  .read(corporatorLeaderListProvider.notifier)
                  .search(q),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.goNamed(RouteNames.createLeader),
        backgroundColor: AppColors.primary,
        icon:  const Icon(Icons.person_add_outlined,
            color: Colors.white),
        label: Text('Add Leader',
            style: AppTextStyles.buttonMedium),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(
      BuildContext context, CorporatorLeaderListState state) {
    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 88);
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
                  ref.read(corporatorLeaderListProvider.notifier)
                      .load(),
              icon:  const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return EmptyStateWidget(
        icon:        Icons.people_outline,
        title:       'No Leaders Found',
        subtitle:    state.searchQuery.isNotEmpty
            ? 'No results for "${state.searchQuery}".'
            : 'Add the first leader for your area.',
        actionLabel: 'Add Leader',
        onAction:    () =>
            context.goNamed(RouteNames.createLeader),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(corporatorLeaderListProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH,
          AppDimensions.pagePaddingTop,
          AppDimensions.pagePaddingH,
          100, // FAB clearance
        ),
        itemCount: state.leaders.length +
            (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceSM),
        itemBuilder: (context, i) {
          if (i == state.leaders.length) {
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
          final l = state.leaders[i];
          return _LeaderTile(
            leader: l,
            onTap:  () => context.goNamed(
              RouteNames.leaderDetail,
              pathParameters: {'id': l.id},
            ),
          );
        },
      ),
    );
  }
}

class _LeaderTile extends StatelessWidget {
  const _LeaderTile({
    required this.leader,
    required this.onTap,
  });

  final CorporatorLeaderItem leader;
  final VoidCallback         onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
        decoration: BoxDecoration(
          color:        AppColors.white,
          borderRadius: BorderRadius.circular(
              AppDimensions.cardRadius),
          border: Border.all(
            color: leader.isActive
                ? AppColors.borderGrey
                : AppColors.errorLight,
          ),
          boxShadow: [
            BoxShadow(
              color:      AppColors.shadow,
              blurRadius: 3,
              offset:     const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar ──────────────────────────
            Container(
              width:  48,
              height: 48,
              decoration: BoxDecoration(
                color: leader.isActive
                    ? AppColors.primary
                    : AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  leader.initials,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: leader.isActive
                        ? AppColors.white
                        : AppColors.textSecondary,
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
                          leader.fullName,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!leader.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:        AppColors.errorLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Inactive',
                              style: AppTextStyles.labelSmall
                                  .copyWith(
                                      color: AppColors.error)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.map_outlined,
                          size: 12,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(leader.wardName,
                          style: AppTextStyles.caption),
                      const SizedBox(width: 10),
                      const Icon(Icons.thumb_up_outlined,
                          size: 12,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        '${leader.complaintsAcknowledged} acknowledged',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
