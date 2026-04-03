import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/ops_colors.dart';
import '../../../core/theme/ops_text_styles.dart';
import '../../../core/theme/ops_dimensions.dart';
import '../../../core/utils/ops_date_formatter.dart';
import '../../../shared/widgets/ops_page_header.dart';
import '../../../shared/widgets/ops_data_table.dart';
import '../../../shared/widgets/ops_empty_state.dart';
import '../../../features/corporators/providers/ops_corporator_provider.dart';
import '../models/ops_complaint_models.dart';
import '../providers/ops_complaint_provider.dart';

class OpsComplaintsScreen extends ConsumerStatefulWidget {
  const OpsComplaintsScreen({super.key});

  @override
  ConsumerState<OpsComplaintsScreen> createState() =>
      _OpsComplaintsScreenState();
}

class _OpsComplaintsScreenState
    extends ConsumerState<OpsComplaintsScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref
            .read(opsComplaintListProvider.notifier)
            .loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(opsComplaintListProvider);

    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(
          OpsDimensions.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page header ──────────────────────────
          OpsPageHeader(
            title:    'Complaint Oversight',
            subtitle: 'Read-only view of all complaints '
                'across the platform.',
            actions: [
              if (state.escalatedCount > 0)
                _AlertChip(
                  icon:  Icons.warning_amber_rounded,
                  label: '${state.escalatedCount} escalated',
                  color: OpsColors.error,
                ),
              if (state.pendingCount > 0)
                _AlertChip(
                  icon:  Icons.schedule_rounded,
                  label: '${state.pendingCount} pending',
                  color: OpsColors.warning,
                ),
              if (state.total > 0)
                _AlertChip(
                  icon:  Icons.receipt_long_outlined,
                  label: '${state.total} total',
                  color: OpsColors.primary,
                ),
            ],
          ),

          const SizedBox(height: OpsDimensions.space24),

          // ── Filter bar ───────────────────────────
          _FilterBar(
            searchCtrl:   _searchCtrl,
            filter:       state.filter,
            onSearch: (q) => ref
                .read(opsComplaintListProvider.notifier)
                .search(q),
            onFilterChanged: (f) => ref
                .read(opsComplaintListProvider.notifier)
                .applyFilter(f),
            onClearAll: () {
              _searchCtrl.clear();
              ref
                  .read(opsComplaintListProvider.notifier)
                  .clearFilters();
            },
          ),

          const SizedBox(height: OpsDimensions.space20),

          // ── Quick filter chips ────────────────────
          _QuickFilters(
            filter: state.filter,
            onChanged: (f) => ref
                .read(opsComplaintListProvider.notifier)
                .applyFilter(f),
          ),

          const SizedBox(height: OpsDimensions.space16),

          // ── Read-only notice ─────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: OpsColors.infoLight,
              borderRadius: BorderRadius.circular(
                  OpsDimensions.radiusMD),
              border: Border.all(color: OpsColors.infoBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: OpsColors.info, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Complaint management is handled by '
                    'Corporators and Leaders. '
                    'This view is read-only for Ops.',
                    style: OpsTextStyles.caption.copyWith(
                        color: OpsColors.info),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: OpsDimensions.space16),

          // ── Table ────────────────────────────────
          if (state.isEmpty && !state.isLoading)
            OpsEmptyState(
              icon:     Icons.report_problem_outlined,
              title:    'No Complaints Found',
              subtitle: state.filter.hasFilters
                  ? 'No results for the applied filters.'
                  : 'No complaints across the platform.',
              actionLabel: state.filter.hasFilters
                  ? 'Clear Filters'
                  : null,
              onAction: state.filter.hasFilters
                  ? () {
                      _searchCtrl.clear();
                      ref
                          .read(opsComplaintListProvider
                              .notifier)
                          .clearFilters();
                    }
                  : null,
            )
          else
            OpsDataTable(
              isLoading:    state.isLoading,
              skeletonRows: 8,
              columns: const [
                'Number',
                'Title',
                'Category',
                'Area',
                'Ward',
                'Priority',
                'Status',
                'Assigned To',
                'Filed',
              ],
              emptyMessage:
                  'No complaints match the filters.',
              rows: state.complaints.map((c) {
                return OpsTableRow(
                  cells: [
                    c.complaintNumber,
                    c.title.length > 35
                        ? '${c.title.substring(0, 35)}…'
                        : c.title,
                    c.categoryName,
                    c.areaName,
                    c.wardName,
                    _priorityPrefix(c.priority),
                    _statusPrefix(c.status),
                    c.assignedToName ?? '—',
                    OpsDateFormatter.toDate(c.createdAt),
                  ],
                  badge: c.isEscalated
                      ? const _EscalatedBadge()
                      : null,
                );
              }).toList(),
            ),

          // ── Load more ────────────────────────────
          if (state.isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(
                  vertical: OpsDimensions.space24),
              child: Center(
                child: SizedBox(
                  width:  24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color:       OpsColors.primary,
                  ),
                ),
              ),
            ),

          const SizedBox(height: OpsDimensions.space32),
        ],
      ),
    );
  }

  String _priorityPrefix(String priority) {
    return switch (priority) {
      'emergency' => '🔴 Emergency',
      'high'      => '🟠 High',
      'medium'    => '🟡 Medium',
      'low'       => '🟢 Low',
      _           => priority,
    };
  }

  String _statusPrefix(String status) {
    return switch (status) {
      'pending'      => '⚠ Pending',
      'acknowledged' => 'Acknowledged',
      'in_progress'  => 'In Progress',
      'escalated'    => '⚠ Escalated',
      'resolved'     => '✓ Resolved',
      'rejected'     => '✗ Rejected',
      'closed'       => '✓ Closed',
      _              => status,
    };
  }
}

