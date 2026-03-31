import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/badges/status_badge.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/buttons/secondary_button.dart';
import '../models/campaign_models.dart';
import '../providers/campaign_provider.dart';
import '../repositories/campaign_repository.dart';

/// Donation detail / status screen.
///
/// Shows full donation info — amount, UPI txn ID, status,
/// fraud flags (if any), verification note, and receipt
/// download link once accepted.
///
/// Can receive the donation model directly via [extra]
/// (from donate screen navigation) or fetches by [donationId].
class DonationStatusScreen extends ConsumerWidget {
  const DonationStatusScreen({
    super.key,
    required this.donationId,
    this.initialDonation,
  });

  final String donationId;
  final DonationModel? initialDonation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If we have initial data (navigating from donate screen)
    // use it, but also watch for updates via a provider
    final donationAsync = ref.watch(_donationDetailProvider(donationId));

    return donationAsync.when(
      loading: () => initialDonation != null
          ? _DonationStatusContent(donation: initialDonation!)
          : const AppScaffold(
              title: 'Donation Status',
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
      error: (e, _) => initialDonation != null
          ? _DonationStatusContent(donation: initialDonation!)
          : AppScaffold(
              title: 'Donation Status',
              body: EmptyStateWidget(
                icon: Icons.error_outline_rounded,
                title: 'Failed to load donation',
                subtitle: e.toString(),
              ),
            ),
      data: (donation) => _DonationStatusContent(donation: donation),
    );
  }
}

// ─────────────────────────────────────────────
// Donation detail provider
// ─────────────────────────────────────────────

final _donationDetailProvider = FutureProvider.autoDispose
    .family<DonationModel, String>((ref, id) async {
      final repo = ref.watch(campaignRepositoryProvider);
      final response = await repo.fetchDonationDetail(id);
      return response.when(success: (data) => data, error: (e) => throw e);
    });

// ─────────────────────────────────────────────
// Content
// ─────────────────────────────────────────────

class _DonationStatusContent extends StatelessWidget {
  const _DonationStatusContent({required this.donation});
  final DonationModel donation;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Donation Status',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spaceMD),

            // ── Status hero ──────────────────────
            _StatusHero(donation: donation),

            const SizedBox(height: AppDimensions.spaceXXL),

            // ── Donation details card ────────────
            _DetailCard(
              title: 'Donation Details',
              rows: [
                _DetailRow(label: 'Campaign', value: donation.campaignTitle),
                _DetailRow(
                  label: 'Amount',
                  value: CurrencyFormatter.format(donation.amountClaimed),
                  valueStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                _DetailRow(
                  label: 'UPI Transaction ID',
                  value: donation.upiTransactionId,
                ),
                _DetailRow(
                  label: 'Submitted',
                  value: DateFormatter.toDisplayDateTime(donation.createdAt),
                ),
                if (donation.verifiedAt != null)
                  _DetailRow(
                    label: donation.isAccepted ? 'Accepted On' : 'Reviewed On',
                    value: DateFormatter.toDisplayDateTime(donation.verifiedAt),
                  ),
              ],
            ),

            // ── OCR verification ─────────────────
            if (donation.ocrExtractedAmount != null) ...[
              const SizedBox(height: AppDimensions.spaceMD),
              _DetailCard(
                title: 'Automatic Verification',
                rows: [
                  _DetailRow(
                    label: 'Amount Claimed',
                    value: CurrencyFormatter.format(donation.amountClaimed),
                  ),
                  _DetailRow(
                    label: 'OCR Extracted',
                    value: CurrencyFormatter.format(
                      donation.ocrExtractedAmount!,
                    ),
                    valueStyle:
                        (donation.ocrExtractedAmount! - donation.amountClaimed)
                                .abs() >
                            1.0
                        ? AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          )
                        : AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                          ),
                  ),
                ],
              ),
            ],

            // ── Fraud flags ──────────────────────
            if (donation.hasFraudFlags) ...[
              const SizedBox(height: AppDimensions.spaceMD),
              _FraudFlagsCard(flags: donation.fraudFlags),
            ],

            // ── Verification note ────────────────
            if (donation.verificationNote != null &&
                donation.verificationNote!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spaceMD),
              _NoteCard(
                title: donation.isAccepted
                    ? 'Acceptance Note'
                    : 'Rejection Reason',
                note: donation.verificationNote!,
                color: donation.isAccepted
                    ? AppColors.successLight
                    : AppColors.errorLight,
                textColor: donation.isAccepted
                    ? AppColors.success
                    : AppColors.error,
              ),
            ],

            const SizedBox(height: AppDimensions.spaceXXL),

            // ── Receipt download ─────────────────
            if (donation.hasReceipt) ...[
              PrimaryButton(
                label: 'Download Receipt',
                icon: Icons.receipt_long_outlined,
                onPressed: () {
                  // Receipt download handled via browser
                  // URL construction: base_url + receipt_pdf_url
                },
              ),
              const SizedBox(height: AppDimensions.spaceMD),
            ],

            // ── Pending state info ───────────────
            if (donation.isPending || donation.isPendingReview) ...[
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceMD),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        donation.isPendingReview
                            ? 'Your donation has been flagged for '
                                  'manual review. The Corporator will '
                                  'verify it shortly.'
                            : 'Your donation is pending review by '
                                  'the Corporator. You will be notified '
                                  'once it is accepted.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMD),
            ],

            SecondaryButton(
              label: 'Back to Campaigns',
              onPressed: () => context.pop(),
            ),

            const SizedBox(height: AppDimensions.spaceXXL),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Status hero widget
