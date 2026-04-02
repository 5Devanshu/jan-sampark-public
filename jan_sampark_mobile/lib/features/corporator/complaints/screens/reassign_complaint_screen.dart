import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../providers/corporator_complaint_provider.dart';

// ─────────────────────────────────────────────
// Leaders for reassign (lightweight list)
// ─────────────────────────────────────────────

class _LeaderOption {
  const _LeaderOption({
    required this.id,
    required this.fullName,
    required this.wardName,
  });
  final String id;
  final String fullName;
  final String wardName;

  factory _LeaderOption.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>? ?? {};
    return _LeaderOption(
      id:       json['id']        as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      wardName: loc['ward_name']  as String? ?? '',
    );
  }
}

final _leadersForReassignProvider =
    FutureProvider.autoDispose<List<_LeaderOption>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(
    AppConstants.endpointUsers,
    queryParameters: {'role': 'leader', 'page_size': 100},
  );
  final data = res.data as Map<String, dynamic>;
  return (data['data'] as List<dynamic>? ?? [])
      .map((e) =>
          _LeaderOption.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

class ReassignComplaintScreen extends ConsumerStatefulWidget {
  const ReassignComplaintScreen({
    super.key,
    required this.complaintId,
  });
  final String complaintId;

  @override
  ConsumerState<ReassignComplaintScreen> createState() =>
      _ReassignComplaintScreenState();
}

class _ReassignComplaintScreenState
    extends ConsumerState<ReassignComplaintScreen> {
  String? _selectedLeaderId;

  Future<void> _onSubmit() async {
    if (_selectedLeaderId == null) {
      context.showError('Please select a leader to reassign to.');
      return;
    }

    final success = await ref
        .read(corporatorComplaintActionProvider.notifier)
        .reassign(
          widget.complaintId,
          leaderId: _selectedLeaderId!,
        );

    if (!mounted) return;
    if (success) {
      context.showSuccess('Complaint reassigned successfully.');
      context.pop();
    } else {
      context.showError(ref
          .read(corporatorComplaintActionProvider)
          .errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadersAsync =
        ref.watch(_leadersForReassignProvider);
    final actionState =
        ref.watch(corporatorComplaintActionProvider);

    return AppScaffold(
      title:       'Reassign Complaint',
      isBlueAppBar: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: leadersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary),
              ),
              error: (e, _) => EmptyStateWidget(
                icon:        Icons.error_outline_rounded,
                title:       'Could not load leaders',
                subtitle:    e.toString(),
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(
                    _leadersForReassignProvider),
              ),
              data: (leaders) {
                if (leaders.isEmpty) {
                  return const EmptyStateWidget(
                    icon:     Icons.people_outline,
                    title:    'No Leaders Found',
                    subtitle: 'No active leaders in your area.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.pagePaddingH,
                        AppDimensions.spaceXL,
                        AppDimensions.pagePaddingH,
                        AppDimensions.spaceMD,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('Select Leader',
                              style: AppTextStyles.heading3),
                          const SizedBox(
                              height: AppDimensions.spaceSM),
                          Text(
                            'Choose the leader in whose ward '
                            'this complaint falls.',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.pagePaddingH,
                          vertical:   AppDimensions.spaceSM,
                        ),
                        itemCount: leaders.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(
                                height: AppDimensions.spaceSM),
                        itemBuilder: (_, i) {
                          final l        = leaders[i];
                          final isSelected =
                              l.id == _selectedLeaderId;

                          return GestureDetector(
                            onTap: () => setState(() =>
                                _selectedLeaderId = l.id),
                            child: AnimatedContainer(
                              duration: const Duration(
                                  milliseconds: 150),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryLight
                                    : AppColors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                        AppDimensions.cardRadius),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.borderGrey,
                                  width:
                                      isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width:  40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors
                                              .primaryLight,
                                      borderRadius:
                                          BorderRadius.circular(
                                              10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        l.fullName.isNotEmpty
                                            ? l.fullName[0]
                                                .toUpperCase()
                                            : '?',
                                        style: AppTextStyles
                                            .bodyMedium
                                            .copyWith(
                                          color: isSelected
                                              ? AppColors.white
                                              : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(l.fullName,
                                            style: AppTextStyles
                                                .bodyMedium),
                                        Text(l.wardName,
                                            style: AppTextStyles
                                                .caption),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size:  20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Submit bar ────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.pagePaddingH,
              AppDimensions.spaceMD,
              AppDimensions.pagePaddingH,
              AppDimensions.spaceMD +
                  MediaQuery.paddingOf(context).bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                  top: BorderSide(color: AppColors.borderGrey)),
            ),
            child: PrimaryButton(
              label:     'Reassign Complaint',
              icon:      Icons.swap_horiz_rounded,
              isLoading: actionState.isLoading,
              isDisabled: _selectedLeaderId == null,
              onPressed: _onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}