import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/ops_colors.dart';
import '../../../core/theme/ops_text_styles.dart';
import '../../../core/theme/ops_dimensions.dart';
import '../../../core/utils/ops_date_formatter.dart';
import '../../../core/utils/ops_extensions.dart';
import '../../../shared/widgets/ops_page_header.dart';
import '../../../shared/widgets/ops_data_table.dart';
import '../../../shared/widgets/ops_empty_state.dart';
import '../models/ops_masters_models.dart';
import '../providers/ops_masters_provider.dart';

class HelplineMasterScreen extends ConsumerStatefulWidget {
  const HelplineMasterScreen({super.key});

  @override
  ConsumerState<HelplineMasterScreen> createState() =>
      _HelplineMasterScreenState();
}

class _HelplineMasterScreenState
    extends ConsumerState<HelplineMasterScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        // Filter by system vs custom on tab change
        ref
            .read(opsHelplineListProvider.notifier)
            .filterBySystem(
              _tabCtrl.index == 0 ? true : false,
            );
      }
    });
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref
            .read(opsHelplineListProvider.notifier)
            .loadMore();
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(opsHelplineListProvider);

    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding:    const EdgeInsets.all(OpsDimensions.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OpsPageHeader(
            title:    'Helpline Numbers',
            subtitle: 'Emergency and service helplines visible to all voters.',
            actions: [
              if (state.total > 0)
                _CountBadge(
                    count: state.total,
                    label: 'numbers'),
              ElevatedButton.icon(
                onPressed: () =>
                    _showCreateDialog(context),
                icon:  const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Number'),
              ),
            ],
          ),

          const SizedBox(height: OpsDimensions.space24),

          // Tabs + search row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: OpsDimensions.buttonHeightMD,
                  decoration: BoxDecoration(
                    color:        OpsColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(
                        OpsDimensions.radiusMD),
                    border: Border.all(
                        color: OpsColors.borderGrey),
                  ),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicatorSize:
                        TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color:        OpsColors.primary,
                      borderRadius: BorderRadius.circular(
                          OpsDimensions.radiusMD - 2),
                    ),
                    labelColor:   OpsColors.white,
                    unselectedLabelColor:
                        OpsColors.textSecondary,
                    labelStyle:   OpsTextStyles.label,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'System'),
                      Tab(text: 'Custom (Area)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: OpsDimensions.space12),
              Expanded(
                flex: 3,
                child: _SearchBar(
                  ctrl:     _searchCtrl,
                  onSearch: (q) => ref
                      .read(opsHelplineListProvider.notifier)
                      .search(q),
                ),
              ),
            ],
          ),

          const SizedBox(height: OpsDimensions.space20),

          // Category chips
          _CategoryChips(
            onSelected: (cat) => ref
                .read(opsHelplineListProvider.notifier)
                .filterByCategory(cat),
          ),

          const SizedBox(height: OpsDimensions.space16),

          if (state.isEmpty && !state.isLoading)
            OpsEmptyState(
              icon:        Icons.phone_outlined,
              title:       'No Helplines Found',
              subtitle:    state.searchQuery.isNotEmpty
                  ? 'No results for "${state.searchQuery}".'
                  : 'Add the first helpline number.',
              actionLabel: 'Add Number',
              onAction:    () => _showCreateDialog(context),
            )
          else
            OpsDataTable(
              isLoading:    state.isLoading,
              skeletonRows: 6,
              columns: const [
                'Name',
                'Number',
                'Category',
                'Area',
                'Type',
                'Created',
                'Status',
                'Actions',
              ],
              emptyMessage: 'No helplines match the filters.',
              rows: state.items.map((h) {
                return OpsTableRow(
                  cells: [
                    h.name,
                    h.number,
                    kHelplineCategories[h.category] ??
                        h.category,
                    h.areaName ?? '—',
                    h.isSystem ? 'System' : 'Custom',
                    OpsDateFormatter.toDate(h.createdAt),
                    h.isActive ? '✓ Active' : '✗ Inactive',
                    '',
                  ],
                  badge: _HelplineRowActions(
                    helpline: h,
                    onEdit:   () =>
                        _showEditDialog(context, h),
                    onToggle: () => _toggleActive(h),
                    onDelete: () =>
                        _confirmDelete(context, h),
                  ),
                );
              }).toList(),
            ),

          if (state.isLoadingMore)
            const _LoadingMore(),

          const SizedBox(height: OpsDimensions.space32),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => _HelplineDialog(
        onSave: (name, number, cat, desc) async {
          final created = await ref
              .read(opsHelplineActionProvider.notifier)
              .create(
                name:        name,
                number:      number,
                category:    cat,
                description: desc,
                isSystem:    true,
              );
          if (created != null && context.mounted) {
            ref
                .read(opsHelplineListProvider.notifier)
                .prepend(created);
            context.showSuccess(
                '"$name" added.');
            Navigator.of(context).pop();
          } else if (context.mounted) {
            context.showError(ref
                .read(opsHelplineActionProvider)
                .errorMessage);
          }
        },
        isSaving:
            ref.read(opsHelplineActionProvider).isLoading,
      ),
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, OpsHelpline h) async {
    await showDialog(
      context: context,
      builder: (_) => _HelplineDialog(
        initial: h,
        onSave: (name, number, cat, desc) async {
          final updated = await ref
              .read(opsHelplineActionProvider.notifier)
              .update(
                h.id,
                name:        name,
                number:      number,
                category:    cat,
                description: desc,
              );
          if (updated != null && context.mounted) {
            ref
                .read(opsHelplineListProvider.notifier)
                .replace(updated);
            context.showSuccess('Helpline updated.');
            Navigator.of(context).pop();
          } else if (context.mounted) {
            context.showError(ref
                .read(opsHelplineActionProvider)
                .errorMessage);
          }
        },
        isSaving:
            ref.read(opsHelplineActionProvider).isLoading,
      ),
    );
  }

  Future<void> _toggleActive(OpsHelpline h) async {
    final newState = !h.isActive;
    ref
        .read(opsHelplineListProvider.notifier)
        .toggleActiveOptimistic(h.id, newState);

    final updated = await ref
        .read(opsHelplineActionProvider.notifier)
        .update(h.id, isActive: newState);

    if (updated == null && mounted) {
      ref
          .read(opsHelplineListProvider.notifier)
          .toggleActiveOptimistic(h.id, h.isActive);
      context.showError(
          ref.read(opsHelplineActionProvider).errorMessage);
    } else if (mounted) {
      context.showSuccess(newState
          ? '"${h.name}" activated.'
          : '"${h.name}" deactivated.');
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, OpsHelpline h) async {
    final confirmed =
        await _showDeleteDialog(context, h.name);
    if (confirmed != true || !mounted) return;

    final ok = await ref
        .read(opsHelplineActionProvider.notifier)
        .delete(h.id);

    if (ok && mounted) {
      ref
          .read(opsHelplineListProvider.notifier)
          .remove(h.id);
      context.showSuccess('"${h.name}" deleted.');
    } else if (mounted) {
      context.showError(
          ref.read(opsHelplineActionProvider).errorMessage);
    }
  }
}

