import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../providers/leader_complaint_provider.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({super.key, required this.complaintId});
  final String complaintId;

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  bool _isInternal = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(complaintActionProvider.notifier)
        .addNote(
          widget.complaintId,
          noteText: _noteCtrl.text.trim(),
          isInternal: _isInternal,
        );

    if (!mounted) return;
    if (success) {
      context.showSuccess('Note added successfully.');
      context.pop();
    } else {
      context.showError(ref.read(complaintActionProvider).errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(complaintActionProvider);

    return AppScaffold(
      title: 'Add Field Note',
      isBlueAppBar: true,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spaceXL),

              Text('Field Observation', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                'Document your field visit findings or '
                'updates about this complaint.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppDimensions.spaceXL),

              AppTextField(
                label: 'Note',
                hint:
                    'e.g. Visited the site. Water '
                    'pump is damaged. Municipal team informed.',
                controller: _noteCtrl,
                maxLines: 5,
                maxLength: 1000,
                textInputAction: TextInputAction.done,
                validator: Validators.minLength('Note', 3),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Internal toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isInternal
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _isInternal
                          ? AppColors.warning
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Internal note',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            _isInternal
                                ? 'Visible only to Leaders '
                                      'and Corporator'
                                : 'Visible to the voter too',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isInternal,
                      onChanged: (v) => setState(() => _isInternal = v),
                    ),
                  ],
                ),
              ),

              if (_isInternal) ...[
                const SizedBox(height: AppDimensions.spaceSM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This note will NOT be shown to the voter.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppDimensions.spaceXXL),

              PrimaryButton(
                label: 'Add Note',
                icon: Icons.note_add_outlined,
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
