import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/date_formatter.dart';

/// Notification list item card.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.onTap,
    this.isRead = false,
    this.onDismiss,
  });

  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final VoidCallback onTap;
  final bool isRead;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key:        ValueKey('notif-$title-$createdAt'),
      direction:  DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding:   const EdgeInsets.only(right: 20),
        color:     AppColors.errorLight,
        child: const Icon(Icons.delete_outline,
            color: AppColors.error),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: isRead ? AppColors.white : AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical:   AppDimensions.space,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon ──────────────────────────────
              Container(
                width:  40,
                height: 40,
                decoration: BoxDecoration(
                  color:        _iconBg(type),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconData(type),
                  color: _iconColor(type),
                  size:  20,
                ),
              ),
              const SizedBox(width: 12),

              // ── Content ───────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(title,
                              style: isRead
                                  ? AppTextStyles.bodyMedium
                                  : AppTextStyles.bodySemiBold,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Text(DateFormatter.timeAgo(createdAt),
                            style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(body,
                        style: AppTextStyles.bodySecondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),

              // ── Unread dot ────────────────────────
              if (!isRead)
                Container(
                  width:  8, height: 8,
                  margin: const EdgeInsets.only(top: 4, left: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconData(String type) {
    return switch (type) {
      'complaint_assigned'     => Icons.assignment_ind_outlined,
      'complaint_acknowledged' => Icons.thumb_up_outlined,
      'complaint_escalated'    => Icons.warning_amber_outlined,
      'complaint_resolved'     => Icons.check_circle_outline,
      'complaint_rejected'     => Icons.cancel_outlined,
      'complaint_status_update'=> Icons.update_outlined,
      'donation_accepted'      => Icons.volunteer_activism_outlined,
      'donation_rejected'      => Icons.money_off_outlined,
      'event_registered'       => Icons.event_available_outlined,
      'announcement_published' => Icons.campaign_outlined,
      'poll_published'         => Icons.poll_outlined,
      _                        => Icons.notifications_outlined,
    };
  }

  Color _iconColor(String type) {
    return switch (type) {
      'complaint_resolved' || 'donation_accepted' || 'event_registered'
          => AppColors.success,
      'complaint_rejected' || 'donation_rejected'
          => AppColors.error,
      'complaint_escalated'
          => AppColors.escalation,
      'announcement_published' || 'poll_published'
          => AppColors.primary,
      _ => AppColors.primaryAccent,
    };
  }

  Color _iconBg(String type) {
    return switch (type) {
      'complaint_resolved' || 'donation_accepted' || 'event_registered'
          => AppColors.successLight,
      'complaint_rejected' || 'donation_rejected'
          => AppColors.errorLight,
      'complaint_escalated'
          => AppColors.escalationLight,
      _ => AppColors.primaryLight,
    };
  }
}