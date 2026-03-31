import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/cards/campaign_card.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../providers/campaign_provider.dart';

/// Voter campaigns screen — shows all active campaigns.
///
/// Two tabs:
///   Active Campaigns — browse and donate
///   My Donations     — own donation history
class CampaignsScreen extends ConsumerStatefulWidget {
  const CampaignsScreen({super.key});

  @override
  ConsumerState<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends ConsumerState<CampaignsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _campaignScrollCtrl  = ScrollController();
  final _donationScrollCtrl  = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);

    // Infinite scroll for campaigns
    _campaignScrollCtrl.addListener(() {
      if (_campaignScrollCtrl.position.pixels >=
          _campaignScrollCtrl.position.maxScrollExtent - 200) {
        ref.read(campaignListProvider.notifier).loadMore();
      }
    });

    // Infinite scroll for donations
    _donationScrollCtrl.addListener(() {
      if (_donationScrollCtrl.position.pixels >=
          _donationScrollCtrl.position.maxScrollExtent - 200) {
        ref.read(myDonationsProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _campaignScrollCtrl.dispose();
    _donationScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor:       AppColors.appBarWhite,
        elevation:             0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Campaigns', style: AppTextStyles.appBarTitle),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Active Campaigns'),
            Tab(text: 'My Donations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _CampaignListTab(scrollCtrl: _campaignScrollCtrl),
          _MyDonationsTab(scrollCtrl: _donationScrollCtrl),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Campaign List Tab
// ─────────────────────────────────────────────

class _CampaignListTab extends ConsumerWidget {
  const _CampaignListTab({required this.scrollCtrl});
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(campaignListProvider);

    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 180);
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () =>
                  ref.read(campaignListProvider.notifier).load(),
              icon:  const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.campaigns.isEmpty) {
      return EmptyStateWidget(
        icon:     Icons.campaign_outlined,
        title:    'No Active Campaigns',
        subtitle: 'There are no campaigns running in your area right now.',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(campaignListProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: scrollCtrl,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical:   AppDimensions.pagePaddingTop,
        ),
        itemCount: state.campaigns.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceMD),
        itemBuilder: (context, i) {
          if (i == state.campaigns.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          final campaign = state.campaigns[i];
          return CampaignCard(
            title:           campaign.title,
            description:     campaign.description,
            targetAmount:    campaign.targetAmount,
            amountCollected: campaign.amountCollected,
            progressPct:     campaign.progressPct,
            donationCount:   campaign.donationCount,
            status:          campaign.status,
            endDate:         campaign.endDate,
            coverImageUrl:   campaign.coverImageUrl,
            onTap: () => context.goNamed(
              RouteNames.campaignDetail,
              pathParameters: {'id': campaign.id},
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// My Donations Tab
// ─────────────────────────────────────────────

class _MyDonationsTab extends ConsumerWidget {
  const _MyDonationsTab({required this.scrollCtrl});
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myDonationsProvider);

    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 140);
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () =>
                  ref.read(myDonationsProvider.notifier).load(),
              icon:  const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.donations.isEmpty) {
      return EmptyStateWidget(
        icon:     Icons.volunteer_activism_outlined,
        title:    'No Donations Yet',
        subtitle: 'Your donation history will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(myDonationsProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: scrollCtrl,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical:   AppDimensions.pagePaddingTop,
        ),
        itemCount:
            state.donations.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceMD),
        itemBuilder: (context, i) {
          if (i == state.donations.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          final donation = state.donations[i];
          return DonationStatusCard(
            donation: donation,
            onTap: () => context.goNamed(
              RouteNames.donationStatus,
              pathParameters: {'id': donation.id},
            ),
          );
        },
      ),
    );
  }
}

// Imports
import '../widgets/donation_status_card.dart';