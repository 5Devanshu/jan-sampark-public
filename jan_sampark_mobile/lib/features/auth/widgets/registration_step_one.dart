import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../shared_widgets/inputs/app_text_field.dart';
import '../../../shared_widgets/inputs/app_dropdown.dart';

/// Registration Step 1 — Personal Information.
///
/// Collects: full name, password, gender, date of birth, language.
class RegistrationStepOne extends StatelessWidget {
  const RegistrationStepOne({
    super.key,
    required this.fullNameCtrl,
    required this.passwordCtrl,
    required this.dobCtrl,
    required this.selectedGender,
    required this.selectedLanguage,
    required this.onGenderChanged,
    required this.onLanguageChanged,
  });

  final TextEditingController fullNameCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController dobCtrl;
  final String? selectedGender;
  final String? selectedLanguage;
  final void Function(String?) onGenderChanged;
  final void Function(String?) onLanguageChanged;

  static const _genderOptions = {
    'male':   'Male',
    'female': 'Female',
    'other':  'Other',
  };

  static const _languageOptions = {
    'en': 'English',
    'hi': 'हिन्दी (Hindi)',
    'mr': 'मराठी (Marathi)',
    'gu': 'ગુજરાતી (Gujarati)',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical:   AppDimensions.pagePaddingTop,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: AppTextStyles.heading2),
          const SizedBox(height: 6),
          Text(
            'Tell us about yourself to set up your account.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppDimensions.spaceXXL),

          // Full name
          AppTextField(
            label:          'Full Name',
            hint:           'Your name as on your ID',
            controller:     fullNameCtrl,
            textInputAction: TextInputAction.next,
            validator:      Validators.fullName,
            prefixIcon: const Icon(Icons.person_outline,
                size: AppDimensions.iconMD),
            autofillHints: const [AutofillHints.name],
          ),

          const SizedBox(height: AppDimensions.spaceXL),

          // Password
          AppTextField(
            label:          'Create Password',
            hint:           'Min 8 chars, uppercase, digit, special char',
            controller:     passwordCtrl,
            isPassword:     true,
            textInputAction: TextInputAction.next,
            validator:      Validators.password,
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                size: AppDimensions.iconMD),
            autofillHints: const [AutofillHints.newPassword],
          ),

          const SizedBox(height: AppDimensions.spaceXL),

          // Gender
          AppDropdown<String>(
            label:     'Gender',
            value:     selectedGender,
            items:     dropdownItems(_genderOptions),
            onChanged: onGenderChanged,
            validator: (_) => selectedGender == null
                ? 'Please select your gender.'
                : null,
            prefixIcon: const Icon(Icons.wc_outlined,
                size: AppDimensions.iconMD),
          ),

          const SizedBox(height: AppDimensions.spaceXL),

          // Date of birth
          AppTextField(
            label:          'Date of Birth',
            hint:           'YYYY-MM-DD',
            controller:     dobCtrl,
            keyboardType:   TextInputType.datetime,
            textInputAction: TextInputAction.next,
            validator:      Validators.dateOfBirth,
            prefixIcon: const Icon(Icons.cake_outlined,
                size: AppDimensions.iconMD),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'[\d\-]')),
              LengthLimitingTextInputFormatter(10),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceXL),

          // Language preference
          AppDropdown<String>(
            label:     'Preferred Language',
            value:     selectedLanguage,
            items:     dropdownItems(_languageOptions),
            onChanged: onLanguageChanged,
            validator: (_) => selectedLanguage == null
                ? 'Please select your preferred language.'
                : null,
            prefixIcon: const Icon(Icons.language_outlined,
                size: AppDimensions.iconMD),
          ),

          const SizedBox(height: AppDimensions.spaceXXL),
        ],
      ),
    );
  }
}