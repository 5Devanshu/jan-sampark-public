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

class AreasScreen extends ConsumerStatefulWidget {
  const AreasScreen({super.key});

  @override
  ConsumerState<AreasScreen> createState() =>
      _AreasScreenState();
}

class _AreasScreenState extends ConsumerState<AreasScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(opsAreaListProvider.notifier).loadMore();
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
    final state = ref.watch(opsAreaListProvider);

    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding:    const EdgeInsets.all(OpsDimensions.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OpsPageHeader(
            title:    'Areas',
            subtitle: 'Geographic service areas for Jan Sampark.',
            actions: [
              if (state.total > 0)
                _CountBadge(count: state.total, label: 'areas'),
              ElevatedButton.icon(
                onPressed: () => _showCreateDialog(context),
                icon:  const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Area'),
              ),
            ],
          ),

          const SizedBox(height: OpsDimensions.space24),

          // Search
          _SearchBar(
            ctrl:     _searchCtrl,
            onSearch: (q) => ref
                .read(opsAreaListProvider.notifier)
                .search(q),
          ),

          const SizedBox(height: OpsDimensions.space20),

          if (state.isEmpty && !state.isLoading)
            OpsEmptyState(
              icon:        Icons.location_city_outlined,
              title:       'No Areas Found',
              subtitle:    state.searchQuery.isNotEmpty
                  ? 'No results for "${state.searchQuery}".'
                  : 'Add the first service area.',
              actionLabel: 'Add Area',
              onAction:    () => _showCreateDialog(context),
            )
          else
            OpsDataTable(
              isLoading:    state.isLoading,
              skeletonRows: 6,
              columns: const [
                'Area Name',
                'Code',
                'Wards',
                'Voters',
                'Corporator',
                'Created',
                'Status',
                'Actions',
              ],
              emptyMessage: 'No areas match the search.',
              rows: state.items.map((a) {
                return OpsTableRow(
                  cells: [
                    a.areaName,
                    a.areaCode,
                    '${a.wardsCount}',
                    a.votersCount.compact,
                    a.corporatorName ?? '—',
                    OpsDateFormatter.toDate(a.createdAt),
                    a.isActive ? '✓ Active' : '✗ Inactive',
                    '',
                  ],
                  badge: _RowActions(
                    area:     a,
                    onEdit:   () => _showEditDialog(context, a),
                    onToggle: () => _toggleActive(a),
                    onDelete: () => _confirmDelete(context, a),
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
      builder: (_) => _AreaDialog(
        onSave: (name, code, desc) async {
          final created = await ref
              .read(opsAreaActionProvider.notifier)
              .create(
                areaName:    name,
                areaCode:    code,
                description: desc,
              );
          if (created != null && context.mounted) {
            ref
                .read(opsAreaListProvider.notifier)
                .prepend(created);
            context.showSuccess('Area "$name" created.');
            Navigator.of(context).pop();
          } else if (context.mounted) {
            context.showError(
                ref.read(opsAreaActionProvider).errorMessage);
          }
        },
        isSaving: ref.read(opsAreaActionProvider).isLoading,
      ),
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, OpsArea area) async {
    await showDialog(
      context: context,
      builder: (_) => _AreaDialog(
        initial: area,
        onSave: (name, code, desc) async {
          final updated = await ref
              .read(opsAreaActionProvider.notifier)
              .update(
                area.id,
                areaName:    name,
                areaCode:    code,
                description: desc,
              );
          if (updated != null && context.mounted) {
            ref
                .read(opsAreaListProvider.notifier)
                .replace(updated);
            context.showSuccess('Area updated.');
            Navigator.of(context).pop();
          } else if (context.mounted) {
            context.showError(
                ref.read(opsAreaActionProvider).errorMessage);
          }
        },
        isSaving: ref.read(opsAreaActionProvider).isLoading,
      ),
    );
  }

  Future<void> _toggleActive(OpsArea area) async {
    final newState = !area.isActive;
    // Optimistic
    ref
        .read(opsAreaListProvider.notifier)
        .toggleActiveOptimistic(area.id, newState);

    final updated = await ref
        .read(opsAreaActionProvider.notifier)
        .update(area.id, isActive: newState);

    if (updated == null && mounted) {
      // Rollback
      ref
          .read(opsAreaListProvider.notifier)
          .toggleActiveOptimistic(area.id, area.isActive);
      context.showError(
          ref.read(opsAreaActionProvider).errorMessage);
    } else if (mounted) {
      context.showSuccess(newState
          ? '${area.areaName} activated.'
          : '${area.areaName} deactivated.');
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, OpsArea area) async {
    if (area.wardsCount > 0) {
      context.showError(
        'Cannot delete "${area.areaName}" — '
        'it has ${area.wardsCount} ward'
        '${area.wardsCount == 1 ? '' : 's'}. '
        'Remove all wards first.',
      );
      return;
    }

    final confirmed = await _showDeleteDialog(
        context, area.areaName);
    if (confirmed != true || !mounted) return;

    final ok = await ref
        .read(opsAreaActionProvider.notifier)
        .delete(area.id);

    if (ok && mounted) {
      ref
          .read(opsAreaListProvider.notifier)
          .remove(area.id);
      context.showSuccess(
          '"${area.areaName}" deleted.');
    } else if (mounted) {
      context.showError(
          ref.read(opsAreaActionProvider).errorMessage);
    }
  }
}

// ─────────────────────────────────────────────
// Area create / edit dialog
// ─────────────────────────────────────────────

class _AreaDialog extends StatefulWidget {
  const _AreaDialog({
    required this.onSave,
    required this.isSaving,
    this.initial,
  });

  final Future<void> Function(String, String, String?) onSave;
  final bool         isSaving;
  final OpsArea?     initial;

  @override
  State<_AreaDialog> createState() => _AreaDialogState();
}

class _AreaDialogState extends State<_AreaDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.initial?.areaName);
    _codeCtrl =
        TextEditingController(text: widget.initial?.areaCode);
    _descCtrl = TextEditingController(
        text: widget.initial?.description);
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
      title: Text(isEdit ? 'Edit Area' : 'Add Area'),
      content: SizedBox(
        width: OpsDimensions.dialogWidthSM,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(
              label:      'Area Name',
              hint:       'e.g. Western Suburbs',
              controller: _nameCtrl,
              action:     TextInputAction.next,
            ),
            const SizedBox(height: OpsDimensions.space16),
            _DialogField(
              label:      'Area Code',
              hint:       'e.g. WS',
              controller: _codeCtrl,
              action:     TextInputAction.next,
              caps:       TextCapitalization.characters,
            ),
            const SizedBox(height: OpsDimensions.space16),
            _DialogField(
              label:      'Description (optional)',
              hint:       'Short description of this area.',
              controller: _descCtrl,
              maxLines:   3,
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
                  final name = _nameCtrl.text.trim();
                  final code = _codeCtrl.text.trim();
                  if (name.isEmpty || code.isEmpty) {
                    return;
                  }
                  await widget.onSave(
                    name,
                    code,
                    _descCtrl.text.trim().isEmpty
                        ? null
                        : _descCtrl.text.trim(),
                  );
                },
          child: widget.isSaving
              ? const _SavingIndicator()
              : Text(isEdit ? 'Save Changes' : 'Add Area'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Row action buttons
// ─────────────────────────────────────────────

class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.area,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final OpsArea      area;
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
          onTap:   onEdit,
        ),
        const SizedBox(width: 4),
        _IconBtn(
          icon: area.isActive
              ? Icons.toggle_on_rounded
              : Icons.toggle_off_rounded,
          tooltip: area.isActive ? 'Deactivate' : 'Activate',
          color:   area.isActive
              ? OpsColors.success
              : OpsColors.textDisabled,
          onTap:   onToggle,
        ),
        const SizedBox(width: 4),
        _IconBtn(
          icon:    Icons.delete_outline_rounded,
          tooltip: 'Delete',
          color:   OpsColors.error,
          onTap:   onDelete,
        ),
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
