import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../voter/campaigns/models/campaign_models.dart';
import '../providers/corporator_campaign_provider.dart';
import '../../../../core/utils/extensions.dart';

/// Full-screen pending donations list for a specific campaign.
class PendingDonationsScreen extends ConsumerWidget {
  const PendingDonationsScreen({
    super.key,
    required this.campaignId,
  });
  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
        campaignPendingDonationsProvider(campaignId));

    return AppScaffold(
      title: 'Pending Donations',
      body: async.when(
        loading: () => const ShimmerListPlaceholder(itemHeight: 180),
        error: (e, _) => EmptyStateWidget(
          icon:        Icons.error_outline_rounded,
          title:       'Could not load donations',
          subtitle:    e.toString(),
          actionLabel: 'Retry',
          onAction:    () => ref.invalidate(
              campaignPendingDonationsProvider(campaignId)),
        ),
        data: (response) {
          if (response.data.isEmpty) {
            return const EmptyStateWidget(
              icon:     Icons.check_circle_outline_rounded,
              title:    'All Caught Up!',
              subtitle: 'No donations pending verification '
                  'for this campaign.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(
                campaignPendingDonationsProvider(campaignId)),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePaddingH,
                vertical:   AppDimensions.pagePaddingTop,
              ),
              itemCount: response.data.length,
              itemBuilder: (context, i) {
                final d = response.data[i];
                return _DonationVerifyCard(
                  key:      ValueKey(d.id),
                  donation: d,
                  onVerified: () => ref.invalidate(
                      campaignPendingDonationsProvider(campaignId)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DonationVerifyCard extends ConsumerWidget {
  const _DonationVerifyCard({
    super.key,
    required this.donation,
    required this.onVerified,
  });

  final DonationModel donation;
  final VoidCallback  onVerified;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifyState = ref.watch(donationVerifyProvider);

    return Container(
      margin: const EdgeInsets.only(
          bottom: AppDimensions.spaceMD),
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
            // Fraud flags
            if (donation.hasFraudFlags)
              Container(
                width:   double.infinity,
                margin: const EdgeInsets.only(
                    bottom: AppDimensions.spaceMD),
                padding: const EdgeInsets.all(
                    AppDimensions.spaceSM),
                decoration: BoxDecoration(
                  color:        AppColors.warningLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.warningBorder),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${donation.fraudFlags.length} flag'
                        '${donation.fraudFlags.length == 1 ? '' : 's'} '
                        'detected — verify carefully.',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),

            // Voter + amount
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation.voterName ?? 'Voter',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        'UPI: ${donation.upiTransactionId}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${donation.amountClaimed.toStringAsFixed(0)}',
                  style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary),
                ),
              ],
            ),

            // Screenshot
            if (donation.screenshotUrl.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spaceMD),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  donation.screenshotUrl,
                  width:  double.infinity,
                  height: 160,
                  fit:    BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: AppColors.surfaceGrey,
                    child: const Center(
                      child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textSecondary,
                          size: 32),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.spaceMD),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
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
                            if (ok && context.mounted) {
                              context.showSuccess(
                                  'Donation rejected.');
                              onVerified();
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(
                          color: AppColors.error),
                    ),
                    child: const Text('Reject'),
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
                            if (ok && context.mounted) {
                              context.showSuccess(
                                  'Donation accepted. '
                                  'Receipt generated.');
                              onVerified();
                            }
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
                    label: const Text('Accept & Generate Receipt'),
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

