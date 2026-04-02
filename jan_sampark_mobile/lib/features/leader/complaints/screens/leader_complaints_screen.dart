import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/cards/complaint_card.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../providers/leader_complaint_provider.dart';
import '../widgets/complaint_filter_sheet.dart';

class LeaderComplaintsScreen extends ConsumerStatefulWidget {
  const LeaderComplaintsScreen({super.key});

  @override
  ConsumerState<LeaderComplaintsScreen> createState() =>
      _LeaderComplaintsScreenState();
}

class _LeaderComplaintsScreenState
    extends ConsumerState<LeaderComplaintsScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(leaderComplaintListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final state = ref.read(leaderComplaintListProvider);
    final result = await showComplaintFilterSheet(
      context: context,
      currentStatus: state.statusFilter,
      currentPriority: state.priorityFilter,
      currentEscalatedOnly: state.escalatedOnly,
    );
    if (result != null && mounted) {
      ref.read(leaderComplaintListProvider.notifier).applyFilters(
            statusFilter: result.status,
            priorityFilter: result.priority,
            escalatedOnly: result.escalatedOnly,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderComplaintListProvider);

    final hasFilters = state.statusFilter != null ||
        state.priorityFilter != null ||
        state.escalatedOnly;

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: AppColors.appBarWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Ward Complaints', style: AppTextStyles.appBarTitle),
        actions: [
          // Filter button with active indicator
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: _openFilters,
                tooltip: 'Filter',
              ),
              if (hasFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, LeaderComplaintListState state) {
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
              onPressed: () =>
                  ref.read(leaderComplaintListProvider.notifier).load(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.report_problem_outlined,
        title: 'No Complaints Found',
        subtitle: state.statusFilter != null ||
                state.priorityFilter != null ||
                state.escalatedOnly
            ? 'No complaints match the selected filters.'
            : 'There are no complaints in your ward yet.',
        actionLabel: state.statusFilter != null ||
                state.priorityFilter != null ||
                state.escalatedOnly
            ? 'Clear Filters'
            : null,
        onAction: () =>
            ref.read(leaderComplaintListProvider.notifier).clearFilters(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(leaderComplaintListProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical: AppDimensions.pagePaddingTop,
        ),
        itemCount: state.complaints.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceMD),
        itemBuilder: (context, i) {
          if (i == state.complaints.length) {
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
          final c = state.complaints[i];
          return ComplaintCard(
            complaintNumber: c.complaintNumber,
            title: c.title,
            categoryName: c.categoryName,
            status: c.status,
            priority: c.priority,
            wardName: c.wardName,
            areaName: c.areaName,
            assignedToName: c.assignedToName,
            isEscalated: c.isEscalated,
            showAssignee: true,
            createdAt: c.createdAt,
            onTap: () => context.goNamed(
              RouteNames.leaderComplaintDetail,
              pathParameters: {'id': c.id},
            ),
          );
        },
      ),
    );
  }
}
