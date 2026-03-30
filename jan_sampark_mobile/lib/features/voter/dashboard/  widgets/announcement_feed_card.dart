// lib/features/voter/dashboard/widgets/announcement_feed_card.dart
//
// Single announcement list item shown in the dashboard feed.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../models/voter_dashboard_models.dart';

class AnnouncementFeedCard extends StatelessWidget {
  const AnnouncementFeedCard({
    super.key,
    required this.item,
    required this.index,
  });

  final DashboardAnnouncement item;
  final int                   index;

  // Category colour mapping
  Color get _categoryColor {
    return switch (item.category.toLowerCase()) {
      'health'        => const Color(0xFF0284C7),
      'infrastructure'=> const Color(0xFF7C3AED),
      'education'     => const Color(0xFF059669),
      'water'         => const Color(0xFF0EA5E9),
      'election'      => AppColors.primary,
      'emergency'     => AppColors.error,
      _               => AppColors.textSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        RouteNames.voterAnnouncementDetail,
        pathParameters: {'id': item.id},
      ),
      child: Container(
        margin: EdgeInsets.only(
          left:   index == 0 ? AppDimensions.pagePaddingH : 0,
          right:  AppDimensions.spaceMD,
        ),
        width: 280,
        decoration: BoxDecoration(
          color:        AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border:       Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color:      AppColors.shadow,
              blurRadius: 8,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Category stripe ──────────────────
            Container(
              height:      4,
              decoration:  BoxDecoration(
                color: _categoryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.cardRadius),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category chip ──────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          item.category.toUpperCase(),
                          style: AppTextStyles.captionSmall.copyWith(
                            color:      _categoryColor,
                            fontWeight: FontWeight.w700,
                            fontSize:   9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (item.isAcknowledged) ...[
                        const Spacer(),
                        Icon(
                          Icons.check_circle,
                          size:  14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Read',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Title ─────────────────────
                  Text(
                    item.title,
                    style:    AppTextStyles.labelMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 5),

                  // ── Preview ───────────────────
                  Text(
                    item.contentPreview,
                    style:    AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // ── Footer ────────────────────
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size:  12,
                        color: AppColors.textDisabled,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          item.createdByName ?? 'Official',
                          style:    AppTextStyles.captionSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.visibility_outlined,
                        size:  12,
                        color: AppColors.textDisabled,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${item.viewCount}',
                        style: AppTextStyles.captionSmall,
                      ),
                    ],
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