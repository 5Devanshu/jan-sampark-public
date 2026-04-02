import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/dialogs/confirm_dialog.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/buttons/secondary_button.dart';
import '../models/corporator_leader_models.dart';
import '../repositories/corporator_leader_repository.dart';
import '../providers/corporator_leader_provider.dart';
import '../widgets/leader_performance_card.dart';
import '../widgets/leader_responsibility_selector.dart';

class CorporatorLeaderDetailScreen extends ConsumerWidget {
  const CorporatorLeaderDetailScreen({
    super.key,
    required this.leaderId,
  });
  final String leaderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async =
        ref.watch(corporatorLeaderDetailProvider(leaderId));

    return async.when(
      loading: () => const AppScaffold(
        title: 'Leader Profile',
        body:  Center(child: CircularProgressIndicator(
            color: AppColors.primary)),
      ),
      error: (e, _) => AppScaffold(
        title: 'Leader Profile',
        body:  EmptyStateWidget(
          icon:        Icons.error_outline_rounded,
          title:       'Failed to load leader',
          subtitle:    e.toString(),
          actionLabel: 'Retry',
          onAction:    () => ref.invalidate(
              corporatorLeaderDetailProvider(leaderId)),
        ),
      ),
      data: (leader) => _LeaderDetailContent(
        leader:   leader,
        leaderId: leaderId,
      ),
    );
  }
}

class _LeaderDetailContent extends ConsumerStatefulWidget {
  const _LeaderDetailContent({
    required this.leader,
    required this.leaderId,
  });

  final CorporatorLeaderDetail leader;
  final String                 leaderId;

  @override
  ConsumerState<_LeaderDetailContent> createState() =>
      _LeaderDetailContentState();
}