// ─────────────────────────────────────────────
// Category filter chips
// ─────────────────────────────────────────────

class _CategoryChips extends StatefulWidget {
  const _CategoryChips({required this.onSelected});
  final void Function(String?) onSelected;

  @override
  State<_CategoryChips> createState() =>
      _CategoryChipsState();
}

class _CategoryChipsState extends State<_CategoryChips> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label:      'All',
            isSelected: _selected == null,
            onTap: () {
              setState(() => _selected = null);
              widget.onSelected(null);
            },
          ),
          const SizedBox(width: 6),
          ...kHelplineCategories.entries.map((e) => Padding(
                padding: const EdgeInsets.only(
                    right: 6),
                child: _Chip(
                  label:      e.value,
                  isSelected: _selected == e.key,
                  onTap: () {
                    setState(() => _selected = e.key);
                    widget.onSelected(e.key);
                  },
                ),
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String   label;
  final bool     isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? OpsColors.primary
              : OpsColors.surfaceGrey,
          borderRadius:
              BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? OpsColors.primary
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

// ─────────────────────────────────────────────
// Helpline dialog
// ─────────────────────────────────────────────

class _HelplineDialog extends StatefulWidget {
  const _HelplineDialog({
    required this.onSave,
    required this.isSaving,
    this.initial,
  });

  final Future<void> Function(
      String, String, String, String?) onSave;
  final bool          isSaving;
  final OpsHelpline?  initial;

  @override
  State<_HelplineDialog> createState() =>
      _HelplineDialogState();
}

class _HelplineDialogState extends State<_HelplineDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _numberCtrl;
  late final TextEditingController _descCtrl;
  String _category = 'municipal';

  @override
  void initState() {
    super.initState();
    _nameCtrl   = TextEditingController(
        text: widget.initial?.name);
    _numberCtrl = TextEditingController(
        text: widget.initial?.number);
    _descCtrl   = TextEditingController(
        text: widget.initial?.description);
    _category   = widget.initial?.category ?? 'municipal';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return AlertDialog(
      title: Text(isEdit
          ? 'Edit Helpline'
          : 'Add Helpline Number'),
      content: SizedBox(
        width: OpsDimensions.dialogWidthSM,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogLabel('Category'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  style: OpsTextStyles.body,
                  decoration: const InputDecoration(
                      hintText: 'Select category'),
                  isExpanded:    true,
                  dropdownColor: OpsColors.white,
                  icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size:  18,
                      color: OpsColors.textDisabled),
                  items: kHelplineCategories.entries
                      .map((e) => DropdownMenuItem<String>(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (v) => setState(
                      () => _category = v ?? _category),
                ),
              ],
            ),
            const SizedBox(height: OpsDimensions.space16),
            _DialogField(
              label:      'Service Name',
              hint:       'e.g. Mumbai Police',
              controller: _nameCtrl,
              action:     TextInputAction.next,
            ),
            const SizedBox(height: OpsDimensions.space16),
            _DialogField(
              label:      'Phone Number',
              hint:       'e.g. 100 or 1800-123-456',
              controller: _numberCtrl,
              keyboard:   TextInputType.phone,
              action:     TextInputAction.next,
            ),
            const SizedBox(height: OpsDimensions.space16),
            _DialogField(
              label:      'Description (optional)',
              hint:       'e.g. Available 24/7',
              controller: _descCtrl,
              maxLines:   2,
              action:     TextInputAction.done,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: widget.isSaving
              ? null
              : () async {
                  final name   = _nameCtrl.text.trim();
                  final number = _numberCtrl.text.trim();
                  if (name.isEmpty || number.isEmpty) {
                    return;
                  }
                  await widget.onSave(
                    name,
                    number,
                    _category,
                    _descCtrl.text.trim().isEmpty
                        ? null
                        : _descCtrl.text.trim(),
                  );
                },
          child: widget.isSaving
              ? const _SavingIndicator()
              : Text(isEdit
                  ? 'Save Changes'
                  : 'Add Number'),
        ),
      ],
    );
  }
}

