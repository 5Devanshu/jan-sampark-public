import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/badges/status_badge.dart';
import '../../../../shared_widgets/badges/priority_badge.dart';
import '../providers/leader_complaint_provider.dart';
import '../repositories/leader_complaint_repository.dart';
import '../widgets/complaint_timeline.dart';
import '../widgets/complaint_action_bar.dart';

class LeaderComplaintDetailScreen extends ConsumerWidget {
  const LeaderComplaintDetailScreen({super.key, required this.complaintId});
  final String complaintId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(leaderComplaintDetailProvider(complaintId));

    return async.when(
      loading: () => const AppScaffold(
        title: 'Complaint',
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => AppScaffold(
        title: 'Complaint',
        body: EmptyStateWidget(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load complaint',
          subtitle: e.toString(),
          actionLabel: 'Retry',
          onAction: () =>
              ref.invalidate(leaderComplaintDetailProvider(complaintId)),
        ),
      ),
      data: (complaint) =>
          _DetailContent(complaint: complaint, complaintId: complaintId),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.complaint, required this.complaintId});

  final ComplaintDetail complaint;
  final String complaintId;

  void _refresh(WidgetRef ref) {
    ref.invalidate(leaderComplaintDetailProvider(complaintId));
    ref.read(leaderComplaintListProvider.notifier).refreshItem(complaintId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: complaint.complaintNumber,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spaceSM),

                  // ── Status + Priority ──────────
                  Row(
                    children: [
                      StatusBadge(status: complaint.status),
                      const SizedBox(width: 8),
                      PriorityBadge(priority: complaint.priority),
                      if (complaint.escalated) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.escalationLight,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 12,
                                color: AppColors.escalation,
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
                      ],
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spaceMD),

                  // ── Title ──────────────────────
                  Text(complaint.title, style: AppTextStyles.heading1),

                  const SizedBox(height: AppDimensions.spaceXS),

                  // ── Category ───────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      complaint.categoryName,
                      style: AppTextStyles.captionMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceXL),

                  // ── Meta info card ─────────────
                  _MetaCard(complaint: complaint),

                  const SizedBox(height: AppDimensions.spaceXL),

                  // ── Description ────────────────
                  Text('Description', style: AppTextStyles.heading3),
                  const SizedBox(height: AppDimensions.spaceSM),
                  Text(
                    complaint.description,
                    style: AppTextStyles.body.copyWith(height: 1.6),
                  ),

                  // ── Images ─────────────────────
                  if (complaint.images.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spaceXL),
                    Text('Attached Photos', style: AppTextStyles.heading3),
                    const SizedBox(height: AppDimensions.spaceMD),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: complaint.images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            complaint.images[i],
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ── Notes ──────────────────────
                  if (complaint.notes.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spaceXL),
                    Text('Field Notes', style: AppTextStyles.heading3),
                    const SizedBox(height: AppDimensions.spaceMD),
                    ...complaint.notes.map((n) => _NoteCard(note: n)),
                  ],

                  // ── Audit trail ────────────────
                  const SizedBox(height: AppDimensions.spaceXL),
                  Text('Activity Timeline', style: AppTextStyles.heading3),
                  const SizedBox(height: AppDimensions.spaceMD),
                  ComplaintTimeline(auditTrail: complaint.auditTrail),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ── Action bar ─────────────────────────
          ComplaintActionBar(
            complaint: complaint,
            onAcknowledge: () => context
                .goNamed(
                  RouteNames.acknowledgeComplaint,
                  pathParameters: {'id': complaintId},
                )
                .then((_) => _refresh(ref)),
            onEscalate: () => context
                .goNamed(
                  RouteNames.escalateComplaint,
                  pathParameters: {'id': complaintId},
                )
                .then((_) => _refresh(ref)),
            onAddNote: () => context
                .goNamed(
                  RouteNames.addComplaintNote,
                  pathParameters: {'id': complaintId},
                )
                .then((_) => _refresh(ref)),
            onReject: () => context
                .goNamed(
                  RouteNames.rejectComplaint,
                  pathParameters: {'id': complaintId},
                )
                .then((_) => _refresh(ref)),
            onMarkInProgress: () async {
              final success = await ref
                  .read(complaintActionProvider.notifier)
                  .markInProgress(complaintId);
              if (success && context.mounted) {
                context.showSuccess('Marked as in progress.');
                _refresh(ref);
              } else if (context.mounted) {
                context.showError(
                  ref.read(complaintActionProvider).errorMessage,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.complaint});
  final ComplaintDetail complaint;

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
          _MetaRow(
            icon: Icons.person_outline,
            label: 'Filed by',
            value: complaint.submittedByVoterName ?? 'Voter',
          ),
          const Divider(height: 1),
          _MetaRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: [
              complaint.wardName,
              complaint.areaName,
            ].where((s) => s != null && s!.isNotEmpty).join(', '),
          ),
          const Divider(height: 1),
          if (complaint.assignedToName != null) ...[
            _MetaRow(
              icon: Icons.assignment_ind_outlined,
              label: 'Assigned to',
              value: complaint.assignedToName!,
            ),
            const Divider(height: 1),
          ],
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            label: 'Filed on',
            value: DateFormatter.toDisplayDateTime(complaint.createdAt),
          ),
          if (complaint.escalated && complaint.escalationReason != null) ...[
            const Divider(height: 1),
            _MetaRow(
              icon: Icons.warning_amber_outlined,
              label: 'Escalation reason',
              value: complaint.escalationReason!,
              valueColor: AppColors.escalation,
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});
  final ComplaintNote note;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: note.isInternal ? AppColors.warningLight : AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: note.isInternal
              ? AppColors.warningBorder
              : AppColors.borderGrey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (note.isInternal)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warningBorder.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Internal',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              Expanded(
                child: Text(note.addedByName, style: AppTextStyles.bodyMedium),
              ),
              Text(
                DateFormatter.timeAgo(note.timestamp),
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(note.noteText, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
