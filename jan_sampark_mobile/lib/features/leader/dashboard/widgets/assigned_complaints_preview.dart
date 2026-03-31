import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared_widgets/badges/status_badge.dart';
import '../../../../shared_widgets/badges/priority_badge.dart';
import '../../../../shared_widgets/layout/section_header.dart';
import '../../complaints/providers/leader_complaint_provider.dart';

/// Top 5 pending complaints shown on the Leader home screen.
class AssignedComplaintsPreview extends ConsumerWidget {
  const AssignedComplaintsPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaderComplaintListProvider);

    // Show top 5 pending
    final preview = state.complaints
        .where((c) => c.status == 'pending' || c.status == 'acknowledged')
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Ward Complaints',
          actionLabel: 'See all',
          onActionTap: () => context.goNamed(RouteNames.leaderComplaints),
        ),
        const SizedBox(height: AppDimensions.spaceMD),

        if (state.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (state.hasError)
          _ErrorTile(message: state.errorMessage)
        else if (preview.isEmpty)
          _EmptyPreview()
        else
          ...preview.map(
            (c) => _PreviewTile(
              complaint: c,
              onTap: () => context.goNamed(
                RouteNames.leaderComplaintDetail,
                pathParameters: {'id': c.id},
              ),
            ),
          ),
      ],
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.complaint, required this.onTap});

  final ComplaintListItem complaint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
        padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: complaint.isEscalated
                ? AppColors.escalation
                : AppColors.borderGrey,
            width: complaint.isEscalated ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Escalation banner
            if (complaint.isEscalated)
              Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.escalationLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.escalation,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Escalated',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.escalation,
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint.complaintNumber,
                        style: AppTextStyles.codeLabel,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        complaint.title,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: complaint.status, small: true),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                PriorityBadge(priority: complaint.priority),
                const Spacer(),
                Text(
                  DateFormatter.timeAgo(complaint.createdAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceXL),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.success,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No pending complaints in your ward.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}
