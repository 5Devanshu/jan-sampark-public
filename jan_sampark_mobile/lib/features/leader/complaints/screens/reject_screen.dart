import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/inputs/app_dropdown.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/dialogs/confirm_dialog.dart';
import '../providers/leader_complaint_provider.dart';

class RejectScreen extends ConsumerStatefulWidget {
  const RejectScreen({super.key, required this.complaintId});
  final String complaintId;

  @override
  ConsumerState<RejectScreen> createState() => _RejectScreenState();
}

class _RejectScreenState extends ConsumerState<RejectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customCtrl = TextEditingController();
  String? _selectedReason;
  bool _useCustom = false;

  static const _commonReasons = {
    'duplicate': 'Duplicate complaint — already filed',
    'out_of_ward': 'Outside my ward jurisdiction',
    'insufficient': 'Insufficient information provided',
    'resolved': 'Issue already resolved',
    'invalid': 'Invalid or spam complaint',
    'other': 'Other reason (specify below)',
  };

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedReason == null) {
      context.showError('Please select a rejection reason.');
      return;
    }

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Reject Complaint',
      message:
          'This complaint will be permanently rejected. '
          'The voter will be notified with the reason.',
      confirmLabel: 'Yes, Reject',
      isDestructive: true,
      icon: Icons.cancel_outlined,
    );

    if (confirmed != true || !mounted) return;

    final reason = _useCustom
        ? _customCtrl.text.trim()
        : _commonReasons[_selectedReason] ?? _selectedReason!;

    final success = await ref
        .read(complaintActionProvider.notifier)
        .reject(widget.complaintId, reason: reason);

    if (!mounted) return;
    if (success) {
      context.showSuccess('Complaint rejected.');
      context.pop();
    } else {
      context.showError(ref.read(complaintActionProvider).errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(complaintActionProvider);

    return AppScaffold(
      title: 'Reject Complaint',
      isBlueAppBar: true,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spaceXL),

              // Warning banner
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceMD),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(color: AppColors.errorBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Rejection is permanent and cannot be '
                        'undone. The voter will be notified '
                        'with the reason provided.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              Text('Rejection Reason', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                'Select or write the reason this complaint '
                'cannot be accepted.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppDimensions.spaceMD),

              AppDropdown<String>(
                label: 'Select Reason',
                value: _selectedReason,
                items: dropdownItems(_commonReasons),
                onChanged: (v) => setState(() {
                  _selectedReason = v;
                  _useCustom = v == 'other';
                }),
                validator: (_) =>
                    _selectedReason == null ? 'Please select a reason.' : null,
              ),

              if (_useCustom) ...[
                const SizedBox(height: AppDimensions.spaceXL),
                AppTextField(
                  label: 'Custom Reason',
                  hint: 'Describe why this complaint is rejected.',
                  controller: _customCtrl,
                  maxLines: 3,
                  maxLength: 500,
                  textInputAction: TextInputAction.done,
                  validator: Validators.minLength('Reason', 5),
                ),
              ],

              const SizedBox(height: AppDimensions.spaceXXL),

              PrimaryButton(
                label: 'Reject Complaint',
                icon: Icons.cancel_outlined,
                backgroundColor: AppColors.error,
                isLoading: actionState.isLoading,
                onPressed: _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
