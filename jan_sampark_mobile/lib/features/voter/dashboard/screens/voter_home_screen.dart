// lib/features/voter/dashboard/screens/voter_home_screen.dart
//
// Voter Dashboard — home tab of the VoterShell.
// Replaces the stub installed in Module 4.
//
// Sections (top → bottom):
//   1. Blue gradient Greeting Banner (SliverAppBar-style header)
//   2. EPIC verification banner (if not verified)
//   3. My Complaints summary card
//   4. Quick Actions 4×2 grid
//   5. Announcements horizontal scroll
//   6. Upcoming Events vertical list
//   7. Active Campaigns horizontal scroll
//   8. Community Leaderboard card
//
// Data flow:
//   voterDashboardProvider (AsyncNotifier) → parallel fetch → VoterDashboardData
//   Pull-to-refresh triggers notifier.refresh()
//
// Dependencies added to app_router.dart (Module 4):
//   Replaced stub VoterHomeScreen with this file — no router change needed.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../models/voter_dashboard_models.dart';
import '../providers/voter_dashboard_provider.dart';
import '../widgets/greeting_banner.dart';
import '../widgets/epic_verification_banner.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/dashboard_section_header.dart';
import '../widgets/my_complaints_summary_card.dart';
import '../widgets/announcement_feed_card.dart';
import '../widgets/upcoming_event_card.dart';
import '../widgets/active_campaign_card.dart';
import '../widgets/leaderboard_preview_card.dart';

class VoterHomeScreen extends ConsumerStatefulWidget {
  const VoterHomeScreen({super.key});

  @override
  ConsumerState<VoterHomeScreen> createState() => _VoterHomeScreenState();
}