// ─────────────────────────────────────────────
// Alert chip (header)
// ─────────────────────────────────────────────

class _AlertChip extends StatelessWidget {
  const _AlertChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String   label;
  final Color    color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(OpsDimensions.radiusMD),
        border: Border.all(
            color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: OpsTextStyles.caption.copyWith(
              color:      color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Escalated badge (row)
// ─────────────────────────────────────────────

class _EscalatedBadge extends StatelessWidget {
  const _EscalatedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: OpsColors.errorLight,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
            color: OpsColors.errorBorder),
      ),
      child: Text(
        '⚠ Esc',
        style: OpsTextStyles.labelSmall.copyWith(
            color: OpsColors.error),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Filter bar
// ─────────────────────────────────────────────

class _FilterBar extends ConsumerWidget {
  const _FilterBar({
    required this.searchCtrl,
    required this.filter,
    required this.onSearch,
    required this.onFilterChanged,
    required this.onClearAll,
  });

  final TextEditingController         searchCtrl;
  final OpsComplaintFilter            filter;
  final void Function(String)         onSearch;
  final void Function(OpsComplaintFilter) onFilterChanged;
  final VoidCallback                  onClearAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(opsAreaOptionsProvider);

    return Wrap(
      spacing:    OpsDimensions.space12,
      runSpacing: OpsDimensions.space12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Search
        SizedBox(
          width:  300,
          height: OpsDimensions.inputHeight,
          child: TextField(
            controller: searchCtrl,
            style:      OpsTextStyles.body,
            decoration: InputDecoration(
              hintText:   'Search complaints...',
              prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 16,
                  color: OpsColors.textDisabled),
              suffixIcon: searchCtrl.text.isNotEmpty
                  ? GestureDetector(
                      onTap: onClearAll,
                      child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: OpsColors.textDisabled),
                    )
                  : null,
            ),
            onChanged: onSearch,
          ),
        ),

        // Status
        _FilterDropdown<String>(
          value:  filter.status,
          hint:   'All Statuses',
          items: [
            const DropdownMenuItem<String>(
                value: null, child: Text('All Statuses')),
            ...kOpsComplaintStatuses.entries.map((e) =>
                DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(e.value))),
          ],
          onChanged: (v) => onFilterChanged(
            filter.copyWith(
                status:      v,
                clearStatus: v == null),
          ),
        ),

        // Priority
        _FilterDropdown<String>(
          value:  filter.priority,
          hint:   'All Priorities',
          items: [
            const DropdownMenuItem<String>(
                value: null,
                child: Text('All Priorities')),
            ...kOpsComplaintPriorities.entries.map((e) =>
                DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(e.value))),
          ],
          onChanged: (v) => onFilterChanged(
            filter.copyWith(
                priority:     v,
                clearPriority: v == null),
          ),
        ),

