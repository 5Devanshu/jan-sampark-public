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
import '../../../leader/complaints/repositories/leader_complaint_repository.dart';
import '../../../leader/complaints/widgets/complaint_timeline.dart';
import '../providers/corporator_complaint_provider.dart';
import '../widgets/corporator_complaint_action_bar.dart';
import '../../../leader/complaints/repositories/leader_complaint_repository.dart';

class CorporatorComplaintDetailScreen extends ConsumerWidget {
  const CorporatorComplaintDetailScreen({
    super.key,
    required this.complaintId,
  });
  final String complaintId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
        corporatorComplaintDetailProvider(complaintId));

    return async.when(
      loading: () => const AppScaffold(
        title: 'Complaint',
        body:  Center(child: CircularProgressIndicator(
            color: AppColors.primary)),
      ),
      error: (e, _) => AppScaffold(
        title: 'Complaint',
        body:  EmptyStateWidget(
          icon:        Icons.error_outline_rounded,
          title:       'Failed to load complaint',
          subtitle:    e.toString(),
          actionLabel: 'Retry',
          onAction:    () => ref.invalidate(
              corporatorComplaintDetailProvider(complaintId)),
        ),
      ),
      data: (complaint) => _DetailContent(
        complaint:   complaint,
        complaintId: complaintId,
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({
    required this.complaint,
    required this.complaintId,
  });

  final ComplaintDetail complaint;
  final String          complaintId;

  void _refresh(WidgetRef ref) {
    ref.invalidate(
        corporatorComplaintDetailProvider(complaintId));
    ref
        .read(corporatorComplaintListProvider.notifier)
        .load();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: complaint.complaintNumber,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                  AppDimensions.pagePaddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.spaceSM),

                  // ── Status row ─────────────────
                  Wrap(
                    spacing:    8,
                    runSpacing: 6,
                    children: [
                      StatusBadge(status: complaint.status),
                      PriorityBadge(priority: complaint.priority),
                      if (complaint.escalated)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.escalationLight,
                            borderRadius:
                                BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size:  12,
                                color: AppColors.escalation,
                              ),
                              const SizedBox(width: 4),
                              Text('Escalated',
                                  style: AppTextStyles.labelSmall
                                      .copyWith(
                                          color: AppColors
                                              .escalation)),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spaceMD),

                  // ── Title + Category ───────────
                  Text(complaint.title,
                      style: AppTextStyles.heading1),
                  const SizedBox(height: AppDimensions.spaceXS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:        AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(complaint.categoryName,
                        style: AppTextStyles.captionMedium
                            .copyWith(color: AppColors.primary)),
                  ),

                  const SizedBox(height: AppDimensions.spaceXL),

                  // ── Meta card ──────────────────
                  _MetaCard(complaint: complaint),

                  const SizedBox(height: AppDimensions.spaceXL),

                  // ── Description ────────────────
                  Text('Description',
                      style: AppTextStyles.heading3),
                  const SizedBox(height: AppDimensions.spaceSM),
                  Text(complaint.description,
                      style: AppTextStyles.body.copyWith(
                          height: 1.6)),

                  // ── Complaint images ───────────
                  if (complaint.images.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spaceXL),
                    Text('Attached Photos',
                        style: AppTextStyles.heading3),
                    const SizedBox(height: AppDimensions.spaceMD),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            complaint.images.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 10),
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () =>
                              _viewImage(context,
                                  complaint.images[i]),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(8),
                            child: Image.network(
                              complaint.images[i],
                              width:  110,
                              height: 110,
                              fit:    BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ── Resolution notes (if resolved) ─
                  if (complaint.resolutionNotes != null &&
                      complaint.resolutionNotes!.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spaceXL),
                    Container(
                      padding: const EdgeInsets.all(
                          AppDimensions.spaceMD),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMD),
                        border: Border.all(
                            color: AppColors.successBorder),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: AppColors.success,
                                size:  16,
                              ),
                              const SizedBox(width: 8),
                              Text('Resolution Notes',
                                  style: AppTextStyles
                                      .bodyMedium
                                      .copyWith(
                                          color:
                                              AppColors.success)),
                            ],
                          ),
                          const SizedBox(
                              height: AppDimensions.spaceSM),
                          Text(
                            complaint.resolutionNotes!,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.success,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Field notes ────────────────
                  if (complaint.notes.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spaceXL),
                    Text('Field Notes',
                        style: AppTextStyles.heading3),
                    const SizedBox(height: AppDimensions.spaceMD),
                    ...complaint.notes.map((n) => _NoteCard(note: n)),
                  ],

                  // ── Timeline ───────────────────
                  const SizedBox(height: AppDimensions.spaceXL),
                  Text('Activity Timeline',
                      style: AppTextStyles.heading3),
                  const SizedBox(height: AppDimensions.spaceMD),
                  ComplaintTimeline(
                      auditTrail: complaint.auditTrail),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ── Action bar ─────────────────────────
          CorporatorComplaintActionBar(
            complaint:   complaint,
            onResolve: () => context.pushNamed(
              RouteNames.resolveComplaint,
              pathParameters: {'id': complaintId},
            ).then((_) => _refresh(ref)),
            onReject: () => context.pushNamed(
              RouteNames.rejectComplaint,
              pathParameters: {'id': complaintId},
            ).then((_) => _refresh(ref)),
            onReassign: () => context.pushNamed(
              RouteNames.reassignComplaint,
              pathParameters: {'id': complaintId},
            ).then((_) => _refresh(ref)),
            onClose: () async {
              final success = await ref
                  .read(corporatorComplaintActionProvider
                      .notifier)
                  .close(complaintId);
              if (success && context.mounted) {
                context.showSuccess('Complaint closed.');
                _refresh(ref);
              } else if (context.mounted) {
                context.showError(ref
                    .read(corporatorComplaintActionProvider)
                    .errorMessage);
              }
            },
            onAddNote: () async {
              final text =
                  await _showNoteInput(context);
              if (text != null && text.isNotEmpty) {
                final success = await ref
                    .read(corporatorComplaintActionProvider
                        .notifier)
                    .addNote(complaintId, noteText: text);
                if (success && context.mounted) {
                  context.showSuccess('Note added.');
                  _refresh(ref);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _showNoteInput(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: ctrl,
          maxLines:   4,
          decoration: const InputDecoration(
            hintText: 'Enter your note here...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _viewImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(url),
          ),
        ),
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
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        children: [
          _Row(
            icon:  Icons.person_outline,
            label: 'Filed by',
            value: complaint.submittedByVoterName ?? 'Voter',
          ),
          const Divider(height: 1),
          _Row(
            icon:  Icons.location_on_outlined,
            label: 'Location',
            value: [complaint.wardName, complaint.areaName]
                .where((s) => s != null && s!.isNotEmpty)
                .join(', '),
          ),
          if (complaint.assignedToName != null) ...[
            const Divider(height: 1),
            _Row(
              icon:  Icons.assignment_ind_outlined,
              label: 'Assigned to',
              value: complaint.assignedToName!,
            ),
          ],
          const Divider(height: 1),
          _Row(
            icon:  Icons.calendar_today_outlined,
            label: 'Filed on',
            value: DateFormatter.toDisplayDateTime(
                complaint.createdAt),
          ),
          if (complaint.escalated &&
              complaint.escalationReason != null) ...[
            const Divider(height: 1),
            _Row(
              icon:       Icons.warning_amber_outlined,
              label:      'Escalation reason',
              value:      complaint.escalationReason!,
              valueColor: AppColors.escalation,
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String   label;
  final String   value;
  final Color?   valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16,
              color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: valueColor),
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
      margin: const EdgeInsets.only(
          bottom: AppDimensions.spaceMD),
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: note.isInternal
            ? AppColors.warningLight
            : AppColors.surfaceGrey,
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
                      horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warningBorder
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Internal',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.warning)),
                ),
              Expanded(
                child: Text(note.addedByName,
                    style: AppTextStyles.bodyMedium),
              ),
              Text(DateFormatter.timeAgo(note.timestamp),
                  style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 6),
          Text(note.noteText,
              style: AppTextStyles.body),
        ],
      ),
    );
  }
}
