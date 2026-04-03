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

class ComplaintCategoriesScreen extends ConsumerStatefulWidget {
  const ComplaintCategoriesScreen({super.key});

  @override
  ConsumerState<ComplaintCategoriesScreen> createState() =>
      _ComplaintCategoriesScreenState();
}

class _ComplaintCategoriesScreenState
    extends ConsumerState<ComplaintCategoriesScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref
            .read(opsCategoryListProvider.notifier)
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
    final state = ref.watch(opsCategoryListProvider);

    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding:    const EdgeInsets.all(OpsDimensions.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OpsPageHeader(
            title:    'Complaint Categories',
            subtitle: 'Categories voters select when filing complaints.',
            actions: [
              if (state.total > 0)
                _CountBadge(
                    count: state.total, label: 'categories'),
              ElevatedButton.icon(
                onPressed: () =>
                    _showCreateDialog(context),
                icon:  const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Category'),
              ),
            ],
          ),

          const SizedBox(height: OpsDimensions.space24),

          _SearchBar(
            ctrl:     _searchCtrl,
            onSearch: (q) => ref
                .read(opsCategoryListProvider.notifier)
                .search(q),
          ),

          const SizedBox(height: OpsDimensions.space20),

          if (state.isEmpty && !state.isLoading)
            OpsEmptyState(
              icon:        Icons.category_outlined,
              title:       'No Categories Found',
              subtitle:    state.searchQuery.isNotEmpty
                  ? 'No results for "${state.searchQuery}".'
                  : 'Add the first complaint category.',
              actionLabel: 'Add Category',
              onAction:    () => _showCreateDialog(context),
            )
          else
            OpsDataTable(
              isLoading:    state.isLoading,
              skeletonRows: 6,
              columns: const [
                'Category Name',
                'Description',
                'Complaints',
                'Sort',
                'Created',
                'Status',
                'Actions',
              ],
              emptyMessage: 'No categories match the search.',
              rows: state.items.map((c) {
                return OpsTableRow(
                  cells: [
                    c.name,
                    c.description.length > 50
                        ? '${c.description.substring(0, 50)}…'
                        : c.description,
                    '${c.complaintsCount}',
                    '${c.sortOrder}',
                    OpsDateFormatter.toDate(c.createdAt),
                    c.isActive ? '✓ Active' : '✗ Inactive',
                    '',
                  ],
                  badge: _CategoryRowActions(
                    category: c,
                    onEdit:   () => _showEditDialog(context, c),
                    onToggle: () => _toggleActive(c),
                    onDelete: () => _confirmDelete(context, c),
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
      builder: (_) => _CategoryDialog(
        onSave: (name, desc, sort) async {
          final created = await ref
              .read(opsCategoryActionProvider.notifier)
              .create(
                name:        name,
                description: desc,
                sortOrder:   sort,
              );
          if (created != null && context.mounted) {
            ref
                .read(opsCategoryListProvider.notifier)
                .prepend(created);
            context.showSuccess(
                'Category "$name" created.');
            Navigator.of(context).pop();
          } else if (context.mounted) {
            context.showError(ref
                .read(opsCategoryActionProvider)
                .errorMessage);
          }
        },
        isSaving:
            ref.read(opsCategoryActionProvider).isLoading,
      ),
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, OpsCategory cat) async {
    await showDialog(
      context: context,
      builder: (_) => _CategoryDialog(
        initial: cat,
        onSave: (name, desc, sort) async {
          final updated = await ref
              .read(opsCategoryActionProvider.notifier)
              .update(
                cat.id,
                name:        name,
                description: desc,
                sortOrder:   sort,
              );
          if (updated != null && context.mounted) {
            ref
                .read(opsCategoryListProvider.notifier)
                .replace(updated);
            context.showSuccess('Category updated.');
            Navigator.of(context).pop();
          } else if (context.mounted) {
            context.showError(ref
                .read(opsCategoryActionProvider)
                .errorMessage);
          }
        },
        isSaving:
            ref.read(opsCategoryActionProvider).isLoading,
      ),
    );
  }

  Future<void> _toggleActive(OpsCategory cat) async {
    final newState = !cat.isActive;
    ref
        .read(opsCategoryListProvider.notifier)
        .toggleActiveOptimistic(cat.id, newState);

    final updated = await ref
        .read(opsCategoryActionProvider.notifier)
        .update(cat.id, isActive: newState);

    if (updated == null && mounted) {
      ref
          .read(opsCategoryListProvider.notifier)
          .toggleActiveOptimistic(cat.id, cat.isActive);
      context.showError(
          ref.read(opsCategoryActionProvider).errorMessage);
    } else if (mounted) {
      context.showSuccess(newState
          ? '"${cat.name}" activated.'
          : '"${cat.name}" deactivated.');
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, OpsCategory cat) async {
    if (cat.complaintsCount > 0) {
      context.showError(
        'Cannot delete "${cat.name}" — '
        '${cat.complaintsCount} complaint'
        '${cat.complaintsCount == 1 ? '' : 's'} '
        'use this category.',
      );
      return;
    }

    final confirmed =
        await _showDeleteDialog(context, cat.name);
    if (confirmed != true || !mounted) return;

    final ok = await ref
        .read(opsCategoryActionProvider.notifier)
        .delete(cat.id);

    if (ok && mounted) {
      ref
          .read(opsCategoryListProvider.notifier)
          .remove(cat.id);
      context.showSuccess('"${cat.name}" deleted.');
    } else if (mounted) {
      context.showError(ref
          .read(opsCategoryActionProvider)
          .errorMessage);
    }
  }
}

// ─────────────────────────────────────────────
// Category dialog
// ─────────────────────────────────────────────

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({
    required this.onSave,
    required this.isSaving,
    this.initial,
  });

  final Future<void> Function(String, String, int) onSave;
  final bool          isSaving;
  final OpsCategory?  initial;

  @override
  State<_CategoryDialog> createState() =>
      _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _sortCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
        text: widget.initial?.name);
    _descCtrl = TextEditingController(
        text: widget.initial?.description);
    _sortCtrl = TextEditingController(
        text: '${widget.initial?.sortOrder ?? 0}');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return AlertDialog(
      title: Text(
          isEdit ? 'Edit Category' : 'Add Category'),
      content: SizedBox(
        width: OpsDimensions.dialogWidthSM,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(
              label:      'Category Name',
              hint:       'e.g. Water Supply Problem',
              controller: _nameCtrl,
              action:     TextInputAction.next,
            ),
            const SizedBox(height: OpsDimensions.space16),
            _DialogField(
              label:      'Description',
              hint:       'Describe what this category covers.',
              controller: _descCtrl,
              maxLines:   3,
              action:     TextInputAction.next,
            ),
            const SizedBox(height: OpsDimensions.space16),
            _DialogField(
              label:      'Sort Order',
              hint:       '0 = first',
              controller: _sortCtrl,
              keyboard:   TextInputType.number,
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
                  final desc = _descCtrl.text.trim();
                  final sort = int.tryParse(
                          _sortCtrl.text.trim()) ??
                      0;
                  if (name.isEmpty || desc.isEmpty) {
                    return;
                  }
                  await widget.onSave(name, desc, sort);
                },
          child: widget.isSaving
              ? const _SavingIndicator()
              : Text(isEdit
                  ? 'Save Changes'
                  : 'Add Category'),
        ),
      ],
    );
  }
}

class _CategoryRowActions extends StatelessWidget {
  const _CategoryRowActions({
    required this.category,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final OpsCategory  category;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconBtn(
            icon: Icons.edit_outlined,
            tooltip: 'Edit',
            color: OpsColors.primary,
            onTap: onEdit),
        const SizedBox(width: 4),
        _IconBtn(
          icon: category.isActive
              ? Icons.toggle_on_rounded
              : Icons.toggle_off_rounded,
          tooltip: category.isActive
              ? 'Deactivate'
              : 'Activate',
          color: category.isActive
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
