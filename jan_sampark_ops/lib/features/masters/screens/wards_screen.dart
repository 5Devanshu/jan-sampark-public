import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/ops_colors.dart';
import '../../../core/theme/ops_text_styles.dart';
import '../../../core/network/ops_dio_client.dart';
import '../../../core/constants/ops_constants.dart';
import '../../../shared/widgets/ops_data_table.dart';
import '../providers/masters_provider.dart';
import '../../corporators/providers/corporators_provider.dart';

class WardsScreen extends ConsumerWidget {
  const WardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardsAsync = ref.watch(wardsListProvider);

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
                    Text('Wards', style: OpsTextStyles.heading1),
                    Text(
                      'Ward boundaries within each area.',
                      style: OpsTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    _showCreateWard(context, ref),
                icon:  const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Ward'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          wardsAsync.when(
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
            data: (wards) => OpsDataTable(
              columns: const [
                'Ward Name',
                'Ward Code',
                'Area',
                'Status',
              ],
              rows: wards.map((w) => [
                w.wardName,
                w.wardCode,
                w.areaName,
                w.isActive ? '✓ Active' : '✗ Inactive',
              ]).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateWard(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _CreateWardDialog(
        onCreated: () => ref.invalidate(wardsListProvider),
      ),
    );
  }
}

class _CreateWardDialog extends ConsumerStatefulWidget {
  const _CreateWardDialog({required this.onCreated});
  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateWardDialog> createState() =>
      _CreateWardDialogState();
}

class _CreateWardDialogState
    extends ConsumerState<_CreateWardDialog> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  String? _areaId;
  bool   _isLoading = false;
  String _error     = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _codeCtrl.text.trim().isEmpty ||
        _areaId == null) {
      setState(() => _error = 'All fields required.');
      return;
    }

    setState(() { _isLoading = true; _error = ''; });

    try {
      final dio = ref.read(opsDioProvider);
      await dio.post(
        OpsConstants.endpointWards,
        data: {
          'ward_name': _nameCtrl.text.trim(),
          'ward_code': _codeCtrl.text.trim().toUpperCase(),
          'area_id':   _areaId,
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
    final areasAsync = ref.watch(opsAreasProvider);

    return AlertDialog(
      title: const Text('Add Ward',
          style: OpsTextStyles.heading2),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Area selector
            areasAsync.when(
              loading: () =>
                  const LinearProgressIndicator(),
              error: (_, __) =>
                  const Text('Failed to load areas'),
              data: (areas) => DropdownButtonFormField<String>(
                hint: const Text('Select Area'),
                value: _areaId,
                items: areas.map((a) {
                  return DropdownMenuItem<String>(
                    value: a.id,
                    child: Text(a.areaName),
                  );
                }).toList(),
                onChanged: (v) =>
                    setState(() => _areaId = v),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              style:      OpsTextStyles.body,
              decoration: const InputDecoration(
                  labelText: 'Ward Name',
                  hintText: 'e.g. Bandra East'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeCtrl,
              style:      OpsTextStyles.body,
              decoration: const InputDecoration(
                  labelText: 'Ward Code',
                  hintText: 'e.g. H/E'),
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
              _isLoading ? 'Adding...' : 'Add Ward'),
        ),
      ],
    );
  }
}