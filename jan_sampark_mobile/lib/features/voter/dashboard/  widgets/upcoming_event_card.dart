// lib/features/voter/dashboard/widgets/upcoming_event_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../models/voter_dashboard_models.dart';

class UpcomingEventCard extends StatelessWidget {
  const UpcomingEventCard({super.key, required this.event});

  final DashboardEvent event;

  String get _formattedDate {
    if (event.eventDate == null) return 'Date TBD';
    return DateFormat('EEE, d MMM · h:mm a').format(event.eventDate!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        RouteNames.voterEvents,
        queryParameters: {'event_id': event.id},
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
        ),
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
        child: Row(
          children: [
            // ── Date panel ─────────────────────────
            Container(
              width:  72,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppDimensions.cardRadius),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.eventDate != null
                        ? DateFormat('MMM').format(event.eventDate!).toUpperCase()
                        : '—',
                    style: AppTextStyles.captionSmall.copyWith(
                      color:       AppColors.textOnPrimary.withOpacity(0.8),
                      fontWeight:  FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    event.eventDate != null
                        ? DateFormat('d').format(event.eventDate!)
                        : '?',
                    style: AppTextStyles.heading1.copyWith(
                      color:    AppColors.textOnPrimary,
                      fontSize: 30,
                      height:   1.0,
                    ),
                  ),
                  Text(
                    event.eventDate != null
                        ? DateFormat('EEE').format(event.eventDate!).toUpperCase()
                        : '',
                    style: AppTextStyles.captionSmall.copyWith(
                      color:       AppColors.textOnPrimary.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Event details ──────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style:    AppTextStyles.labelMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    if (event.venueName != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size:  12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              event.venueName!,
                              style:    AppTextStyles.caption,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size:  12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          event.maxParticipants != null
                              ? '${event.registeredCount} / '
                                '${event.maxParticipants} registered'
                              : '${event.registeredCount} registered',
                          style: AppTextStyles.caption,
                        ),
                        const Spacer(),
                        // Registration status badge
                        if (event.isRegistered)
                          _Badge(label: 'Registered', color: AppColors.success)
                        else if (event.isFull)
                          _Badge(label: 'Full',       color: AppColors.textSecondary)
                        else
                          _Badge(label: 'Open',       color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionSmall.copyWith(
          color:      color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}