class _HelplineRowActions extends StatelessWidget {
  const _HelplineRowActions({
    required this.helpline,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final OpsHelpline  helpline;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconBtn(
            icon:    Icons.edit_outlined,
            tooltip: 'Edit',
            color:   OpsColors.primary,
            onTap:   onEdit),
        const SizedBox(width: 4),
        _IconBtn(
          icon: helpline.isActive
              ? Icons.toggle_on_rounded
              : Icons.toggle_off_rounded,
          tooltip: helpline.isActive
              ? 'Deactivate'
              : 'Activate',
          color: helpline.isActive
              ? OpsColors.success
              : OpsColors.textDisabled,
          onTap: onToggle,
        ),
        const SizedBox(width: 4),
        _IconBtn(
            icon:    Icons.delete_outline_rounded,
            tooltip: 'Delete',
            color:   OpsColors.error,
            onTap:   onDelete),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.count,
    required this.label,
  });

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: OpsColors.primaryLight,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '$count $label',
        style: OpsTextStyles.label.copyWith(color: OpsColors.primary),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.ctrl,
    required this.onSearch,
  });

  final TextEditingController ctrl;
  final void Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      textInputAction: TextInputAction.search,
      onSubmitted: onSearch,
      decoration: const InputDecoration(
        hintText: 'Search...',
        prefixIcon: Icon(Icons.search_rounded),
      ),
    );
  }
}

class _LoadingMore extends StatelessWidget {
  const _LoadingMore();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: OpsDimensions.space16),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

Future<bool?> _showDeleteDialog(BuildContext context, String name) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Item'),
      content: Text('Delete "$name"? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: OpsColors.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

class _DialogLabel extends StatelessWidget {
  const _DialogLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: OpsTextStyles.label);
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.label,
    required this.hint,
    required this.controller,
    this.action = TextInputAction.next,
    this.keyboard,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputAction action;
  final TextInputType? keyboard;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: OpsTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          textInputAction: action,
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _SavingIndicator extends StatelessWidget {
  const _SavingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(OpsColors.white),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
