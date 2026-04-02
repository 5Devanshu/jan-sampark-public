import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/inputs/app_dropdown.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/dialogs/confirm_dialog.dart';
import '../providers/corporator_complaint_provider.dart';

class CorporatorRejectScreen extends ConsumerStatefulWidget {
  const CorporatorRejectScreen({
    super.key,
    required this.complaintId,
  });
  final String complaintId;

  @override
  ConsumerState<CorporatorRejectScreen> createState() =>
      _CorporatorRejectScreenState();
}

class _CorporatorRejectScreenState
    extends ConsumerState<CorporatorRejectScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _customCtrl  = TextEditingController();
  String? _selected;
  bool    _useCustom = false;

  static const _reasons = {
    'duplicate':        'Duplicate — already raised and resolved',
    'out_of_scope':     'Outside corporator area scope',
    'no_merit':         'Complaint lacks sufficient merit',
    'already_resolved': 'Issue resolved before filing',
    'fake':             'False or misleading complaint',
    'other':            'Other (specify below)',
  };

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;
    if (_selected == null) {
      context.showError('Please select a rejection reason.');
      return;
    }

    final confirmed = await showConfirmDialog(
      context:       context,
      title:         'Reject Complaint',
      message:       'This will permanently reject the complaint '
          'and notify the voter. This cannot be undone.',
      confirmLabel:  'Yes, Reject',
      isDestructive: true,
      icon:          Icons.cancel_outlined,
    );

    if (confirmed != true || !mounted) return;

    final reason = _useCustom
        ? _customCtrl.text.trim()
        : (_reasons[_selected] ?? _selected!);

    final success = await ref
        .read(corporatorComplaintActionProvider.notifier)
        .reject(widget.complaintId, reason: reason);

    if (!mounted) return;
    if (success) {
      context.showSuccess('Complaint rejected.');
      context.pop();
    } else {
      context.showError(ref
          .read(corporatorComplaintActionProvider)
          .errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState =
        ref.watch(corporatorComplaintActionProvider);

    return AppScaffold(
      title:       'Reject Complaint',
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

              Container(
                padding: const EdgeInsets.all(
                    AppDimensions.spaceMD),
                decoration: BoxDecoration(
                  color:        AppColors.errorLight,
                  borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMD),
                  border: Border.all(
                      color: AppColors.errorBorder),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_rounded,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Rejection is permanent and cannot be '
                        'undone. The voter will be notified '
                        'immediately.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              Text('Rejection Reason',
                  style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spaceMD),

              AppDropdown<String>(
                label:     'Select Reason',
                value:     _selected,
                items:     dropdownItems(_reasons),
                onChanged: (v) => setState(() {
                  _selected  = v;
                  _useCustom = v == 'other';
                }),
                validator: (_) => _selected == null
                    ? 'Please select a reason.'
                    : null,
              ),

              if (_useCustom) ...[
                const SizedBox(height: AppDimensions.spaceXL),
                AppTextField(
                  label:          'Custom Reason',
                  hint:           'Describe why this complaint is rejected.',
                  controller:     _customCtrl,
                  maxLines:       3,
                  maxLength:      500,
                  textInputAction: TextInputAction.done,
                  validator: Validators.minLength('Reason', 5),
                ),
              ],

              const SizedBox(height: AppDimensions.spaceXXL),

              PrimaryButton(
                label:           'Reject Complaint',
                icon:            Icons.cancel_outlined,
                backgroundColor: AppColors.error,
                isLoading:       actionState.isLoading,
                onPressed:       _onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}