// ─────────────────────────────────────────────

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.donation});
  final DonationModel donation;

  @override
  Widget build(BuildContext context) {
    final config = _heroConfig(donation.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spaceXXL),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: config.border),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: config.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(config.icon, color: config.iconColor, size: 36),
          ),
          const SizedBox(height: 14),
          StatusBadge(status: donation.status),
          const SizedBox(height: 8),
          Text(config.title, style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text(
            config.subtitle,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  _HeroConfig _heroConfig(String status) {
    return switch (status) {
      'accepted' => _HeroConfig(
        bg: AppColors.successLight,
        border: AppColors.successBorder,
        icon: Icons.check_circle_rounded,
        iconBg: AppColors.success.withOpacity(0.15),
        iconColor: AppColors.success,
        title: 'Donation Accepted',
        subtitle: 'Thank you for your contribution.',
      ),
      'rejected' => _HeroConfig(
        bg: AppColors.errorLight,
        border: AppColors.errorBorder,
        icon: Icons.cancel_rounded,
        iconBg: AppColors.error.withOpacity(0.15),
        iconColor: AppColors.error,
        title: 'Donation Not Accepted',
        subtitle: 'Please review the reason below.',
      ),
      'pending_review' => _HeroConfig(
        bg: AppColors.warningLight,
        border: AppColors.warningBorder,
        icon: Icons.pending_outlined,
        iconBg: AppColors.warning.withOpacity(0.15),
        iconColor: AppColors.warning,
        title: 'Under Review',
        subtitle: 'Flagged for manual verification.',
      ),
      _ => _HeroConfig(
        bg: AppColors.primaryLight,
        border: AppColors.primaryFocus,
        icon: Icons.hourglass_empty_rounded,
        iconBg: AppColors.primary.withOpacity(0.12),
        iconColor: AppColors.primary,
        title: 'Pending Verification',
        subtitle: 'Awaiting Corporator review.',
      ),
    };
  }
}

class _HeroConfig {
  const _HeroConfig({
    required this.bg,
    required this.border,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
  final Color bg;
  final Color border;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
}

// ─────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.rows});
  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(title, style: AppTextStyles.bodyMedium),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          ...rows,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueStyle});
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.cardPaddingH,
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(child: Text(value, style: valueStyle ?? AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _FraudFlagsCard extends StatelessWidget {
  const _FraudFlagsCard({required this.flags});
  final List<FraudFlagModel> flags;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.warningBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Verification Flags',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...flags.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(f.detail, style: AppTextStyles.body)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.title,
    required this.note,
    required this.color,
    required this.textColor,
  });
  final String title;
  final String note;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(color: textColor),
          ),
          const SizedBox(height: 6),
          Text(note, style: AppTextStyles.body.copyWith(color: textColor)),
        ],
      ),
    );
  }
}
