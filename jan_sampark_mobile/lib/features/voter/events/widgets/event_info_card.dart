import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../models/event_models.dart';

/// Compact event info row widget — date, venue, capacity.
/// Used on the event detail screen below the cover image.
class EventInfoCard extends StatelessWidget {
  const EventInfoCard({super.key, required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        children: [
          // Date & Time
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            iconColor: AppColors.primary,
            label: 'Date & Time',
            value: event.formattedDateTime,
          ),
          const Divider(height: 1),

          // Venue
          _InfoRow(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.error,
            label: 'Venue',
            value: event.venueName,
            subtitle: event.venueAddress,
          ),
          const Divider(height: 1),

          // Ward / Area
          _InfoRow(
            icon: Icons.map_outlined,
            iconColor: AppColors.primaryAccent,
            label: 'Location',
            value: [
              event.wardName,
              event.areaName,
            ].where((s) => s != null && s!.isNotEmpty).join(', '),
          ),
          const Divider(height: 1),

          // Capacity
          _InfoRow(
            icon: Icons.people_outline,
            iconColor: AppColors.success,
            label: 'Registrations',
            value: event.maxCapacity != null
                ? '${event.totalRegistered} / ${event.maxCapacity}'
                : '${event.totalRegistered} registered',
            trailing: event.maxCapacity != null
                ? _CapacityBadge(event: event)
                : null,
          ),

          // Deadline (if set)
          if (event.registrationDeadline != null) ...[
            const Divider(height: 1),
            _InfoRow(
              icon: Icons.timer_outlined,
              iconColor: event.isDeadlinePassed
                  ? AppColors.error
                  : AppColors.warning,
              label: 'Registration Deadline',
              value: DateFormatter.toDisplayDate(
                DateFormatter.fromDateString(event.registrationDeadline),
              ),
              valueColor: event.isDeadlinePassed ? AppColors.error : null,
            ),
          ],

          // Organiser
          if (event.createdByName != null) ...[
            const Divider(height: 1),
            _InfoRow(
              icon: Icons.person_outline,
              iconColor: AppColors.textSecondary,
              label: 'Organised by',
              value: event.createdByName!,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.cardPaddingH,
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),

          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _CapacityBadge extends StatelessWidget {
  const _CapacityBadge({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    if (event.isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          'Full',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
        ),
      );
    }

    if (event.maxCapacity != null) {
      final remaining = event.spotsRemaining;
      final isLow = remaining <= 10;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isLow ? AppColors.warningLight : AppColors.successLight,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          '$remaining left',
          style: AppTextStyles.labelSmall.copyWith(
            color: isLow ? AppColors.warning : AppColors.success,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
