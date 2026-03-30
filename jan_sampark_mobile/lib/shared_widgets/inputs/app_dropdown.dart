import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Styled dropdown selector matching the app input design.
///
/// Usage:
///   AppDropdown<String>(
///     label:    'Gender',
///     value:    selectedGender,
///     items:    genderOptions,
///     onChanged: (v) => setState(() => selectedGender = v),
///   )
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.isEnabled = true,
    this.validator,
    this.prefixIcon,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final T? value;
  final String? hint;
  final bool isEnabled;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value:     value,
          items:     items,
          onChanged: isEnabled ? onChanged : null,
          validator: validator,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          style:         AppTextStyles.body,
          isExpanded:    true,
          dropdownColor: AppColors.white,
          decoration: InputDecoration(
            hintText:  hint ?? 'Select $label',
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}

/// Helper to build DropdownMenuItem list from a map.
///
/// Usage:
///   AppDropdown<String>(
///     items: dropdownItems({
///       'male':   'Male',
///       'female': 'Female',
///     }),
///     ...
///   )
List<DropdownMenuItem<String>> dropdownItems(Map<String, String> options) {
  return options.entries.map((e) {
    return DropdownMenuItem<String>(
      value: e.key,
      child: Text(e.value, style: AppTextStyles.body),
    );
  }).toList();
}