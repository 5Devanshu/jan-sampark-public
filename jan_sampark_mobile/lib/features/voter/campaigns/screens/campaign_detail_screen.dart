import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/badges/status_badge.dart';
import '../providers/campaign_provider.dart';
import '../widgets/campaign_progress_bar.dart';

/// Campaign detail screen with full description and donate button.
class CampaignDetailScreen extends ConsumerWidget {
  const CampaignDetailScreen({super.key, required this.campaignId});
  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(campaignDetailProvider(campaignId));

    return async.when(
      loading: () => const AppScaffold(
        title: 'Campaign',
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => AppScaffold(
        title: 'Campaign',
        body: EmptyStateWidget(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load campaign',
          subtitle: e.toString(),
        ),
      ),
      data: (campaign) => _CampaignDetailContent(campaign: campaign),
    );
  }
}

class _CampaignDetailContent extends StatelessWidget {
  const _CampaignDetailContent({required this.campaign});
  final campaign;

  @override
  Widget build(BuildContext context) {
    final canDonate = campaign.isActive && campaign.daysRemaining > 0;

    return AppScaffold(
      title: 'Campaign Details',
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cover image ────────────────
                  if (campaign.coverImageUrl != null)
                    Image.network(
                      campaign.coverImageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: AppColors.primaryLight,
                        child: const Center(
                          child: Icon(
                            Icons.campaign,
                            color: AppColors.primary,
                            size: 64,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 160,
                      width: double.infinity,
                      color: AppColors.primaryLight,
                      child: const Center(
                        child: Icon(
                          Icons.campaign,
                          color: AppColors.primary,
                          size: 64,
                        ),
                      ),
                    ),

                  // ── Main content ───────────────
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
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
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceGrey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                campaign.campaignType
                                    .replaceAll('_', ' ')
                                    .split(' ')
                                    .map(
                                      (w) => w.isEmpty
                                          ? w
                                          : w[0].toUpperCase() + w.substring(1),
                                    )
                                    .join(' '),
                                style: AppTextStyles.labelSmall,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimensions.spaceMD),

                        // Title
                        Text(campaign.title, style: AppTextStyles.heading1),

                        const SizedBox(height: AppDimensions.spaceXS),

                        // By Corporator
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'By ${campaign.createdByName}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimensions.spaceXL),

                        // Progress section
                        CampaignProgressBar(
                          amountCollected: campaign.amountCollected,
                          targetAmount: campaign.targetAmount,
                          progressPct: campaign.progressPct,
                          donationCount: campaign.donationCount,
                          daysRemaining: campaign.daysRemaining,
                        ),

                        const SizedBox(height: AppDimensions.spaceXL),

                        // Campaign dates
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.spaceMD),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMD,
                            ),
                            border: Border.all(color: AppColors.borderGrey),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _DateItem(
                                  label: 'Start Date',
                                  value: DateFormatter.toDisplayDate(
                                    DateFormatter.fromDateString(
                                      campaign.startDate,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 36,
                                width: 1,
                                color: AppColors.borderGrey,
                              ),
                              Expanded(
                                child: _DateItem(
                                  label: 'End Date',
                                  value: DateFormatter.toDisplayDate(
                                    DateFormatter.fromDateString(
                                      campaign.endDate,
                                    ),
                                  ),
                                  textColor:
                                      campaign.daysRemaining <= 3 &&
                                          campaign.daysRemaining > 0
                                      ? AppColors.warning
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceXL),

                        // Description
                        Text(
                          'About this Campaign',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppDimensions.spaceSM),
                        Text(campaign.description, style: AppTextStyles.body),

                        if (campaign.wardName != null ||
                            campaign.areaName != null) ...[
                          const SizedBox(height: AppDimensions.spaceXL),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                [campaign.wardName, campaign.areaName]
                                    .where((s) => s != null && s.isNotEmpty)
                                    .join(', '),
                                style: AppTextStyles.bodySecondary,
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom donate button ─────────────
          if (canDonate)
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
                label: 'Donate Now',
                icon: Icons.volunteer_activism_outlined,
                onPressed: () => context.goNamed(
                  RouteNames.donate,
                  pathParameters: {'id': campaign.id},
                ),
              ),
            )
          else if (!canDonate)
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
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                child: Center(
                  child: Text(
                    campaign.daysRemaining == 0
                        ? 'This campaign has ended'
                        : 'Donations are closed',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateItem extends StatelessWidget {
  const _DateItem({required this.label, required this.value, this.textColor});

  final String label;
  final String value;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
