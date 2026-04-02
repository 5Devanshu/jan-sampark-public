import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Campaign list item card.
class CampaignCard extends StatelessWidget {
  const CampaignCard({
    super.key,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.amountCollected,
    required this.progressPct,
    required this.donationCount,
    required this.status,
    required this.endDate,
    required this.onTap,
    this.coverImageUrl,
  });

  final String title;
  final String description;
  final double targetAmount;
  final double amountCollected;
  final double progressPct;
  final int donationCount;
  final String status;
  final String? endDate;
  final String? coverImageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.cardRadius),
                ),
                child: Image.network(
                  coverImageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: AppColors.surfaceGrey,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading3),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTextStyles.bodySecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (progressPct / 100).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColors.borderGrey,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${amountCollected.toStringAsFixed(0)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'of ₹${targetAmount.toStringAsFixed(0)}',
                        style: AppTextStyles.caption,
                      ),
                      const Spacer(),
                      Text(
                        '$donationCount donations',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Status: $status',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
