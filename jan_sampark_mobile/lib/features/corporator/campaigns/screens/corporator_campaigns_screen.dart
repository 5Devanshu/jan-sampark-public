import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/cards/campaign_card.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../providers/corporator_campaign_provider.dart';
import '../../../voter/campaigns/models/campaign_models.dart';
import '../../../voter/campaigns/providers/campaign_provider.dart';

/// Corporator campaign list with Create FAB and
/// "Pending Donations" badge.
class CorporatorCampaignsScreen extends ConsumerStatefulWidget {
  const CorporatorCampaignsScreen({super.key});

  @override
  ConsumerState<CorporatorCampaignsScreen> createState() =>
      _CorporatorCampaignsScreenState();
}

class _CorporatorCampaignsScreenState
    extends ConsumerState<CorporatorCampaignsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(campaignListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campaignState   = ref.watch(campaignListProvider);
    final pendingAsync    = ref.watch(allPendingDonationsProvider);

    final pendingCount = pendingAsync.maybeWhen(
      data: (d) => d.total,
      orElse: () => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor:        AppColors.appBarWhite,
        elevation:              0,
        scrolledUnderElevation: 0,
        title: Text('Campaigns',
            style: AppTextStyles.appBarTitle),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            const Tab(text: 'All Campaigns'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pending Donations'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:        AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$pendingCount',
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.goNamed(RouteNames.createCampaign),
        backgroundColor: AppColors.primary,
        icon:  const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Create Campaign',
            style: AppTextStyles.buttonMedium),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // ── Campaign List ─────────────────────
          _CampaignListTab(
              state: campaignState, scrollCtrl: _scrollCtrl),

          // ── Pending Donations ─────────────────
          _PendingDonationsTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Campaign List Tab
// ─────────────────────────────────────────────

class _CampaignListTab extends ConsumerWidget {
  const _CampaignListTab({
    required this.state,
    required this.scrollCtrl,
  });

  final CampaignListState state;
  final ScrollController  scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 180);
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
        icon:        Icons.campaign_outlined,
        title:       'No Campaigns Yet',
        subtitle:    'Create the first fundraising campaign for your area.',
        actionLabel: 'Create Campaign',
        onAction: () => context.goNamed(
            RouteNames.createCampaign),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(campaignListProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH,
          AppDimensions.pagePaddingTop,
          AppDimensions.pagePaddingH,
          100,
        ),
        itemCount: state.campaigns.length +
            (state.isLoadingMore ? 1 : 0),
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
                    strokeWidth: 2, color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          final c = state.campaigns[i];
          return CampaignCard(
            title:           c.title,
            description:     c.description,
            targetAmount:    c.targetAmount,
            amountCollected: c.amountCollected,
            progressPct:     c.progressPct,
            donationCount:   c.donationCount,
            status:          c.status,
            endDate:         c.endDate,
            coverImageUrl:   c.coverImageUrl,
            onTap: () => context.goNamed(
              RouteNames.corpCampaignDetail,
              pathParameters: {'id': c.id},
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Pending Donations Tab
// ─────────────────────────────────────────────

class _PendingDonationsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(allPendingDonationsProvider);

    return async.when(
      loading: () => const ShimmerListPlaceholder(itemHeight: 180),
      error: (e, _) => EmptyStateWidget(
        icon:        Icons.error_outline_rounded,
        title:       'Could not load donations',
        subtitle:    e.toString(),
        actionLabel: 'Retry',
        onAction:    () =>
            ref.invalidate(allPendingDonationsProvider),
      ),
      data: (response) {
        if (response.data.isEmpty) {
          return const EmptyStateWidget(
            icon:     Icons.volunteer_activism_outlined,
            title:    'No Pending Donations',
            subtitle: 'All donations have been verified.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(allPendingDonationsProvider),
          color: AppColors.primary,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePaddingH,
              vertical:   AppDimensions.pagePaddingTop,
            ),
            itemCount:   response.data.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.spaceMD),
            itemBuilder: (context, i) {
              final d = response.data[i];
              return _PendingDonationTile(
                donation:   d,
                onVerified: () =>
                    ref.invalidate(allPendingDonationsProvider),
              );
            },
          ),
        );
      },
    );
  }
}

class _PendingDonationTile extends ConsumerWidget {
  const _PendingDonationTile({
    required this.donation,
    required this.onVerified,
  });

  final DonationModel donation;
  final VoidCallback  onVerified;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifyState = ref.watch(donationVerifyProvider);

    return Container(
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: donation.hasFraudFlags
              ? AppColors.warningBorder
              : AppColors.borderGrey,
          width: donation.hasFraudFlags ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:      AppColors.shadow,
            blurRadius: 4,
            offset:     const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────
            Row(
              children: [
                Container(
                  width:  40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: donation.hasFraudFlags
                        ? AppColors.warningLight
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    donation.hasFraudFlags
                        ? Icons.warning_amber_outlined
                        : Icons.volunteer_activism_outlined,
                    color: donation.hasFraudFlags
                        ? AppColors.warning
                        : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation.campaignTitle,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        donation.voterName ?? 'Voter',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${donation.amountClaimed.toStringAsFixed(0)}',
                      style: AppTextStyles.heading3.copyWith(
                          color: AppColors.primary),
                    ),
                    Text(
                      donation.upiTransactionId,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),

            // Fraud flag warning
            if (donation.hasFraudFlags) ...[
              const SizedBox(height: AppDimensions.spaceMD),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color:        AppColors.warningLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.warningBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Verification flags detected — '
                        'review carefully.',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.spaceMD),

            // ── Actions ──────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: verifyState.isLoading
                        ? null
                        : () async {
                            final ok = await ref
                                .read(donationVerifyProvider
                                    .notifier)
                                .verify(
                                  donationId: donation.id,
                                  accept:     false,
                                  rejectionReason:
                                      'Rejected by Corporator.',
                                );
                            if (ok) onVerified();
                          },
                    icon: const Icon(Icons.close_rounded,
                        size: 15),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(
                          color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: verifyState.isLoading
                        ? null
                        : () async {
                            final ok = await ref
                                .read(donationVerifyProvider
                                    .notifier)
                                .verify(
                                  donationId: donation.id,
                                  accept:     true,
                                );
                            if (ok) onVerified();
                          },
                    icon: verifyState.isLoading
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded,
                            size: 15),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      elevation:       0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

