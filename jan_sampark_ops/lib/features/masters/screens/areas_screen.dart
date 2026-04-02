import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/ops_colors.dart';
import '../../../core/theme/ops_text_styles.dart';
import '../../../core/network/ops_dio_client.dart';
import '../../../core/constants/ops_constants.dart';
import '../../../shared/widgets/ops_data_table.dart';
import '../../../shared/widgets/ops_section_header.dart';
import '../providers/masters_providder.dart';

class AreasScreen extends ConsumerWidget {
  const AreasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(areasListProvider);

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
                    Text('Areas', style: OpsTextStyles.heading1),
                    Text(
                      'Geographic areas served by Jan Sampark.',
                      style: OpsTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    _showCreateArea(context, ref),
                icon:  const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Area'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          areasAsync.when(
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
            data: (areas) => OpsDataTable(
              columns: const [
                'Area Name',
                'Area Code',
                'Wards',
                'Status',
              ],
              rows: areas.map((a) => [
                a.areaName,
                a.areaCode,
                '${a.wardsCount} ward'
                    '${a.wardsCount == 1 ? '' : 's'}',
                a.isActive ? '✓ Active' : '✗ Inactive',
              ]).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateArea(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _CreateAreaDialog(
        onCreated: () => ref.invalidate(areasListProvider),
      ),
    );
  }
}

class _CreateAreaDialog extends ConsumerStatefulWidget {
  const _CreateAreaDialog({required this.onCreated});
  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateAreaDialog> createState() =>
      _CreateAreaDialogState();
}

class _CreateAreaDialogState
    extends ConsumerState<_CreateAreaDialog> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool  _isLoading = false;
  String _error    = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _codeCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Both fields are required.');
      return;
    }

    setState(() { _isLoading = true; _error = ''; });

    try {
      final dio = ref.read(opsDioProvider);
      await dio.post(
        OpsConstants.endpointAreas,
        data: {
          'area_name': _nameCtrl.text.trim(),
          'area_code': _codeCtrl.text.trim().toUpperCase(),
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
      title: const Text('Add Area',
          style: OpsTextStyles.heading2),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              style:      OpsTextStyles.body,
              decoration: const InputDecoration(
                  labelText: 'Area Name',
                  hintText: 'e.g. Western Suburbs'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeCtrl,
              style:      OpsTextStyles.body,
              decoration: const InputDecoration(
                  labelText: 'Area Code',
                  hintText: 'e.g. WS'),
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
              _isLoading ? 'Adding...' : 'Add Area'),
        ),
      ],
    );
  }
}
