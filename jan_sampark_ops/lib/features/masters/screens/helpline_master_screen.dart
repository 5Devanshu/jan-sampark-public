import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/ops_colors.dart';
import '../../../core/theme/ops_text_styles.dart';
import '../../../core/network/ops_dio_client.dart';
import '../../../core/constants/ops_constants.dart';
import '../../../shared/widgets/ops_data_table.dart';
import '../providers/masters_provider.dart';

class HelplineMasterScreen extends ConsumerWidget {
  const HelplineMasterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(helplineListProvider);

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
                    Text('Helpline Numbers',
                        style: OpsTextStyles.heading1),
                    Text(
                      'System-wide emergency and service helpline numbers.',
                      style: OpsTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    _showCreateHelpline(context, ref),
                icon:  const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Number'),
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
              child: Text(e.toString(),
                  style: OpsTextStyles.bodySecondary),
            ),
            data: (items) {
              final system = items.where((h) => h.isSystem).toList();
              final custom = items.where((h) => !h.isSystem).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('System Numbers',
                      style: OpsTextStyles.heading3),
                  const SizedBox(height: 12),
                  OpsDataTable(
                    columns: const [
                      'Name',
                      'Number',
                      'Category',
                      'Status',
                    ],
                    rows: system.map((h) => [
                      h.name,
                      h.number,
                      h.category,
                      h.isActive
                          ? '✓ Active'
                          : '✗ Inactive',
                    ]).toList(),
                    emptyMessage: 'No system numbers configured.',
                  ),

                  const SizedBox(height: 24),

                  Text('Custom Numbers',
                      style: OpsTextStyles.heading3),
                  const SizedBox(height: 4),
                  Text(
                    'Added by Corporators for their areas.',
                    style: OpsTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 12),
                  OpsDataTable(
                    columns: const [
                      'Name',
                      'Number',
                      'Category',
                      'Status',
                    ],
                    rows: custom.map((h) => [
                      h.name,
                      h.number,
                      h.category,
                      h.isActive
                          ? '✓ Active'
                          : '✗ Inactive',
                    ]).toList(),
                    emptyMessage: 'No custom numbers added yet.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCreateHelpline(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _CreateHelplineDialog(
        onCreated: () => ref.invalidate(helplineListProvider),
      ),
    );
  }
}

class _CreateHelplineDialog extends ConsumerStatefulWidget {
  const _CreateHelplineDialog({required this.onCreated});
  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateHelplineDialog> createState() =>
      _CreateHelplineDialogState();
}

class _CreateHelplineDialogState
    extends ConsumerState<_CreateHelplineDialog> {
  final _nameCtrl   = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _descCtrl   = TextEditingController();
  String  _category = 'municipal';
  bool    _isLoading = false;
  String  _error     = '';

  static const _categoryOptions = {
    'police':      'Police',
    'fire':        'Fire',
    'medical':     'Medical',
    'electricity': 'Electricity',
    'water':       'Water',
    'women':       'Women',
    'child':       'Child',
    'municipal':   'Municipal',
    'transport':   'Transport',
    'disaster':    'Disaster',
    'other':       'Other',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _numberCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name and number are required.');
      return;
    }
    setState(() { _isLoading = true; _error = ''; });
    try {
      final dio = ref.read(opsDioProvider);
      await dio.post(
        OpsConstants.endpointHelpline,
        data: {
          'name':        _nameCtrl.text.trim(),
          'number':      _numberCtrl.text.trim(),
          'category':    _category,
          'description': _descCtrl.text.trim(),
          'is_system':   true,
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
      title: const Text('Add Helpline Number',
          style: OpsTextStyles.heading2),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              style:      OpsTextStyles.body,
              decoration: const InputDecoration(
                  labelText: 'Service Name',
                  hintText:  'e.g. Mumbai Police'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller:  _numberCtrl,
              keyboardType: TextInputType.phone,
              style:        OpsTextStyles.body,
              decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText:  'e.g. 100 or 1800-XXX-XXXX'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                  labelText: 'Category'),
              items: _categoryOptions.entries.map((e) {
                return DropdownMenuItem<String>(
                  value: e.key,
                  child: Text(e.value),
                );
              }).toList(),
              onChanged: (v) =>
                  setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              maxLines:   2,
              style:      OpsTextStyles.body,
              decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText:  'Brief description'),
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
              _isLoading ? 'Adding...' : 'Add Number'),
        ),
      ],
    );
  }
}