class _VoterHomeScreenState extends ConsumerState<VoterHomeScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Pull-to-refresh ──────────────────────────

  Future<void> _onRefresh() async {
    await ref.read(voterDashboardProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    // Force dark status bar icons (white bg scroll area)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light, // over blue header
    ));

    final asyncData = ref.watch(voterDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      body: asyncData.when(
        loading: () => _LoadingSkeleton(),
        error:   (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(voterDashboardProvider),
        ),
        data:    (data) => _DashboardBody(
          data:             data,
          onRefresh:        _onRefresh,
          scrollController: _scrollController,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Dashboard Body — fully populated
// ─────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.data,
    required this.onRefresh,
    required this.scrollController,
  });

  final VoterDashboardData       data;
  final Future<void> Function()  onRefresh;
  final ScrollController         scrollController;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh:   onRefresh,
      color:       AppColors.primary,
      strokeWidth: 2.5,
      child: CustomScrollView(
        controller: scrollController,
        physics:    const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ── Sticky App Bar ─────────────────────
          _VoterSliverAppBar(profile: data.profile),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting banner (below the sliver app bar) ─
                GreetingBanner(profile: data.profile),

                // ── EPIC verification nudge ─────────
                if (!data.profile.epicVerified)
                  EpicVerificationBanner(ocrStatus: data.profile.ocrStatus),

                const SizedBox(height: AppDimensions.spaceXL),

                // ── Quick Actions ───────────────────
                _Section(
                  header: const DashboardSectionHeader(
                    title: 'Quick Actions',
                  ),
                  child: const QuickActionsGrid(),
                ),

                const SizedBox(height: AppDimensions.spaceXL),

                // ── My Complaints ───────────────────
                _Section(
                  header: DashboardSectionHeader(
                    title:      'My Complaints',
                    subtitle:   'Track the status of issues you raised',
                    onSeeAll:   () => context.pushNamed(
                      RouteNames.voterComplaints,
                    ),
                  ),
                  child: MyComplaintsSummaryCard(
                    summary: data.complaintSummary,
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceXL),

                // ── Announcements ───────────────────
                if (data.announcements.isNotEmpty) ...[
                  _Section(
                    header: DashboardSectionHeader(
                      title:    'Announcements',
                      subtitle: 'Latest from your ward & area',
                      onSeeAll: () => context.pushNamed(
                        RouteNames.voterAnnouncements,
                      ),
                    ),
                    child: _AnnouncementsRow(
                      items: data.announcements,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXL),
                ],

                // ── Upcoming Events ─────────────────
                if (data.upcomingEvents.isNotEmpty) ...[
                  _Section(
                    header: DashboardSectionHeader(
                      title:    'Upcoming Events',
                      subtitle: 'Don\'t miss events near you',
                      onSeeAll: () => context.pushNamed(
                        RouteNames.voterEvents,
                      ),
                    ),
                    child: _EventsList(events: data.upcomingEvents),
                  ),
                  const SizedBox(height: AppDimensions.spaceXL),
                ],

                // ── Active Campaigns ────────────────
                if (data.activeCampaigns.isNotEmpty) ...[
                  _Section(
                    header: DashboardSectionHeader(
                      title:    'Active Campaigns',
                      subtitle: 'Support initiatives in your constituency',
                      onSeeAll: () => context.pushNamed(
                        RouteNames.voterCampaigns,
                      ),
                    ),
                    child: _CampaignsRow(
                      campaigns: data.activeCampaigns,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXL),
                ],

                // ── Community Leaderboard ───────────
                if (data.leaderboard.isNotEmpty) ...[
                  DashboardSectionHeader(
                    title:    'Community Leaders',
                    subtitle: 'Top performers this month',
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  LeaderboardPreviewCard(entries: data.leaderboard),
                  const SizedBox(height: AppDimensions.spaceXL),
                ],

                // ── Bottom padding for nav bar ──────
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sliver App Bar — transparent, overlays the greeting
// ─────────────────────────────────────────────

class _VoterSliverAppBar extends StatelessWidget {
  const _VoterSliverAppBar({required this.profile});
  final VoterProfileSummary profile;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned:          true,
      floating:        false,
      expandedHeight:  0,
      backgroundColor: AppColors.primaryDark,
      elevation:       0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor:          Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      title: Text(
        'Jan Sampark',
        style: AppTextStyles.appBarTitle.copyWith(
          color: AppColors.textOnPrimary,
        ),
      ),
      actions: [
        // ── Search ────────────────────────────────
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textOnPrimary),
          onPressed: () {},
          tooltip: 'Search',
        ),
        // ── Notifications ─────────────────────────
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_outlined,
                color: AppColors.textOnPrimary,
              ),
              onPressed: () => context.pushNamed(RouteNames.notifications),
              tooltip: 'Notifications',
            ),
            // Unread dot — static placeholder (Module 20 wires live count)
            Positioned(
              right: 10,
              top:   10,
              child: Container(
                width:  8,
                height: 8,
                decoration: const BoxDecoration(
                  color:  AppColors.error,
                  shape:  BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Horizontal row helpers
// ─────────────────────────────────────────────

class _AnnouncementsRow extends StatelessWidget {
  const _AnnouncementsRow({required this.items});
  final List<DashboardAnnouncement> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection:    Axis.horizontal,
        padding:            EdgeInsets.zero,
        itemCount:          items.length,
        itemBuilder: (_, i) => AnnouncementFeedCard(item: items[i], index: i),
      ),
    );
  }
}

class _CampaignsRow extends StatelessWidget {
  const _CampaignsRow({required this.campaigns});
  final List<DashboardCampaign> campaigns;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection:    Axis.horizontal,
        padding:            EdgeInsets.zero,
        itemCount:          campaigns.length,
        itemBuilder: (_, i) =>
            ActiveCampaignCard(campaign: campaigns[i], index: i),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Events vertical list
// ─────────────────────────────────────────────

class _EventsList extends StatelessWidget {
  const _EventsList({required this.events});
  final List<DashboardEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: events
          .map((e) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.spaceMD,
                ),
                child: UpcomingEventCard(event: e),
              ))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Section wrapper — header + consistent spacing
// ─────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.header, required this.child});
  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: AppDimensions.spaceMD),
        child,
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Loading skeleton — shimmer placeholders
// ─────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:      AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting banner skeleton
            Container(
              height:     200,
              color:      AppColors.white,
              margin:     EdgeInsets.zero,
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePaddingH,
              ),
              child: Column(
                children: [
                  // Quick actions skeleton
                  _ShimmerBox(height: 130, width: double.infinity, radius: 12),
                  const SizedBox(height: 24),

                  // Complaints card skeleton
                  _ShimmerBox(height: 110, width: double.infinity, radius: 12),
                  const SizedBox(height: 24),

                  // Section header skeleton
                  Row(
                    children: [
                      _ShimmerBox(height: 16, width: 130, radius: 8),
                      const Spacer(),
                      _ShimmerBox(height: 14, width: 55, radius: 8),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Horizontal cards skeleton
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection:    Axis.horizontal,
                padding:            const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pagePaddingH,
                ),
                itemCount:          3,
                separatorBuilder:   (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) =>
                    _ShimmerBox(height: 150, width: 260, radius: 12),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePaddingH,
              ),
              child: Column(
                children: [
                  _ShimmerBox(height: 80, width: double.infinity, radius: 12),
                  const SizedBox(height: 12),
                  _ShimmerBox(height: 80, width: double.infinity, radius: 12),
                  const SizedBox(height: 12),
                  _ShimmerBox(height: 80, width: double.infinity, radius: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.height,
    required this.width,
    required this.radius,
  });
  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height:      height,
      width:       width,
      decoration:  BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String      message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width:  80,
              height: 80,
              decoration: BoxDecoration(
                color:        AppColors.errorLight,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.error,
                size:  36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Could not load dashboard',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed:  onRetry,
              icon:       const Icon(Icons.refresh),
              label:      const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize:     const Size(140, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}