class _LeaderDetailContentState
    extends ConsumerState<_LeaderDetailContent> {
  late Set<String> _responsibilities;
  bool _editingResponsibilities = false;

  @override
  void initState() {
    super.initState();
    _responsibilities =
        Set<String>.from(widget.leader.responsibilities);
  }

  void _refresh() {
    ref.invalidate(
        corporatorLeaderDetailProvider(widget.leaderId));
    ref
        .read(corporatorLeaderListProvider.notifier)
        .load();
  }

  Future<void> _toggleActive() async {
    final isActive = widget.leader.isActive;
    final confirmed = await showConfirmDialog(
      context:       context,
      title:         isActive ? 'Deactivate Leader' : 'Activate Leader',
      message:       isActive
          ? 'This leader will lose access to Jan Sampark immediately.'
          : 'This leader will regain full access.',
      confirmLabel:  isActive ? 'Deactivate' : 'Activate',
      isDestructive: isActive,
      icon: isActive
          ? Icons.person_off_outlined
          : Icons.person_outlined,
    );

    if (confirmed != true || !mounted) return;

    final repo = ref.read(corporatorLeaderRepositoryProvider);
    final res  = await repo.toggleActive(
      widget.leaderId,
      isActive: !isActive,
    );

    if (!mounted) return;
    res.when(
      success: (_) {
        context.showSuccess(
          isActive ? 'Leader deactivated.' : 'Leader activated.',
        );
        _refresh();
      },
      error: (e) => context.showError(e.toString()),
    );
  }

  Future<void> _saveResponsibilities() async {
    final success = await ref
        .read(updateResponsibilitiesProvider.notifier)
        .update(
          widget.leaderId,
          responsibilities: _responsibilities.toList(),
        );

    if (!mounted) return;
    if (success) {
      context.showSuccess('Responsibilities updated.');
      setState(() => _editingResponsibilities = false);
      _refresh();
    } else {
      context.showError(ref
          .read(updateResponsibilitiesProvider)
          .errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateState =
        ref.watch(updateResponsibilitiesProvider);
    final leader = widget.leader;

    return AppScaffold(
      title: 'Leader Profile',
      actions: [
        // Toggle active/inactive
        TextButton.icon(
          onPressed: _toggleActive,
          icon: Icon(
            leader.isActive
                ? Icons.person_off_outlined
                : Icons.person_outlined,
            size: 18,
          ),
          label: Text(
            leader.isActive ? 'Deactivate' : 'Activate',
          ),
          style: TextButton.styleFrom(
            foregroundColor: leader.isActive
                ? AppColors.error
                : AppColors.success,
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spaceMD),

            // ── Header card ──────────────────────
            Container(
              width:   double.infinity,
              padding: const EdgeInsets.all(AppDimensions.spaceXL),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width:  64,
                    height: 64,
                    decoration: BoxDecoration(
                      color:  AppColors.white.withOpacity(0.2),
                      shape:  BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        leader.initials,
                        style: AppTextStyles.heading1
                            .copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  Text(leader.fullName,
                      style: AppTextStyles.heading2.copyWith(
                          color: AppColors.white)),
                  const SizedBox(height: 4),
                  Text(leader.mobile,
                      style: AppTextStyles.body.copyWith(
                          color:
                              AppColors.white.withOpacity(0.85))),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: leader.isActive
                          ? AppColors.successLight
                          : AppColors.errorLight,
                      borderRadius:
                          BorderRadius.circular(100),
                    ),
                    child: Text(
                      leader.isActive ? 'Active' : 'Inactive',
                      style: AppTextStyles.captionMedium.copyWith(
                        color: leader.isActive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spaceXL),

            // ── Basic info ───────────────────────
            _InfoCard(leader: leader),

            const SizedBox(height: AppDimensions.spaceMD),

            // ── Performance ──────────────────────
            LeaderPerformanceCard(leader: leader),

            const SizedBox(height: AppDimensions.spaceXL),

            // ── Responsibilities ─────────────────
            Row(
              children: [
                Expanded(
                  child: Text('Responsibilities',
                      style: AppTextStyles.heading3),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _editingResponsibilities =
                        !_editingResponsibilities;
                    if (!_editingResponsibilities) {
                      // Reset on cancel
                      _responsibilities = Set<String>.from(
                          leader.responsibilities);
                    }
                  }),
                  child: Text(_editingResponsibilities
                      ? 'Cancel'
                      : 'Edit'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceMD),

            if (_editingResponsibilities) ...[
              LeaderResponsibilitySelector(
                selected:  _responsibilities,
                onChanged: (updated) =>
                    setState(() => _responsibilities = updated),
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              PrimaryButton(
                label:     'Save Responsibilities',
                isLoading: updateState.isLoading,
                onPressed: _saveResponsibilities,
                height:    AppDimensions.buttonHeightMD,
              ),
            ] else
              _ResponsibilityChips(
                  responsibilities: leader.responsibilities),

            const SizedBox(height: AppDimensions.spaceXXL),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.leader});
  final CorporatorLeaderDetail leader;

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
            icon:  Icons.map_outlined,
            label: 'Ward',
            value: leader.wardName,
          ),
          const Divider(height: 1),
          _Row(
            icon:  Icons.calendar_today_outlined,
            label: 'Added On',
            value: DateFormatter.toDisplayDate(
                leader.createdAt),
          ),
          const Divider(height: 1),
          _Row(
            icon:  Icons.person_outline,
            label: 'Voter Interactions',
            value: '${leader.voterInteractions}',
          ),
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
  });
  final IconData icon;
  final String   label;
  final String   value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 16,
              color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ResponsibilityChips extends StatelessWidget {
  const _ResponsibilityChips({
      required this.responsibilities});
  final List<String> responsibilities;

  @override
  Widget build(BuildContext context) {
    if (responsibilities.isEmpty) {
      return Text(
        'No responsibilities assigned.',
        style: AppTextStyles.bodySecondary,
      );
    }
    return Wrap(
      spacing:    8,
      runSpacing: 8,
      children: responsibilities.map((r) {
        final label =
            kLeaderResponsibilities[r] ?? r;
        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:        AppColors.primaryLight,
            borderRadius: BorderRadius.circular(
                AppDimensions.radiusFull),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded,
                  size: 12, color: AppColors.primary),
              const SizedBox(width: 5),
              Text(label,
                  style: AppTextStyles.captionMedium
                      .copyWith(color: AppColors.primary)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
