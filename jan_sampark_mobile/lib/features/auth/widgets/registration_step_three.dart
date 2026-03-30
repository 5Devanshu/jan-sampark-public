import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared_widgets/inputs/app_dropdown.dart';
import '../../../shared_widgets/inputs/app_text_field.dart';

/// Registration Step 3 — Demographic Profile.
///
/// Collects: education, occupation, income range,
/// family adults count, family kids count, religion.
/// All fields optional — helps Corporator analytics.
class RegistrationStepThree extends StatelessWidget {
  const RegistrationStepThree({
    super.key,
    required this.selectedReligion,
    required this.selectedEducation,
    required this.selectedOccupation,
    required this.selectedIncomeRange,
    required this.familyAdultsCtrl,
    required this.familyKidsCtrl,
    required this.onReligionChanged,
    required this.onEducationChanged,
    required this.onOccupationChanged,
    required this.onIncomeRangeChanged,
  });

  final String? selectedReligion;
  final String? selectedEducation;
  final String? selectedOccupation;
  final String? selectedIncomeRange;
  final TextEditingController familyAdultsCtrl;
  final TextEditingController familyKidsCtrl;
  final void Function(String?) onReligionChanged;
  final void Function(String?) onEducationChanged;
  final void Function(String?) onOccupationChanged;
  final void Function(String?) onIncomeRangeChanged;

  static const _religionOptions = {
    'hindu':      'Hindu',
    'muslim':     'Muslim',
    'christian':  'Christian',
    'sikh':       'Sikh',
    'buddhist':   'Buddhist',
    'jain':       'Jain',
    'other':      'Other',
    'prefer_not': 'Prefer not to say',
  };

  static const _educationOptions = {
    'no_formal':    'No Formal Education',
    'primary':      'Primary School',
    'secondary':    'Secondary School',
    'higher_secondary': 'Higher Secondary (12th)',
    'diploma':      'Diploma',
    'graduate':     'Graduate',
    'post_graduate': 'Post Graduate',
    'doctorate':    'Doctorate',
  };

  static const _occupationOptions = {
    'employed_private': 'Private Sector Employee',
    'employed_govt':    'Government Employee',
    'self_employed':    'Self-Employed / Business',
    'farmer':           'Farmer',
    'student':          'Student',
    'homemaker':        'Homemaker',
    'retired':          'Retired',
    'unemployed':       'Unemployed',
    'other':            'Other',
  };

  static const _incomeOptions = {
    'below_1l':   'Below ₹1 Lakh',
    '1l_3l':      '₹1L – ₹3L',
    '3l_6l':      '₹3L – ₹6L',
    '6l_10l':     '₹6L – ₹10L',
    '10l_25l':    '₹10L – ₹25L',
    'above_25l':  'Above ₹25 Lakh',
    'prefer_not': 'Prefer not to say',
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
          Text('Demographic Profile', style: AppTextStyles.heading2),
          const SizedBox(height: 6),
          Text(
            'Optional — helps your representative serve you better.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppDimensions.spaceMD),

          // Optional note
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            decoration: BoxDecoration(
              color:        AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline_rounded,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This information is never shared publicly. '
                    'Only your Corporator sees aggregate statistics.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spaceXL),

          // Religion
          AppDropdown<String>(
            label:     'Religion',
            value:     selectedReligion,
            items:     dropdownItems(_religionOptions),
            onChanged: onReligionChanged,
            prefixIcon: const Icon(Icons.diversity_3_outlined,
                size: AppDimensions.iconMD),
          ),

          const SizedBox(height: AppDimensions.spaceXL),

          // Education
          AppDropdown<String>(
            label:     'Education Level',
            value:     selectedEducation,
            items:     dropdownItems(_educationOptions),
            onChanged: onEducationChanged,
            prefixIcon: const Icon(Icons.school_outlined,
                size: AppDimensions.iconMD),
          ),

          const SizedBox(height: AppDimensions.spaceXL),

          // Occupation
          AppDropdown<String>(
            label:     'Occupation',
            value:     selectedOccupation,
            items:     dropdownItems(_occupationOptions),
            onChanged: onOccupationChanged,
            prefixIcon: const Icon(Icons.work_outline_rounded,
                size: AppDimensions.iconMD),
          ),

          const SizedBox(height: AppDimensions.spaceXL),

          // Income range
          AppDropdown<String>(
            label:     'Annual Household Income',
            value:     selectedIncomeRange,
            items:     dropdownItems(_incomeOptions),
            onChanged: onIncomeRangeChanged,
            prefixIcon: const Icon(Icons.currency_rupee_rounded,
                size: AppDimensions.iconMD),
          ),

          const SizedBox(height: AppDimensions.spaceXL),

          // Family size row
          Text('Family Size', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label:          'Adults (18+)',
                  hint:           '0',
                  controller:     familyAdultsCtrl,
                  keyboardType:   TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  prefixIcon: const Icon(Icons.people_outline,
                      size: AppDimensions.iconMD),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AppTextField(
                  label:          'Children (< 18)',
                  hint:           '0',
                  controller:     familyKidsCtrl,
                  keyboardType:   TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  prefixIcon: const Icon(Icons.child_care_outlined,
                      size: AppDimensions.iconMD),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceXXL),
        ],
      ),
    );
  }
}