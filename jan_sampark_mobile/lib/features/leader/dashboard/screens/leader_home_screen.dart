import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/layout/section_header.dart';
import '../providers/leader_dashboard_provider.dart';
import '../widgets/leader_summary_row.dart';
import '../widgets/assigned_complaints_preview.dart';
import '../models/leader_models.dart';

class LeaderHomeScreen extends ConsumerWidget {
  const LeaderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser  = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(leaderProfileProvider);
    final dashState    = ref.watch(leaderDashboardProvider);

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
            Text('Good morning,',
                style: AppTextStyles.caption),
            Text(
              currentUser?.fullName ?? 'Leader',
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        actions: [
          // Notifications bell
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                context.goNamed(RouteNames.notifications),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(leaderProfileProvider);
          await ref
              .read(leaderDashboardProvider.notifier)
              .load();
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical:   AppDimensions.pagePaddingTop,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Location banner ─────────────────
              profileAsync.when(
                loading: () => const _LocationSkeleton(),
                error:   (_, __) => const SizedBox.shrink(),
                data: (profile) => _LocationBanner(
                  wardName: profile.location.wardName,
                  areaName: profile.location.areaName,
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // ── Summary card ────────────────────
              profileAsync.when(
                loading: () => const _SummarySkeleton(),
                error:   (_, __) => const SizedBox.shrink(),
                data: (profile) => dashState.isLoading
                    ? const _SummarySkeleton()
                    : LeaderSummaryRow(
                        performance: profile.performance,
                        summary: dashState.summary ??
                            const WardComplaintSummary(),
                      ),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // ── Quick actions ───────────────────
              _QuickActions(profile: profileAsync.valueOrNull),

              const SizedBox(height: AppDimensions.spaceXL),

              // ── Complaints preview ──────────────
              const AssignedComplaintsPreview(),

              const SizedBox(height: AppDimensions.spaceXXL),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Location Banner
// ─────────────────────────────────────────────

class _LocationBanner extends StatelessWidget {
  const _LocationBanner({this.wardName, this.areaName});
  final String? wardName;
  final String? areaName;

  @override
  Widget build(BuildContext context) {
    final location = [wardName, areaName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:        AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              location.isNotEmpty
                  ? 'Assigned ward: $location'
                  : 'No ward assigned',
              style: AppTextStyles.captionMedium.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quick Actions
// ─────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({this.profile});
  final LeaderProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: AppDimensions.spaceMD),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon:    Icons.report_problem_outlined,
                label:   'Complaints',
                color:   AppColors.primary,
                onTap:   () =>
                    context.goNamed(RouteNames.leaderComplaints),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: _ActionCard(
                icon:    Icons.people_outline,
                label:   'Ward Voters',
                color:   AppColors.primaryAccent,
                onTap:   () =>
                    context.goNamed(RouteNames.leaderVoters),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: _ActionCard(
                icon:    Icons.event_outlined,
                label:   'Events',
                color:   AppColors.success,
                onTap:   () =>
                    context.goNamed(RouteNames.leaderEvents),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: _ActionCard(
                icon:    Icons.forum_outlined,
                label:   'Chats',
                color:   const Color(0xFF7C3AED),
                onTap:   () =>
                    context.goNamed(RouteNames.leaderChats),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:        AppColors.white,
          borderRadius: BorderRadius.circular(
              AppDimensions.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width:  40,
              height: 40,
              decoration: BoxDecoration(
                color:        color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.labelSmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Skeleton placeholders
// ─────────────────────────────────────────────

class _LocationSkeleton extends StatelessWidget {
  const _LocationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color:        AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color:        AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius),
      ),
    );
  }
}

