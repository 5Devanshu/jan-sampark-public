import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/ops_colors.dart';
import '../../../core/theme/ops_text_styles.dart';
import '../../../core/network/ops_dio_client.dart';
import '../../../core/constants/ops_constants.dart';
import '../../../shared/widgets/ops_data_table.dart';
import '../providers/masters_provider.dart';

class ComplaintCategoriesScreen extends ConsumerWidget {
  const ComplaintCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(categoriesListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Complaint Categories',
                        style: OpsTextStyles.heading1),
                    Text(
                      'Manage categories voters use when filing complaints.',
                      style: OpsTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    _showCreateCategory(context, ref),
                icon:  const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Category'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          async.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(
                    color: OpsColors.primary),
              ),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.toString(),
                      style: OpsTextStyles.bodySecondary),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.invalidate(categoriesListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (cats) => OpsDataTable(
              columns: const [
                'Category Name',
                'Description',
                'Complaints',
                'Status',
              ],
              rows: cats.map((c) => [
                c.name,
                c.description.length > 40
                    ? '${c.description.substring(0, 40)}...'
                    : c.description,
                '${c.complaintsCount}',
                c.isActive ? '✓ Active' : '✗ Inactive',
              ]).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCategory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _CreateCategoryDialog(
        onCreated: () => ref.invalidate(categoriesListProvider),
      ),
    );
  }
}

class _CreateCategoryDialog extends ConsumerStatefulWidget {
  const _CreateCategoryDialog({required this.onCreated});
  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateCategoryDialog> createState() =>
      _CreateCategoryDialogState();
}

class _CreateCategoryDialogState
    extends ConsumerState<_CreateCategoryDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool   _isLoading = false;
  String _error     = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }
    setState(() { _isLoading = true; _error = ''; });
    try {
      final dio = ref.read(opsDioProvider);
      await dio.post(
        OpsConstants.endpointCategories,
        data: {
          'name':        _nameCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
        },
      );
      widget.onCreated();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error     = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Category',
          style: OpsTextStyles.heading2),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              style:      OpsTextStyles.body,
              decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g. Water Supply Problem'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              maxLines:   3,
              style:      OpsTextStyles.body,
              decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText:
                      'Briefly describe what this category covers.'),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_error,
                  style: OpsTextStyles.caption.copyWith(
                      color: OpsColors.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: Text(
              _isLoading ? 'Adding...' : 'Add Category'),
        ),
      ],
    );
  }
}