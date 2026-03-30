// lib/features/voter/dashboard/widgets/my_complaints_summary_card.dart
//
// Summary card showing the voter's complaint status distribution
// as four coloured count tiles + a file-new shortcut.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../models/voter_dashboard_models.dart';

class MyComplaintsSummaryCard extends StatelessWidget {
  const MyComplaintsSummaryCard({
    super.key,
    required this.summary,
  });

  final VoterComplaintSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
      ),
      child: Container(
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
          children: [
            // ── Top row ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding:     const EdgeInsets.all(8),
                    decoration:  BoxDecoration(
                      color:        AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.report_problem_outlined,
                      color: AppColors.primary,
                      size:  18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Complaints',
                          style: AppTextStyles.labelMedium,
                        ),
                        Text(
                          '${summary.total} total filed',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  // File new complaint shortcut
                  GestureDetector(
                    onTap: () => context.pushNamed(RouteNames.voterComplaints),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:        AppColors.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '+ File New',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider ────────────────────────────
            Divider(color: AppColors.borderGrey, height: 1),

            // ── Status grid ────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _StatusCount(
                    label: 'Pending',
                    count: summary.pending,
                    bg:    AppColors.statusPendingBg,
                    text:  AppColors.statusPendingText,
                  ),
                  const SizedBox(width: 8),
                  _StatusCount(
                    label: 'In Progress',
                    count: summary.inProgress,
                    bg:    AppColors.statusAcknowledgedBg,
                    text:  AppColors.statusAcknowledgedText,
                  ),
                  const SizedBox(width: 8),
                  _StatusCount(
                    label: 'Resolved',
                    count: summary.resolved,
                    bg:    AppColors.statusResolvedBg,
                    text:  AppColors.statusResolvedText,
                  ),
                  const SizedBox(width: 8),
                  _StatusCount(
                    label: 'Escalated',
                    count: summary.escalated,
                    bg:    AppColors.escalationLight,
                    text:  AppColors.escalation,
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

class _StatusCount extends StatelessWidget {
  const _StatusCount({
    required this.label,
    required this.count,
    required this.bg,
    required this.text,
  });

  final String label;
  final int    count;
  final Color  bg;
  final Color  text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:     const EdgeInsets.symmetric(vertical: 10),
        decoration:  BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: AppTextStyles.heading3.copyWith(color: text, fontSize: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(color: text),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}