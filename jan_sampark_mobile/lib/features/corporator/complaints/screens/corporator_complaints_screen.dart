import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/cards/complaint_card.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../providers/corporator_complaint_provider.dart';

/// Corporator complaints screen.
/// Shows all complaints in the corporator's area with
/// tabs for All / Escalated / Pending Resolution.
class CorporatorComplaintsScreen extends ConsumerStatefulWidget {
  const CorporatorComplaintsScreen({super.key});

  @override
  ConsumerState<CorporatorComplaintsScreen> createState() =>
      _CorporatorComplaintsScreenState();
}

class _CorporatorComplaintsScreenState
    extends ConsumerState<CorporatorComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) _onTabChanged();
    });

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref
            .read(corporatorComplaintListProvider.notifier)
            .loadMore();
      }
    });
  }

  void _onTabChanged() {
    final filter = switch (_tabCtrl.index) {
      1 => const CorporatorComplaintFilter(escalatedOnly: true),
      2 => const CorporatorComplaintFilter(
            statusFilter: 'resolved'),
      _ => const CorporatorComplaintFilter(),
    };
    ref
        .read(corporatorComplaintListProvider.notifier)
        .applyFilter(filter);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(corporatorComplaintListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor:        AppColors.appBarWhite,
        elevation:              0,
        scrolledUnderElevation: 0,
        title: Text('Complaints',
            style: AppTextStyles.appBarTitle),
        actions: [
          // Active filter dot
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: _openFilterSheet,
                tooltip: 'Filters',
              ),
              if (state.filter.hasFilters &&
                  _tabCtrl.index == 0)
                const Positioned(
                  right: 8,
                  top:   8,
                  child: CircleAvatar(
                    radius:          4,
                    backgroundColor: AppColors.primary,
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Escalated'),
            Tab(text: 'Resolved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          3,
          (_) => _ComplaintList(
            state:      state,
            scrollCtrl: _scrollCtrl,
            onTap: (id) => context.goNamed(
              RouteNames.corporatorComplaintDetail,
              pathParameters: {'id': id},
            ),
            onRetry: () => ref
                .read(corporatorComplaintListProvider.notifier)
                .load(),
            onClearFilters: () => ref
                .read(corporatorComplaintListProvider.notifier)
                .clearFilters(),
          ),
        ),
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final current = ref.read(corporatorComplaintListProvider).filter;

    final result = await showModalBottomSheet<CorporatorComplaintFilter>(
      context:            context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      builder: (_) => _CorporatorFilterSheet(current: current),
    );

    if (result != null && mounted) {
      ref
          .read(corporatorComplaintListProvider.notifier)
          .applyFilter(result);
    }
  }
}

// ─────────────────────────────────────────────
// List tab content
// ─────────────────────────────────────────────

class _ComplaintList extends StatelessWidget {
  const _ComplaintList({
    required this.state,
    required this.scrollCtrl,
    required this.onTap,
    required this.onRetry,
    required this.onClearFilters,
  });

  final CorporatorComplaintListState state;
  final ScrollController             scrollCtrl;
  final void Function(String)        onTap;
  final VoidCallback                 onRetry;
  final VoidCallback                 onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 140);
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(state.errorMessage,
                style:     AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon:  const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return EmptyStateWidget(
        icon:        Icons.report_problem_outlined,
        title:       'No Complaints Found',
        subtitle:    state.filter.hasFilters
            ? 'No complaints match the selected filters.'
            : 'No complaints in your area yet.',
        actionLabel: state.filter.hasFilters
            ? 'Clear Filters'
            : null,
        onAction:    state.filter.hasFilters
            ? onClearFilters
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: onRetry,
      color:     AppColors.primary,
      child: ListView.separated(
        controller: scrollCtrl,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical:   AppDimensions.pagePaddingTop,
        ),
        itemCount: state.complaints.length +
            (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceMD),
        itemBuilder: (context, i) {
          if (i == state.complaints.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          final c = state.complaints[i];
          return ComplaintCard(
            complaintNumber:  c.complaintNumber,
            title:            c.title,
            categoryName:     c.categoryName,
            status:           c.status,
            priority:         c.priority,
            wardName:         c.wardName,
            areaName:         c.areaName,
            assignedToName:   c.assignedToName,
            isEscalated:      c.isEscalated,
            showAssignee:     true,
            createdAt:        c.createdAt,
            onTap:            () => onTap(c.id),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Filter Sheet
// ─────────────────────────────────────────────

class _CorporatorFilterSheet extends StatefulWidget {
  const _CorporatorFilterSheet({required this.current});
  final CorporatorComplaintFilter current;

  @override
  State<_CorporatorFilterSheet> createState() =>
      _CorporatorFilterSheetState();
}

class _CorporatorFilterSheetState
    extends State<_CorporatorFilterSheet> {
  String? _status;
  String? _priority;
  bool    _escalatedOnly = false;
  String? _assignedToType;

  static const _statusOptions = {
    'pending':      'Pending',
    'acknowledged': 'Acknowledged',
    'in_progress':  'In Progress',
    'resolved':     'Resolved',
    'closed':       'Closed',
    'rejected':     'Rejected',
  };

  static const _priorityOptions = {
    'low':       'Low',
    'medium':    'Medium',
    'high':      'High',
    'emergency': 'Emergency',
  };

  static const _assigneeOptions = {
    'leader':     'Assigned to Leader',
    'corporator': 'Assigned to Me',
  };

  @override
  void initState() {
    super.initState();
    _status         = widget.current.statusFilter;
    _priority       = widget.current.priority;
    _escalatedOnly  = widget.current.escalatedOnly;
    _assignedToType = widget.current.assignedToType;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH,
          AppDimensions.spaceLG,
          AppDimensions.pagePaddingH,
          AppDimensions.spaceXL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color:        AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            Row(
              children: [
                Text('Filter Complaints',
                    style: AppTextStyles.heading3),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    _status         = null;
                    _priority       = null;
                    _escalatedOnly  = false;
                    _assignedToType = null;
                  }),
                  child: const Text('Clear all'),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceXL),

            // Status
            _buildDropdown(
              label: 'Status',
              value: _status,
              options: _statusOptions,
              onChanged: (v) => setState(() => _status = v),
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Priority
            _buildDropdown(
              label: 'Priority',
              value: _priority,
              options: _priorityOptions,
              onChanged: (v) => setState(() => _priority = v),
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Assigned to
            _buildDropdown(
              label: 'Assigned To',
              value: _assignedToType,
              options: _assigneeOptions,
              onChanged: (v) =>
                  setState(() => _assignedToType = v),
            ),

            const SizedBox(height: AppDimensions.spaceXL),

            // Escalated toggle
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color:        AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_outlined,
                      color: AppColors.escalation, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Show escalated only',
                        style: AppTextStyles.bodyMedium),
                  ),
                  Switch(
                    value:     _escalatedOnly,
                    onChanged: (v) =>
                        setState(() => _escalatedOnly = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spaceXXL),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMD),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        CorporatorComplaintFilter(
                          statusFilter:   _status,
                          priority:       _priority,
                          escalatedOnly:  _escalatedOnly,
                          assignedToType: _assignedToType,
                        ),
                      );
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String  label,
    required String? value,
    required Map<String, String> options,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value:     value,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('Any $label',
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.textHint)),
            ),
            ...options.entries.map((e) {
              return DropdownMenuItem<String>(
                value: e.key,
                child: Text(e.value,
                    style: AppTextStyles.body),
              );
            }),
          ],
          onChanged: onChanged,
          icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          dropdownColor: AppColors.white,
          isExpanded:    true,
          decoration: const InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}