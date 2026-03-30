import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/date_formatter.dart';
import '../badges/status_badge.dart';

/// Event list item card.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.title,
    required this.eventDate,
    required this.eventTime,
    required this.venueName,
    required this.status,
    required this.onTap,
    this.wardName,
    this.totalRegistered = 0,
    this.maxCapacity,
    this.isRegistered   = false,
    this.coverImageUrl,
  });

  final String title;
  final String eventDate;
  final String eventTime;
  final String venueName;
  final String status;
  final VoidCallback onTap;
  final String? wardName;
  final int totalRegistered;
  final int? maxCapacity;
  final bool isRegistered;
  final String? coverImageUrl;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormatter.toEventDateTime(eventDate, eventTime);
    final isFull    = maxCapacity != null && totalRegistered >= maxCapacity!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:        AppColors.white,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover image ─────────────────────────
            if (coverImageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.cardRadius - 1),
                ),
                child: Image.network(
                  coverImageUrl!,
                  height:    140,
                  width:     double.infinity,
                  fit:       BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color:  AppColors.primaryLight,
                    child: const Center(
                      child: Icon(Icons.event,
                          color: AppColors.primary, size: 48),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title + Status ───────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(title,
                            style: AppTextStyles.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: status, small: true),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Date / Time ──────────────────
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text(dateLabel, style: AppTextStyles.captionMedium
                          .copyWith(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // ── Venue ────────────────────────
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          venueName,
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // ── Footer ───────────────────────
                  Row(
                    children: [
                      const Icon(Icons.people_outline,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        maxCapacity != null
                            ? '$totalRegistered / $maxCapacity registered'
                            : '$totalRegistered registered',
                        style: AppTextStyles.caption,
                      ),
                      const Spacer(),
                      if (isRegistered)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.verifiedBg,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 12, color: AppColors.verifiedText),
                              const SizedBox(width: 3),
                              Text('Registered',
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.verifiedText)),
                            ],
                          ),
                        )
                      else if (isFull)
                        Text('Full',
                            style: AppTextStyles.captionMedium.copyWith(
                                color: AppColors.error)),
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