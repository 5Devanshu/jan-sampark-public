import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// ─────────────────────────────────────────────
// Pending Donation Model
// ─────────────────────────────────────────────

class PendingDonation {
  const PendingDonation({
    required this.id,
    required this.campaignTitle,
    required this.voterName,
    required this.amountClaimed,
    required this.upiTransactionId,
    required this.screenshotUrl,
    required this.status,
    this.ocrExtractedAmount,
    this.fraudFlags       = const [],
    this.createdAt,
  });

  final String   id;
  final String   campaignTitle;
  final String   voterName;
  final double   amountClaimed;
  final String   upiTransactionId;
  final String   screenshotUrl;
  final String   status;
  final double?  ocrExtractedAmount;
  final List<String> fraudFlags;
  final DateTime?    createdAt;

  bool get hasAmountMismatch =>
      ocrExtractedAmount != null &&
      (ocrExtractedAmount! - amountClaimed).abs() > 1.0;

  bool get hasFraudFlags => fraudFlags.isNotEmpty;

  factory PendingDonation.fromJson(Map<String, dynamic> json) {
    return PendingDonation(
      id:                json['id']                 as String? ?? '',
      campaignTitle:     json['campaign_title']      as String? ?? '',
      voterName:         json['voter_name']          as String? ?? '',
      amountClaimed:     _toDouble(json['amount_claimed']),
      upiTransactionId:  json['upi_transaction_id']  as String? ?? '',
      screenshotUrl:     json['screenshot_url']      as String? ?? '',
      status:            json['status']              as String? ?? '',
      ocrExtractedAmount: json['ocr_extracted_amount'] != null
          ? _toDouble(json['ocr_extracted_amount'])
          : null,
      fraudFlags: (json['fraud_flags'] as List<dynamic>? ?? [])
          .map((e) {
            if (e is Map) return e['detail']?.toString() ?? '';
            return e.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList(),
      createdAt: DateTime.tryParse(
          json['created_at'] as String? ?? ''),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int)    return v.toDouble();
    return 0.0;
  }
}

// ─────────────────────────────────────────────
// Provider — pending donations list
// ─────────────────────────────────────────────

final pendingDonationsProvider = FutureProvider.autoDispose
    .family<List<PendingDonation>, String>((ref, campaignId) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(
    AppConstants.endpointDonations,
    queryParameters: {
      'campaign_id': campaignId,
      'status':      'pending',
      'page_size':   50,
    },
  );
  final data = res.data as Map<String, dynamic>;
  return (data['data'] as List<dynamic>? ?? [])
      .map((e) =>
          PendingDonation.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ─────────────────────────────────────────────
// Verify / Reject donation provider
// ─────────────────────────────────────────────

final _verifyLoadingProvider =
    StateProvider.autoDispose<String?>((ref) => null);

// ─────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────

/// Card showing a single pending donation for verification.
/// Used on the complaint detail screen when the complaint
/// category is 'Donation Dispute' or from the campaign screen.
class DonationVerificationCard extends ConsumerWidget {
  const DonationVerificationCard({
    super.key,
    required this.donation,
    required this.onVerified,
  });

  final PendingDonation donation;
  final VoidCallback    onVerified;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifyingId = ref.watch(_verifyLoadingProvider);
    final isVerifying = verifyingId == donation.id;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fraud warning banner
                if (donation.hasFraudFlags)
                  Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    margin: const EdgeInsets.only(
                        bottom: AppDimensions.spaceMD),
                    decoration: BoxDecoration(
                      color:        AppColors.warningLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.warningBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning, size: 15),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verification flags detected',
                                style: AppTextStyles.captionMedium
                                    .copyWith(
                                        color: AppColors.warning),
                              ),
                              const SizedBox(height: 3),
                              ...donation.fraudFlags.map(
                                (f) => Text('• $f',
                                    style: AppTextStyles.caption
                                        .copyWith(
                                            color:
                                                AppColors.warning)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Voter + Campaign
                Row(
                  children: [
                    Container(
                      width:  40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:        AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.volunteer_activism_outlined,
                        color: AppColors.primary,
                        size:  20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(donation.voterName,
                              style: AppTextStyles.bodyMedium),
                          Text(donation.campaignTitle,
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Text(
                      DateFormatter.timeAgo(donation.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spaceMD),

                // Amount comparison
                Container(
                  padding: const EdgeInsets.all(
                      AppDimensions.spaceMD),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AmountColumn(
                          label: 'Claimed',
                          value: CurrencyFormatter.format(
                              donation.amountClaimed),
                          color: AppColors.primary,
                        ),
                      ),
                      if (donation.ocrExtractedAmount != null) ...[
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.borderGrey,
                        ),
                        Expanded(
                          child: _AmountColumn(
                            label: 'OCR Detected',
                            value: CurrencyFormatter.format(
                                donation.ocrExtractedAmount!),
                            color: donation.hasAmountMismatch
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                      ],
                      Container(
                        width: 1,
                        height: 36,
                        color: AppColors.borderGrey,
                      ),
                      Expanded(
                        child: _AmountColumn(
                          label: 'UPI Ref',
                          value: donation.upiTransactionId,
                          color: AppColors.textPrimary,
                          isSmall: true,
                        ),
                      ),
                    ],
                  ),
                ),

                // OCR mismatch warning
                if (donation.hasAmountMismatch) ...[
                  const SizedBox(height: AppDimensions.spaceSM),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color:        AppColors.errorLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.error, size: 13),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Amount mismatch: OCR detected '
                            '${CurrencyFormatter.format(donation.ocrExtractedAmount!)} '
                            'but voter claimed '
                            '${CurrencyFormatter.format(donation.amountClaimed)}.',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppDimensions.spaceMD),

                // Screenshot thumbnail
                if (donation.screenshotUrl.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showScreenshot(
                        context, donation.screenshotUrl),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            donation.screenshotUrl,
                            width:  double.infinity,
                            height: 140,
                            fit:    BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(
                              height: 140,
                              color:  AppColors.surfaceGrey,
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color: AppColors.textSecondary,
                                    size:  32),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right:  8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius:
                                  BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.zoom_in_rounded,
                                  color: Colors.white,
                                  size:  13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'View full',
                                  style: AppTextStyles.caption
                                      .copyWith(
                                          color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Action buttons ───────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.cardPaddingH,
              0,
              AppDimensions.cardPaddingH,
              AppDimensions.cardPaddingH,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isVerifying
                        ? null
                        : () => _handleVerification(
                            context, ref,
                            accept: false),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(
                          color: AppColors.error),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isVerifying
                        ? null
                        : () => _handleVerification(
                            context, ref,
                            accept: true),
                    icon: isVerifying
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 16),
                    label: Text(
                      isVerifying
                          ? 'Verifying...'
                          : 'Accept Donation',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      elevation:       0,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVerification(
    BuildContext context,
    WidgetRef ref, {
    required bool accept,
  }) async {
    ref.read(_verifyLoadingProvider.notifier).state = donation.id;

    try {
      final dio = ref.read(dioProvider);
      await dio.patch(
        '${AppConstants.endpointDonations}/${donation.id}/verify',
        data: {
          'action': accept ? 'accept' : 'reject',
          if (!accept) 'rejection_reason': 'Rejected by Corporator.',
        },
      );
      if (context.mounted) {
        context.showSuccess(accept
            ? 'Donation accepted — receipt generated.'
            : 'Donation rejected.');
        onVerified();
      }
    } catch (e) {
      if (context.mounted) {
        context.showError('Action failed: ${e.toString()}');
      }
    } finally {
      ref.read(_verifyLoadingProvider.notifier).state = null;
    }
  }

  void _showScreenshot(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(url),
              ),
            ),
            Positioned(
              top:   8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:  Colors.black.withOpacity(0.6),
                    shape:  BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.value,
    required this.color,
    this.isSmall = false,
  });

  final String label;
  final String value;
  final Color  color;
  final bool   isSmall;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 3),
        Text(
          value,
          style: (isSmall
                  ? AppTextStyles.caption
                  : AppTextStyles.bodyMedium)
              .copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

import '../../../../core/utils/extensions.dart';