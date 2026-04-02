import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/inputs/app_dropdown.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/dialogs/loading_dialog.dart';
import '../models/corporator_leader_models.dart';
import '../providers/corporator_leader_provider.dart';
import '../widgets/leader_responsibility_selector.dart';

// ─────────────────────────────────────────────
// Ward options for the create form
// ─────────────────────────────────────────────

class _WardOption {
  const _WardOption({
    required this.id,
    required this.wardName,
    required this.wardCode,
  });
  final String id;
  final String wardName;
  final String wardCode;

  factory _WardOption.fromJson(Map<String, dynamic> json) {
    return _WardOption(
      id:       json['id']        as String? ?? '',
      wardName: json['ward_name'] as String? ?? '',
      wardCode: json['ward_code'] as String? ?? '',
    );
  }
}

final _myWardsProvider =
    FutureProvider.autoDispose<List<_WardOption>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get(
    AppConstants.endpointWards,
    queryParameters: {'page_size': 100},
  );
  final data = res.data as Map<String, dynamic>;
  return (data['data'] as List<dynamic>? ?? [])
      .map((e) => _WardOption.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

class CreateLeaderScreen extends ConsumerStatefulWidget {
  const CreateLeaderScreen({super.key});

  @override
  ConsumerState<CreateLeaderScreen> createState() =>
      _CreateLeaderScreenState();
}

class _CreateLeaderScreenState
    extends ConsumerState<CreateLeaderScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passCtrl   = TextEditingController();

  String?       _selectedWardId;
  Set<String>   _responsibilities = {
    'acknowledge_complaints',
    'escalate_complaints',
    'add_complaint_notes',
    'ground_verification',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWardId == null) {
      context.showError('Please select a ward for this leader.');
      return;
    }

    LoadingDialog.show(context, message: 'Creating leader...');

    final success = await ref
        .read(createLeaderProvider.notifier)
        .create(
          CreateLeaderRequest(
            fullName:         _nameCtrl.text.trim(),
            mobile:           _mobileCtrl.text.trim(),
            password:         _passCtrl.text,
            wardId:           _selectedWardId!,
            responsibilities: _responsibilities.toList(),
          ),
        );

    if (!mounted) return;
    LoadingDialog.hide(context);

    if (success) {
      ref
          .read(corporatorLeaderListProvider.notifier)
          .load();
      context.showSuccess('Leader created successfully.');
      context.pop();
    } else {
      final error =
          ref.read(createLeaderProvider).errorMessage;
      if (error.isNotEmpty) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wardsAsync = ref.watch(_myWardsProvider);
    final state      = ref.watch(createLeaderProvider);

    return AppScaffold(
      title:       'Add Leader',
      isBlueAppBar: true,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
              AppDimensions.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spaceXL),

              // ── Personal details ───────────────
              Text('Personal Details',
                  style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spaceMD),

              AppTextField(
                label:          'Full Name',
                hint:           'Leader\'s full name',
                controller:     _nameCtrl,
                textInputAction: TextInputAction.next,
                validator:      Validators.fullName,
                prefixIcon: const Icon(Icons.person_outline,
                    size: AppDimensions.iconMD),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              AppTextField(
                label:          'Mobile Number',
                hint:           '10-digit mobile number',
                controller:     _mobileCtrl,
                keyboardType:   TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator:      Validators.mobile,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                prefixIcon: const Icon(Icons.phone_outlined,
                    size: AppDimensions.iconMD),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              AppTextField(
                label:          'Temporary Password',
                hint:           'Min 8 chars',
                controller:     _passCtrl,
                isPassword:     true,
                textInputAction: TextInputAction.done,
                validator:      Validators.password,
                prefixIcon: const Icon(Icons.lock_outline_rounded,
                    size: AppDimensions.iconMD),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              // ── Ward assignment ─────────────────
              Text('Ward Assignment',
                  style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                'The leader will manage complaints and events '
                'in the selected ward.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppDimensions.spaceMD),

              wardsAsync.when(
                loading: () => const SizedBox(
                  height: 56,
                  child: Center(
                    child: LinearProgressIndicator(),
                  ),
                ),
                error: (e, _) => Text(
                  'Could not load wards: ${e.toString()}',
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.error),
                ),
                data: (wards) => AppDropdown<String>(
                  label:     'Assign Ward',
                  value:     _selectedWardId,
                  hint:      'Select a ward',
                  items: wards.map((w) {
                    return DropdownMenuItem<String>(
                      value: w.id,
                      child: Text(
                          '${w.wardName} (${w.wardCode})',
                          style: AppTextStyles.body),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setState(() => _selectedWardId = v),
                  validator: (_) => _selectedWardId == null
                      ? 'Please select a ward.'
                      : null,
                  prefixIcon: const Icon(Icons.map_outlined,
                      size: AppDimensions.iconMD),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              // ── Responsibilities ────────────────
              LeaderResponsibilitySelector(
                selected:  _responsibilities,
                onChanged: (updated) =>
                    setState(() => _responsibilities = updated),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              PrimaryButton(
                label:     'Create Leader',
                icon:      Icons.person_add_outlined,
                isLoading: state.isLoading,
                onPressed: _onSubmit,
              ),

              const SizedBox(height: AppDimensions.spaceXXL),
            ],
          ),
        ),
      ),
    );
  }
}