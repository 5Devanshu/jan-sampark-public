import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/file_picker_helper.dart';
import '../../../shared_widgets/inputs/image_upload_field.dart';

/// Registration Step 4 — ID Document Upload.
///
/// Voter uploads one photo of their government-issued ID.
/// The document is processed by the OCR background worker
/// after registration completes.
/// Upload is optional — voter can skip and verify later.
class RegistrationStepFour extends StatelessWidget {
  const RegistrationStepFour({
    super.key,
    required this.selectedDocumentType,
    required this.pickedFile,
    required this.onDocumentTypeChanged,
    required this.onFilePicked,
    required this.onSkip,
  });

  final String? selectedDocumentType;
  final PickedFile? pickedFile;
  final void Function(String?) onDocumentTypeChanged;
  final void Function(PickedFile) onFilePicked;
  final VoidCallback onSkip;

  static const _docTypes = [
    _DocType(
      value:    'voter_id',
      label:    'Voter ID (EPIC Card)',
      icon:     Icons.how_to_vote_outlined,
      hint:     'Upload a clear photo of your EPIC voter ID card.',
    ),
    _DocType(
      value:    'aadhaar',
      label:    'Aadhaar Card',
      icon:     Icons.credit_card_outlined,
      hint:     'Upload the front side of your Aadhaar card.',
    ),
    _DocType(
      value:    'driving_lic',
      label:    'Driving Licence',
      icon:     Icons.drive_eta_outlined,
      hint:     'Upload the front side of your driving licence.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedDoc = _docTypes.firstWhere(
      (d) => d.value == selectedDocumentType,
      orElse: () => _docTypes.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical:   AppDimensions.pagePaddingTop,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID Verification', style: AppTextStyles.heading2),
          const SizedBox(height: 6),
          Text(
            'Upload your government-issued ID to verify your identity. '
            'You can also complete this later from your profile.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppDimensions.spaceXXL),

          // ── Document type selector ────────────
          Text('Select ID Type', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 10),
          ...List.generate(_docTypes.length, (i) {
            final doc    = _docTypes[i];
            final isSelected = doc.value == selectedDocumentType ||
                (selectedDocumentType == null && i == 0);
            return GestureDetector(
              onTap: () => onDocumentTypeChanged(doc.value),
              child: Container(
                margin: const EdgeInsets.only(
                    bottom: AppDimensions.spaceMD),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryLight
                      : AppColors.white,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderGrey,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width:  42,
                      height: 42,
                      decoration: BoxDecoration(
                        color:        isSelected
                            ? AppColors.primary
                            : AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        doc.icon,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        doc.label,
                        style: isSelected
                            ? AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary)
                            : AppTextStyles.bodyMedium,
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: AppDimensions.spaceXL),

          // ── Upload box ───────────────────────
          ImageUploadField(
            label:          'Upload ${selectedDoc.label}',
            onPicked:       onFilePicked,
            allowDocuments: true,
            helperText:     selectedDoc.hint,
          ),

          const SizedBox(height: AppDimensions.spaceXL),

          // Upload tips
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            decoration: BoxDecoration(
              color:        AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tips_and_updates_outlined,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Photo Tips',
                      style: AppTextStyles.captionMedium.copyWith(
                          color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...[
                  'Ensure the ID is fully visible in the frame.',
                  'Good lighting — avoid glare or shadows.',
                  'Keep the image in focus and not blurry.',
                  'File size must be under 5MB.',
                ].map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style: AppTextStyles.captionMedium),
                        Expanded(
                          child: Text(tip,
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primaryDark)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spaceXL),

          // Skip option
          Center(
            child: GestureDetector(
              onTap: onSkip,
              child: Text(
                'Skip for now — I will verify later',
                style: AppTextStyles.bodySecondary.copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spaceXXL),
        ],
      ),
    );
  }
}

class _DocType {
  const _DocType({
    required this.value,
    required this.label,
    required this.icon,
    required this.hint,
  });

  final String   value;
  final String   label;
  final IconData icon;
  final String   hint;
}