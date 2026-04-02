import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/layout/section_header.dart';
import '../../../../shared_widgets/badges/status_badge.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../voter/campaigns/providers/campaign_provider.dart';
import '../../../voter/campaigns/widgets/campaign_progress_bar.dart';
import '../providers/corporator_campaign_provider.dart';
import '../../../voter/campaigns/models/campaign_models.dart';

class CorporatorCampaignDetailScreen extends ConsumerWidget {
  const CorporatorCampaignDetailScreen({
    super.key,
    required this.campaignId,
  });
  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(campaignDetailProvider(campaignId));
    final pendingAsync =
        ref.watch(campaignPendingDonationsProvider(campaignId));

    return async.when(
      loading: () => const AppScaffold(
        title: 'Campaign',
        body:  Center(child: CircularProgressIndicator(
            color: AppColors.primary)),
      ),
      error: (e, _) => AppScaffold(
        title: 'Campaign',
        body:  EmptyStateWidget(
          icon:     Icons.error_outline_rounded,
          title:    'Failed to load campaign',
          subtitle: e.toString(),
        ),
      ),
      data: (campaign) {
        final pendingCount = pendingAsync.maybeWhen(
          data: (d) => d.total,
          orElse: () => 0,
        );

        return AppScaffold(
          title: 'Campaign Details',
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(
                AppDimensions.pagePaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spaceSM),

                // Status + type row
                Row(
                  children: [
                    StatusBadge(status: campaign.status),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:        AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        campaign.campaignType
                            .replaceAll('_', ' '),
                        style: AppTextStyles.labelSmall,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spaceMD),

                Text(campaign.title,
                    style: AppTextStyles.heading1),

                const SizedBox(height: AppDimensions.spaceXL),

                // Progress
                CampaignProgressBar(
                  amountCollected: campaign.amountCollected,
                  targetAmount:    campaign.targetAmount,
                  progressPct:     campaign.progressPct,
                  donationCount:   campaign.donationCount,
                  daysRemaining:   campaign.daysRemaining,
                ),

                const SizedBox(height: AppDimensions.spaceXL),

                // Pending donations button
                if (pendingCount > 0)
                  Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.all(
                        AppDimensions.spaceMD),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius),
                      border: Border.all(
                          color: AppColors.warningBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                            Icons.pending_actions_outlined,
                            color: AppColors.warning, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$pendingCount donation'
                            '${pendingCount == 1 ? '' : 's'} '
                            'awaiting verification.',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.warning),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.goNamed(
                            RouteNames.pendingDonations,
                            pathParameters: {
                              'id': campaignId,
                            },
                          ),
                          child: const Text('Review'),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppDimensions.spaceXL),

                // Description
                Text('About', style: AppTextStyles.heading3),
                const SizedBox(height: AppDimensions.spaceSM),
                Text(campaign.description,
                    style: AppTextStyles.body.copyWith(
                        height: 1.6)),

                // Dates
                const SizedBox(height: AppDimensions.spaceXL),
                _DatesRow(campaign: campaign),

                const SizedBox(height: AppDimensions.spaceXXL),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DatesRow extends StatelessWidget {
  const _DatesRow({required this.campaign});
  final CampaignModel campaign;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color:        AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('Start Date', style: AppTextStyles.caption),
                const SizedBox(height: 3),
                Text(
                  DateFormatter.toDisplayDate(
                      DateFormatter.fromDateString(
                          campaign.startDate)),
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          Container(width: 1, height: 36,
              color: AppColors.borderGrey),
          Expanded(
            child: Column(
              children: [
                Text('End Date', style: AppTextStyles.caption),
                const SizedBox(height: 3),
                Text(
                  DateFormatter.toDisplayDate(
                      DateFormatter.fromDateString(
                          campaign.endDate)),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: campaign.daysRemaining <= 3 &&
                            campaign.daysRemaining > 0
                        ? AppColors.warning
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}