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
import '../../../features/corporators/models/ops_corporator_models.dart';
import '../../../features/corporators/providers/ops_corporator_provider.dart';
import '../models/ops_masters_models.dart';
import '../providers/ops_masters_provider.dart';

class WardsScreen extends ConsumerStatefulWidget {
  const WardsScreen({super.key});

  @override
  ConsumerState<WardsScreen> createState() =>
      _WardsScreenState();
}

class _WardsScreenState extends ConsumerState<WardsScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _areaFilter;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(opsWardListProvider.notifier).loadMore();
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
    final state      = ref.watch(opsWardListProvider);
    final areasAsync = ref.watch(opsAreaOptionsProvider);

    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding:    const EdgeInsets.all(OpsDimensions.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OpsPageHeader(
            title:    'Wards',
            subtitle: 'Electoral wards within each area.',
            actions: [
              if (state.total > 0)
                _CountBadge(count: state.total, label: 'wards'),
              ElevatedButton.icon(
                onPressed: () =>
                    _showCreateDialog(context),
                icon:  const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Ward'),
              ),
            ],
          ),

          const SizedBox(height: OpsDimensions.space24),

          // Filter row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _SearchBar(
                  ctrl:     _searchCtrl,
                  onSearch: (q) => ref
                      .read(opsWardListProvider.notifier)
                      .search(q),
                ),
              ),
              const SizedBox(width: OpsDimensions.space12),
              Expanded(
                flex: 2,
                child: areasAsync.when(
                  loading: () =>
                      const LinearProgressIndicator(),
                  error:   (_, __) =>
                      const SizedBox.shrink(),
                  data: (areas) =>
                      _AreaDropdown(
                    value:    _areaFilter,
                    areas:    areas,
                    onChanged: (id) {
                      setState(() => _areaFilter = id);
                      ref
                          .read(opsWardListProvider.notifier)
                          .filterByArea(id);
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: OpsDimensions.space20),

          if (state.isEmpty && !state.isLoading)
            OpsEmptyState(
              icon:        Icons.map_outlined,
              title:       'No Wards Found',
              subtitle:    state.searchQuery.isNotEmpty
                  ? 'No results for "${state.searchQuery}".'
                  : 'Add the first ward.',
              actionLabel: 'Add Ward',
              onAction:    () => _showCreateDialog(context),
            )
          else
            OpsDataTable(
              isLoading:    state.isLoading,
              skeletonRows: 6,
              columns: const [
                'Ward Name',
                'Code',
                'Area',
                'Voters',
                'Leaders',
                'Created',
                'Status',
                'Actions',
              ],
              emptyMessage: 'No wards match the filters.',
              rows: state.items.map((w) {
                return OpsTableRow(
                  cells: [
                    w.wardName,
                    w.wardCode,
                    w.areaName,
                    w.votersCount.compact,
                    '${w.leadersCount}',
                    OpsDateFormatter.toDate(w.createdAt),
                    w.isActive ? '✓ Active' : '✗ Inactive',
                    '',
                  ],
                  badge: _WardRowActions(
                    ward:     w,
                    onEdit:   () => _showEditDialog(context, w),
                    onToggle: () => _toggleActive(w),
                    onDelete: () => _confirmDelete(context, w),
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
    final areasAsync = ref.read(opsAreaOptionsProvider);
    final areas = areasAsync.maybeWhen(
        data: (d) => d, orElse: () => <OpsAreaOption>[]);

    await showDialog(
      context: context,
      builder: (_) => _WardDialog(
        areas:   areas,
        onSave: (name, code, areaId, desc) async {
          final created = await ref
              .read(opsWardActionProvider.notifier)
              .create(
                wardName:    name,
                wardCode:    code,
                areaId:      areaId,
                description: desc,
              );
          if (created != null && context.mounted) {
            ref
                .read(opsWardListProvider.notifier)
                .prepend(created);
            context
                .showSuccess('Ward "$name" created.');
            Navigator.of(context).pop();
          } else if (context.mounted) {
            context.showError(ref
                .read(opsWardActionProvider)
                .errorMessage);
          }
        },
        isSaving: ref.read(opsWardActionProvider).isLoading,
      ),
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, OpsWard ward) async {
    final areasAsync = ref.read(opsAreaOptionsProvider);
    final areas = areasAsync.maybeWhen(
        data: (d) => d, orElse: () => <OpsAreaOption>[]);

    await showDialog(
      context: context,
      builder: (_) => _WardDialog(
        initial: ward,
        areas:   areas,
        onSave: (name, code, areaId, desc) async {
          final updated = await ref
              .read(opsWardActionProvider.notifier)
              .update(
                ward.id,
                wardName:    name,
                wardCode:    code,
                description: desc,
              );
          if (updated != null && context.mounted) {
            ref
                .read(opsWardListProvider.notifier)
                .replace(updated);
            context.showSuccess('Ward updated.');
            Navigator.of(context).pop();
          } else if (context.mounted) {
            context.showError(ref
                .read(opsWardActionProvider)
                .errorMessage);
          }
        },
        isSaving: ref.read(opsWardActionProvider).isLoading,
      ),
    );
  }

  Future<void> _toggleActive(OpsWard ward) async {
    final newState = !ward.isActive;
    ref
        .read(opsWardListProvider.notifier)
        .toggleActiveOptimistic(ward.id, newState);

    final updated = await ref
        .read(opsWardActionProvider.notifier)
        .update(ward.id, isActive: newState);

    if (updated == null && mounted) {
      ref
          .read(opsWardListProvider.notifier)
          .toggleActiveOptimistic(ward.id, ward.isActive);
      context.showError(
          ref.read(opsWardActionProvider).errorMessage);
    } else if (mounted) {
      context.showSuccess(newState
          ? '${ward.wardName} activated.'
          : '${ward.wardName} deactivated.');
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, OpsWard ward) async {
    if (ward.votersCount > 0) {
      context.showError(
        'Cannot delete "${ward.wardName}" — '
        '${ward.votersCount} voter'
        '${ward.votersCount == 1 ? '' : 's'} registered here.',
      );
      return;
    }

    final confirmed =
        await _showDeleteDialog(context, ward.wardName);
    if (confirmed != true || !mounted) return;

    final ok = await ref
        .read(opsWardActionProvider.notifier)
        .delete(ward.id);

    if (ok && mounted) {
      ref
          .read(opsWardListProvider.notifier)
          .remove(ward.id);
      context.showSuccess('"${ward.wardName}" deleted.');
    } else if (mounted) {
      context.showError(
          ref.read(opsWardActionProvider).errorMessage);
    }
  }
}

// ─────────────────────────────────────────────
// Ward dialog
// ─────────────────────────────────────────────

class _WardDialog extends StatefulWidget {
  const _WardDialog({
    required this.areas,
    required this.onSave,
    required this.isSaving,
    this.initial,
  });

  final List<OpsAreaOption>               areas;
  final Future<void> Function(
      String, String, String, String?) onSave;
  final bool                             isSaving;
  final OpsWard?                         initial;

  @override
  State<_WardDialog> createState() => _WardDialogState();
}

class _WardDialogState extends State<_WardDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _descCtrl;
  String? _areaId;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
        text: widget.initial?.wardName);
    _codeCtrl = TextEditingController(
        text: widget.initial?.wardCode);
    _descCtrl = TextEditingController(
        text: widget.initial?.description);
    _areaId   = widget.initial?.areaId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Ward' : 'Add Ward'),
      content: SizedBox(
        width: OpsDimensions.dialogWidthSM,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Area (locked in edit mode)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogLabel('Area'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _areaId,
                  style: OpsTextStyles.body,
                  decoration: const InputDecoration(
                      hintText: 'Select area'),
                  isExpanded:    true,
                  dropdownColor: OpsColors.white,
                  icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size:  18,
                      color: OpsColors.textDisabled),
                  items: widget.areas
                      .map((a) => DropdownMenuItem<String>(
                            value: a.id,
                            child: Text(a.displayName,
                                overflow:
                                    TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: isEdit
                      ? null
                      : (v) =>
                          setState(() => _areaId = v),
                ),
              ],
            ),
            const SizedBox(height: OpsDimensions.space16),
            _DialogField(
              label:      'Ward Name',
              hint:       'e.g. Bandra East',
              controller: _nameCtrl,
              action:     TextInputAction.next,
            ),
            const SizedBox(height: OpsDimensions.space16),
            _DialogField(
              label:      'Ward Code',
              hint:       'e.g. H/E',
              controller: _codeCtrl,
              action:     TextInputAction.next,
              caps:       TextCapitalization.characters,
            ),
            const SizedBox(height: OpsDimensions.space16),
            _DialogField(
              label:      'Description (optional)',
              hint:       'Brief description of this ward.',
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
                  final code   = _codeCtrl.text.trim();
                  final areaId = _areaId ?? '';
                  if (name.isEmpty ||
                      code.isEmpty ||
                      areaId.isEmpty) {
                    return;
                  }
                  await widget.onSave(
                    name,
                    code,
                    areaId,
                    _descCtrl.text.trim().isEmpty
                        ? null
                        : _descCtrl.text.trim(),
                  );
                },
          child: widget.isSaving
              ? const _SavingIndicator()
              : Text(isEdit ? 'Save Changes' : 'Add Ward'),
        ),
      ],
    );
  }
}

class _WardRowActions extends StatelessWidget {
  const _WardRowActions({
    required this.ward,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final OpsWard      ward;
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
          icon: ward.isActive
              ? Icons.toggle_on_rounded
              : Icons.toggle_off_rounded,
          tooltip: ward.isActive ? 'Deactivate' : 'Activate',
          color:   ward.isActive
              ? OpsColors.success
              : OpsColors.textDisabled,
          onTap:   onToggle,
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

class _AreaDropdown extends StatelessWidget {
  const _AreaDropdown({
    required this.value,
    required this.areas,
    required this.onChanged,
  });

  final String?          value;
  final List<OpsAreaOption> areas;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: OpsDimensions.inputHeight,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        style: OpsTextStyles.body,
        decoration: const InputDecoration(
            hintText: 'All areas', isDense: true),
        isExpanded:    true,
        dropdownColor: OpsColors.white,
        icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size:  18,
            color: OpsColors.textDisabled),
        items: [
          const DropdownMenuItem<String>(
              value: null, child: Text('All Areas')),
          ...areas.map((a) => DropdownMenuItem<String>(
                value: a.id,
                child: Text(a.areaName,
                    overflow: TextOverflow.ellipsis),
              )),
        ],
        onChanged: onChanged,
      ),
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
    this.maxLines = 1,
    this.caps = TextCapitalization.none,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputAction action;
  final int maxLines;
  final TextCapitalization caps;

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
          maxLines: maxLines,
          textCapitalization: caps,
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
