import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/constants/app_constants.dart';

/// Announcement list item card.
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.title,
    required this.contentPreview,
    required this.category,
    required this.createdByName,
    required this.publishedAt,
    required this.onTap,
    this.isAcknowledged = false,
    this.viewCount      = 0,
  });

  final String title;
  final String contentPreview;
  final String category;
  final String createdByName;
  final DateTime? publishedAt;
  final VoidCallback onTap;
  final bool isAcknowledged;
  final int viewCount;

  @override
  Widget build(BuildContext context) {
    final categoryLabel =
        AppConstants.announcementCategoryLabels[category] ?? category;
    final categoryColor = _categoryColor(category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
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
              // ── Category chip + acknowledged ─────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      categoryLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                          color: categoryColor),
                    ),
                  ),
                  const Spacer(),
                  if (isAcknowledged)
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 14, color: AppColors.success),
                        const SizedBox(width: 3),
                        Text('Read',
                            style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.success)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Title ────────────────────────────
              Text(title,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),

              // ── Preview ──────────────────────────
              Text(contentPreview,
                  style: AppTextStyles.bodySecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // ── Footer ───────────────────────────
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(createdByName, style: AppTextStyles.caption),
                  const Spacer(),
                  if (viewCount > 0) ...[
                    const Icon(Icons.remove_red_eye_outlined,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text('$viewCount', style: AppTextStyles.caption),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    DateFormatter.timeAgo(publishedAt),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(String cat) {
    return switch (cat) {
      'policy'        => AppColors.primaryDark,
      'scheme'        => AppColors.success,
      'achievement'   => const Color(0xFF7C3AED),
      'party_message' => AppColors.primary,
      _               => AppColors.primaryAccent,
    };
  }
}