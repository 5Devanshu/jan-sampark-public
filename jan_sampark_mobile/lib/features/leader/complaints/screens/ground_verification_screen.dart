import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/file_picker_helper.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/inputs/image_upload_field.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../providers/leader_complaint_provider.dart';

/// Ground verification screen — Leader visits the site
/// and documents findings with photos and notes.
///
/// Submits as an internal note with the field report.
class GroundVerificationScreen extends ConsumerStatefulWidget {
  const GroundVerificationScreen({super.key, required this.complaintId});
  final String complaintId;

  @override
  ConsumerState<GroundVerificationScreen> createState() =>
      _GroundVerificationScreenState();
}

class _GroundVerificationScreenState
    extends ConsumerState<GroundVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _findingsCtrl = TextEditingController();
  final _actionCtrl = TextEditingController();
  final List<PickedFile> _photos = [];

  @override
  void dispose() {
    _findingsCtrl.dispose();
    _actionCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;

    // Build the internal note text from findings + action taken
    final noteText =
        '''
GROUND VERIFICATION REPORT
═══════════════════════════
Findings: ${_findingsCtrl.text.trim()}

Action Taken: ${_actionCtrl.text.trim().isEmpty ? 'None yet' : _actionCtrl.text.trim()}

Photos attached: ${_photos.length}
    '''
            .trim();

    final success = await ref
        .read(complaintActionProvider.notifier)
        .addNote(
          widget.complaintId,
          noteText: noteText,
          isInternal: false, // Visible to voter
        );

    if (!mounted) return;
    if (success) {
      context.showSuccess('Ground verification recorded.');
      context.pop();
    } else {
      context.showError(ref.read(complaintActionProvider).errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(complaintActionProvider);

    return AppScaffold(
      title: 'Ground Verification',
      isBlueAppBar: true,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spaceXL),

              // Info banner
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceMD),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Document your on-site visit findings. '
                        'This report will be visible to the voter.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              // Findings
              Text('Site Findings', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                'What did you observe at the location?',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppDimensions.spaceMD),

              AppTextField(
                label: 'Findings',
                hint:
                    'e.g. Water main pipe broken near '
                    'lane 4. Affecting 15 households.',
                controller: _findingsCtrl,
                maxLines: 4,
                maxLength: 800,
                textInputAction: TextInputAction.next,
                validator: Validators.minLength('Findings', 10),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Action taken
              Text('Action Taken', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spaceSM),
              Text(
                'What steps did you take or initiate?',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppDimensions.spaceMD),

              AppTextField(
                label: 'Action Taken (optional)',
                hint:
                    'e.g. Contacted BMC water dept. '
                    'They will attend within 24hrs.',
                controller: _actionCtrl,
                maxLines: 3,
                maxLength: 500,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Photo upload
              ImageUploadField.multiple(
                label: 'Site Photos',
                onPickedMultiple: (files) => setState(() {
                  _photos.clear();
                  _photos.addAll(files);
                }),
                maxCount: 3,
                helperText: 'Upload up to 3 photos of the site.',
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              PrimaryButton(
                label: 'Submit Verification Report',
                icon: Icons.verified_outlined,
                isLoading: actionState.isLoading,
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
