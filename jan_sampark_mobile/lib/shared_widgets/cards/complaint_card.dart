import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/date_formatter.dart';
import '../badges/status_badge.dart';
import '../badges/priority_badge.dart';

/// Complaint list item card used across all roles.
///
/// Usage:
///   ComplaintCard(
///     complaintNumber: 'CMP-2025-00012',
///     title:           'Water supply issue in sector 4',
///     categoryName:    'Water Supply Problem',
///     status:          'pending',
///     priority:        'high',
///     wardName:        'K/W Ward',
///     createdAt:       DateTime.now(),
///     onTap:           () => context.goNamed(RouteNames.complaintDetail),
///     showEscalated:   true,
///   )
class ComplaintCard extends StatelessWidget {
  const ComplaintCard({
    super.key,
    required this.complaintNumber,
    required this.title,
    required this.categoryName,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.onTap,
    this.wardName,
    this.areaName,
    this.assignedToName,
    this.isEscalated   = false,
    this.showAssignee  = false,
    this.imageUrl,
  });

  final String complaintNumber;
  final String title;
  final String categoryName;
  final String status;
  final String priority;
  final DateTime createdAt;
  final VoidCallback onTap;
  final String? wardName;
  final String? areaName;
  final String? assignedToName;
  final bool isEscalated;
  final bool showAssignee;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:        AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: isEscalated
                ? AppColors.escalation
                : AppColors.borderGrey,
            width: isEscalated ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:       AppColors.shadow,
              blurRadius:  4,
              offset:      const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Escalation banner ──────────────────
            if (isEscalated)
              Container(
                width:  double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.cardPaddingH,
                  vertical:   5,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.escalationLight,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.cardRadius - 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.escalation, size: 14),
                    const SizedBox(width: 5),
                    Text('Escalated',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.escalation,
                        )),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row ───────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              complaintNumber,
                              style: AppTextStyles.codeLabel,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              title,
                              style: AppTextStyles.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      StatusBadge(status: status, small: true),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Category + Priority ──────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          categoryName,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PriorityBadge(priority: priority),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // ── Footer row ───────────────────
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          [wardName, areaName]
                              .where((s) => s != null && s.isNotEmpty)
                              .join(', '),
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormatter.timeAgo(createdAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),

                  if (showAssignee && assignedToName != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          assignedToName!,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}