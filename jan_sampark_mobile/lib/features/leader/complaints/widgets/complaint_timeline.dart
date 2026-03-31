import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../dashboard/repositories/leader_complaint_repository.dart';

/// Vertical audit trail timeline shown on complaint detail.
class ComplaintTimeline extends StatelessWidget {
  const ComplaintTimeline({super.key, required this.auditTrail});

  final List<ComplaintAuditEntry> auditTrail;

  @override
  Widget build(BuildContext context) {
    if (auditTrail.isEmpty) {
      return Text('No history yet.', style: AppTextStyles.bodySecondary);
    }

    return Column(
      children: List.generate(auditTrail.length, (i) {
        final entry = auditTrail[i];
        final isLast = i == auditTrail.length - 1;
        return _TimelineItem(entry: entry, isLast: isLast);
      }),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.entry, required this.isLast});

  final ComplaintAuditEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final config = _actionConfig(entry.action);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline line + dot ───────────────
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: config.bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(config.icon, color: config.color, size: 16),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.borderGrey,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Content ───────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppDimensions.spaceXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action label
                  Text(
                    _actionLabel(entry.action),
                    style: AppTextStyles.bodyMedium,
                  ),

                  // Status change
                  if (entry.fromStatus != null && entry.toStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          _StatusPill(status: entry.fromStatus!),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          _StatusPill(status: entry.toStatus!),
                        ],
                      ),
                    ),

                  // Reason
                  if (entry.reason != null && entry.reason!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        entry.reason!,
                        style: AppTextStyles.bodySecondary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  const SizedBox(height: 4),

                  // Meta
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(entry.changedByName, style: AppTextStyles.caption),
                      const SizedBox(width: 8),
                      _RolePill(role: entry.changedByRole),
                      const Spacer(),
                      Text(
                        DateFormatter.timeAgo(entry.timestamp),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ActionConfig _actionConfig(String action) {
    return switch (action) {
      'filed' => _ActionConfig(
          Icons.add_circle_outline,
          AppColors.primary,
          AppColors.primaryLight,
        ),
      'acknowledged' => _ActionConfig(
          Icons.thumb_up_outlined,
          AppColors.primaryAccent,
          AppColors.primaryLight,
        ),
      'status_update' => _ActionConfig(
          Icons.update_outlined,
          const Color(0xFF5521B5),
          const Color(0xFFEDEBFE),
        ),
      'escalated' => _ActionConfig(
          Icons.warning_amber_rounded,
          AppColors.escalation,
          AppColors.escalationLight,
        ),
      'note_added' => _ActionConfig(
          Icons.note_add_outlined,
          AppColors.textSecondary,
          AppColors.surfaceGrey,
        ),
      'resolved' => _ActionConfig(
          Icons.check_circle_outline,
          AppColors.success,
          AppColors.successLight,
        ),
      'rejected' => _ActionConfig(
          Icons.cancel_outlined,
          AppColors.error,
          AppColors.errorLight,
        ),
      'closed' => _ActionConfig(
          Icons.lock_outline,
          AppColors.textSecondary,
          AppColors.surfaceGrey,
        ),
      'feedback' => _ActionConfig(
          Icons.star_outline_rounded,
          const Color(0xFFFACC15),
          const Color(0xFFFEF9C3),
        ),
      _ => _ActionConfig(
          Icons.circle_outlined,
          AppColors.textSecondary,
          AppColors.surfaceGrey,
        ),
    };
  }

  String _actionLabel(String action) {
    return switch (action) {
      'filed' => 'Complaint Filed',
      'assigned' => 'Assigned',
      'acknowledged' => 'Acknowledged',
      'status_update' => 'Status Updated',
      'escalated' => 'Escalated',
      'note_added' => 'Note Added',
      'resolved' => 'Resolved',
      'rejected' => 'Rejected',
      'closed' => 'Closed',
      'feedback' => 'Voter Feedback',
      _ => action.replaceAll('_', ' ').toUpperCase(),
    };
  }
}

class _ActionConfig {
  const _ActionConfig(this.icon, this.color, this.bg);
  final IconData icon;
  final Color color;
  final Color bg;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Text(status.replaceAll('_', ' '), style: AppTextStyles.caption),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final color = switch (role) {
      'corporator' => AppColors.primary,
      'leader' => AppColors.primaryAccent,
      'voter' => AppColors.success,
      _ => AppColors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(role, style: AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }
}
