import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/layout/section_header.dart';
import '../providers/corporator_dashboard_provider.dart';
import '../widgets/area_stats_card.dart';
import '../widgets/analytics_chart_row.dart';
import '../widgets/demographic_breakdown.dart';
import '../widgets/corporator_quick_actions.dart';

class CorporatorHomeScreen extends ConsumerWidget {
  const CorporatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final dashState   = ref.watch(corporatorDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor:        AppColors.appBarWhite,
        elevation:              0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:       MainAxisSize.min,
          children: [
            Text('Welcome back,', style: AppTextStyles.caption),
            Text(
              currentUser?.fullName ?? 'Corporator',
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        actions: [
          // Period selector
          _PeriodSelector(
            selected: dashState.selectedPeriod,
            onChanged: (p) => ref
                .read(corporatorDashboardProvider.notifier)
                .setPeriod(p),
          ),
          IconButton(
            icon:     const Icon(Icons.notifications_outlined),
            onPressed: () =>
                context.goNamed(RouteNames.notifications),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(corporatorDashboardProvider.notifier)
                .load(),
        color: AppColors.primary,
        child: _buildBody(context, dashState),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, CorporatorDashboardState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
            color: AppColors.primary),
      );
    }

    if (state.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(state.errorMessage,
                  style:     AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final dashboard = state.dashboard;
    if (dashboard == null) {
      return const Center(
        child: CircularProgressIndicator(
            color: AppColors.primary),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical:   AppDimensions.pagePaddingTop,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero stats ────────────────────────
          AreaStatsCard(dashboard: dashboard),

          const SizedBox(height: AppDimensions.spaceXL),

          // ── Quick actions grid ────────────────
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: AppDimensions.spaceMD),
          const CorporatorQuickActions(),

          const SizedBox(height: AppDimensions.spaceXL),

          // ── Complaint analytics ───────────────
          const SectionHeader(title: 'Complaint Analytics'),
          const SizedBox(height: AppDimensions.spaceMD),
          Container(
            padding: const EdgeInsets.all(
                AppDimensions.cardPaddingH),
            decoration: BoxDecoration(
              color:        AppColors.white,
              borderRadius: BorderRadius.circular(
                  AppDimensions.cardRadius),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: AnalyticsChartRow(
                complaints: dashboard.complaints),
          ),

          const SizedBox(height: AppDimensions.spaceXL),

          // ── Voter demographics ────────────────
          const SectionHeader(title: 'Voter Demographics'),
          const SizedBox(height: AppDimensions.spaceMD),
          DemographicBreakdown(voters: dashboard.voters),

          // ── Leader performance ────────────────
          if (dashboard.leaders.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spaceXL),
            const SectionHeader(title: 'Leader Performance'),
            const SizedBox(height: AppDimensions.spaceMD),
            ...dashboard.leaders.map(
              (l) => _LeaderRow(leader: l),
            ),
          ],

          const SizedBox(height: AppDimensions.spaceXXL),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Period Selector
// ─────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final void Function(String) onChanged;

  static const _options = {
    '7d':  '7D',
    '30d': '30D',
    '90d': '90D',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color:        AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _options.entries.map((e) {
          final isActive = selected == e.key;
          return GestureDetector(
            onTap: () => onChanged(e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                e.value,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isActive
                      ? AppColors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Leader Performance Row
// ─────────────────────────────────────────────

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.leader});
  final LeaderSummary leader;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          bottom: AppDimensions.spaceMD),
      padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            width:  40,
            height: 40,
            decoration: BoxDecoration(
              color:        AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_outline,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(leader.leaderName,
                    style: AppTextStyles.bodyMedium),
                Text(leader.wardName,
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${leader.complaintsResolved} / '
                '${leader.complaintsAssigned}',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary),
              ),
              Text(
                '${leader.resolutionRate.toStringAsFixed(0)}% resolved',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import '../models/corporator_models.dart';
