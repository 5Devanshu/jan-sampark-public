import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/ops_colors.dart';
import '../../../core/theme/ops_text_styles.dart';
import '../../../core/network/ops_dio_client.dart';
import '../../../core/constants/ops_constants.dart';
import '../providers/corporators_provider.dart';

final _createLoadingProvider = StateProvider<bool>((ref) => false);
final _createErrorProvider   = StateProvider<String>((ref) => '');

class CreateCorporatorScreen extends ConsumerStatefulWidget {
  const CreateCorporatorScreen({super.key});

  @override
  ConsumerState<CreateCorporatorScreen> createState() =>
      _CreateCorporatorScreenState();
}

class _CreateCorporatorScreenState
    extends ConsumerState<CreateCorporatorScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passCtrl   = TextEditingController();

  String?       _selectedAreaId;
  List<String>  _selectedWardIds = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAreaId == null) {
      ref.read(_createErrorProvider.notifier).state =
          'Please select an area.';
      return;
    }

    ref.read(_createLoadingProvider.notifier).state = true;
    ref.read(_createErrorProvider.notifier).state   = '';

    try {
      final dio = ref.read(opsDioProvider);
      await dio.post(
        OpsConstants.endpointCorporators,
        data: {
          'full_name':        _nameCtrl.text.trim(),
          'mobile':           _mobileCtrl.text.trim(),
          'password':         _passCtrl.text,
          'area_id':          _selectedAreaId,
          'assigned_ward_ids': _selectedWardIds,
        },
      );

      ref.read(corporatorsProvider.notifier).load();
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Corporator created successfully.'),
            backgroundColor: OpsColors.success,
          ),
        );
      }
    } catch (e) {
      ref.read(_createErrorProvider.notifier).state =
          e.toString();
    } finally {
      ref.read(_createLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final areasAsync  = ref.watch(opsAreasProvider);
    final wardsAsync  = ref.watch(
        opsWardsForAreaProvider(_selectedAreaId ?? ''));
    final isLoading   = ref.watch(_createLoadingProvider);
    final error       = ref.watch(_createErrorProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                          Icons.arrow_back_rounded),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text('Add Corporator',
                            style: OpsTextStyles.heading1),
                        Text(
                          'Create a new corporator account.',
                          style: OpsTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Form card ──────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color:        OpsColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: OpsColors.borderGrey),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text('Personal Details',
                          style: OpsTextStyles.heading3),
                      const SizedBox(height: 20),

                      // Full name
                      _OpsField(
                        label:      'Full Name',
                        controller: _nameCtrl,
                        hint:       'e.g. Rajesh Kumar Sharma',
                        validator: (v) =>
                            (v?.trim().isEmpty ?? true)
                                ? 'Required'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Mobile
                      _OpsField(
                        label:       'Mobile Number',
                        controller:  _mobileCtrl,
                        hint:        '10-digit mobile',
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v?.trim().isEmpty ?? true) {
                            return 'Required';
                          }
                          if (v!.trim().length != 10) {
                            return 'Enter 10-digit mobile';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _OpsField(
                        label:       'Temporary Password',
                        controller:  _passCtrl,
                        hint:        'Min 8 chars',
                        obscure:     true,
                        validator: (v) =>
                            (v?.length ?? 0) < 8
                                ? 'Min 8 characters'
                                : null,
                      ),

                      const SizedBox(height: 28),

                      Text('Area & Ward Assignment',
                          style: OpsTextStyles.heading3),
                      const SizedBox(height: 20),

                      // Area dropdown
                      _OpsLabel(label: 'Area'),
                      const SizedBox(height: 6),
                      areasAsync.when(
                        loading: () =>
                            const LinearProgressIndicator(),
                        error: (e, _) => Text(
                          'Failed to load areas.',
                          style: OpsTextStyles.body.copyWith(
                              color: OpsColors.error),
                        ),
                        data: (areas) =>
                            DropdownButtonFormField<String>(
                          value:   _selectedAreaId,
                          hint: const Text('Select area'),
                          items: areas.map((a) {
                            return DropdownMenuItem<String>(
                              value: a.id,
                              child: Text(a.areaName),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() {
                            _selectedAreaId  = v;
                            _selectedWardIds = [];
                          }),
                        ),
                      ),

                      if (_selectedAreaId != null) ...[
                        const SizedBox(height: 16),

                        // Ward multi-select
                        _OpsLabel(label: 'Wards'),
                        const SizedBox(height: 6),
                        wardsAsync.when(
                          loading: () =>
                              const LinearProgressIndicator(),
                          error: (e, _) => Text(
                            'Failed to load wards.',
                            style: OpsTextStyles.body.copyWith(
                                color: OpsColors.error),
                          ),
                          data: (wards) => Wrap(
                            spacing:    8,
                            runSpacing: 8,
                            children: wards.map((w) {
                              final selected =
                                  _selectedWardIds.contains(w.id);
                              return FilterChip(
                                label: Text(
                                  '${w.wardName} (${w.wardCode})',
                                  style: OpsTextStyles.caption
                                      .copyWith(
                                    color: selected
                                        ? OpsColors.primary
                                        : OpsColors.textSecondary,
                                  ),
                                ),
                                selected: selected,
                                onSelected: (v) =>
                                    setState(() {
                                  if (v) {
                                    _selectedWardIds.add(w.id);
                                  } else {
                                    _selectedWardIds.remove(w.id);
                                  }
                                }),
                                selectedColor:
                                    OpsColors.primaryLight,
                                checkmarkColor: OpsColors.primary,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (error.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color:        OpsColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: OpsColors.error, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(error,
                              style: OpsTextStyles.caption
                                  .copyWith(
                                      color: OpsColors.error)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _onSubmit,
                      icon: isLoading
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: OpsColors.white,
                              ),
                            )
                          : const Icon(Icons.person_add_outlined,
                              size: 18),
                      label: Text(
                        isLoading
                            ? 'Creating...'
                            : 'Create Corporator',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OpsField extends StatelessWidget {
  const _OpsField({
    required this.label,
    required this.controller,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.obscure = false,
  });

  final String                   label;
  final TextEditingController    controller;
  final String                   hint;
  final String? Function(String?)? validator;
  final TextInputType?           keyboardType;
  final bool                     obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OpsLabel(label: label),
        const SizedBox(height: 6),
        TextFormField(
          controller:   controller,
          keyboardType: keyboardType,
          obscureText:  obscure,
          validator:    validator,
          style:        OpsTextStyles.body,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _OpsLabel extends StatelessWidget {
  const _OpsLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: OpsTextStyles.fieldLabel);
  }
}