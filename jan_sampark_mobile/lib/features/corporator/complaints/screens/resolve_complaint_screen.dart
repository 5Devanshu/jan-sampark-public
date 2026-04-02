import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../providers/corporator_complaint_provider.dart';

class ResolveComplaintScreen extends ConsumerStatefulWidget {
  const ResolveComplaintScreen({
    super.key,
    required this.complaintId,
  });
  final String complaintId;

  @override
  ConsumerState<ResolveComplaintScreen> createState() =>
      _ResolveComplaintScreenState();
}

class _ResolveComplaintScreenState
    extends ConsumerState<ResolveComplaintScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(corporatorComplaintActionProvider.notifier)
        .resolve(
          widget.complaintId,
          resolutionNotes: _notesCtrl.text.trim(),
        );

    if (!mounted) return;
    if (success) {
      context.showSuccess('Complaint marked as resolved.');
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
      title:       'Mark Resolved',
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

              // Info banner
              Container(
                padding: const EdgeInsets.all(
                    AppDimensions.spaceMD),
                decoration: BoxDecoration(
                  color:        AppColors.successLight,
                  borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMD),
                  border: Border.all(
                      color: AppColors.successBorder),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size:  18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Marking this complaint as resolved will '
                        'notify the voter. Provide clear resolution '
                        'notes so the voter understands what was done.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              Text('Resolution Notes',
                  style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                'Describe what action was taken to resolve this '
                'complaint. This will be visible to the voter.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppDimensions.spaceMD),

              AppTextField(
                label:          'Resolution Notes',
                hint:           'e.g. Water supply restored after '
                    'pipe replacement on 15 Jan. Normal supply '
                    'resumed by 6pm.',
                controller:     _notesCtrl,
                maxLines:       5,
                maxLength:      1000,
                textInputAction: TextInputAction.done,
                validator: Validators.minLength(
                    'Resolution Notes', 10),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              PrimaryButton(
                label:           'Mark as Resolved',
                icon:            Icons.check_circle_outline_rounded,
                backgroundColor: AppColors.success,
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