        // Area
        areasAsync.when(
          loading: () => const SizedBox(
              width: 160, child: LinearProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (areas) => _FilterDropdown<String>(
            value: filter.areaId,
            hint:  'All Areas',
            items: [
              const DropdownMenuItem<String>(
                  value: null, child: Text('All Areas')),
              ...areas.map((a) => DropdownMenuItem<String>(
                    value: a.id,
                    child: Text(a.areaName,
                        overflow: TextOverflow.ellipsis),
                  )),
            ],
            onChanged: (v) => onFilterChanged(
              filter.copyWith(
                  areaId:    v,
                  clearArea: v == null),
            ),
          ),
        ),

        // Clear
        if (filter.hasFilters)
          TextButton.icon(
            onPressed: onClearAll,
            icon:  const Icon(
                Icons.filter_list_off_rounded,
                size: 14),
            label: const Text('Clear'),
          ),
      ],
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });
  final T?                         value;
  final String                     hint;
  final List<DropdownMenuItem<T>>  items;
  final void Function(T?)          onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  160,
      height: OpsDimensions.inputHeight,
      child: DropdownButtonFormField<T>(
        value: value,
        style: OpsTextStyles.body,
        decoration: InputDecoration(
            hintText: hint, isDense: true),
        isExpanded:    true,
        dropdownColor: OpsColors.white,
        icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: OpsColors.textDisabled),
        items:     items,
        onChanged: onChanged,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quick filter chips
// ─────────────────────────────────────────────

class _QuickFilters extends StatelessWidget {
  const _QuickFilters({
    required this.filter,
    required this.onChanged,
  });
  final OpsComplaintFilter                 filter;
  final void Function(OpsComplaintFilter)  onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickChip(
            label:      'All',
            isSelected: !filter.hasFilters,
            onTap: () => onChanged(
                const OpsComplaintFilter()),
          ),
          const SizedBox(width: 6),
          _QuickChip(
            label:      '⚠ Escalated',
            isSelected: filter.escalatedOnly,
            color:      OpsColors.error,
            onTap: () => onChanged(filter.copyWith(
              escalatedOnly: !filter.escalatedOnly)),
          ),
          const SizedBox(width: 6),
          _QuickChip(
            label:      'Pending',
            isSelected: filter.status == 'pending',
            color:      OpsColors.warning,
            onTap: () => onChanged(filter.copyWith(
              status: filter.status == 'pending'
                  ? null : 'pending',
              clearStatus: filter.status == 'pending',
            )),
          ),
          const SizedBox(width: 6),
          _QuickChip(
            label:      'Emergency',
            isSelected: filter.priority == 'emergency',
            color:      OpsColors.error,
            onTap: () => onChanged(filter.copyWith(
              priority: filter.priority == 'emergency'
                  ? null : 'emergency',
              clearPriority:
                  filter.priority == 'emergency',
            )),
          ),
          const SizedBox(width: 6),
          _QuickChip(
            label:      'In Progress',
            isSelected: filter.status == 'in_progress',
            color:      OpsColors.primary,
            onTap: () => onChanged(filter.copyWith(
              status: filter.status == 'in_progress'
                  ? null : 'in_progress',
              clearStatus:
                  filter.status == 'in_progress',
            )),
          ),
          const SizedBox(width: 6),
          _QuickChip(
            label:      'Resolved',
            isSelected: filter.status == 'resolved',
            color:      OpsColors.success,
            onTap: () => onChanged(filter.copyWith(
              status: filter.status == 'resolved'
                  ? null : 'resolved',
              clearStatus: filter.status == 'resolved',
            )),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });
  final String   label;
  final bool     isSelected;
  final VoidCallback onTap;
  final Color?   color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? OpsColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? c
              : OpsColors.surfaceGrey,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? c
                : OpsColors.borderGrey,
          ),
        ),
        child: Text(
          label,
          style: OpsTextStyles.caption.copyWith(
            color: isSelected
                ? OpsColors.white
                : OpsColors.textSecondary,
            fontWeight: isSelected
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}