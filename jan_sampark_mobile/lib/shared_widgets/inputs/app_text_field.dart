import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Standard labelled text input field for Jan Sampark.
///
/// Features:
///   - Floating label above the field
///   - Optional prefix / suffix icons
///   - Password toggle (when isPassword=true)
///   - Character counter
///   - Error and helper text
///
/// Usage:
///   AppTextField(
///     label:       'Mobile Number',
///     hint:        '10-digit mobile number',
///     controller:  _mobileCtrl,
///     keyboardType: TextInputType.phone,
///     validator:   Validators.mobile,
///   )
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.keyboardType  = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.isPassword    = false,
    this.isReadOnly    = false,
    this.isEnabled     = true,
    this.maxLines      = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.helperText,
    this.autofillHints,
    this.autofocus     = false,
    this.onTap,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool isPassword;
  final bool isReadOnly;
  final bool isEnabled;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final String? helperText;
  final List<String>? autofillHints;
  final bool autofocus;
  final VoidCallback? onTap;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ───────────────────────────────
        Text(widget.label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 6),

        // ── Input ───────────────────────────────
        TextFormField(
          controller:      widget.controller,
          focusNode:       widget.focusNode,
          initialValue:    widget.initialValue,
          keyboardType:    widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText:     widget.isPassword && _obscureText,
          readOnly:        widget.isReadOnly,
          enabled:         widget.isEnabled,
          maxLines:        widget.isPassword ? 1 : widget.maxLines,
          minLines:        widget.minLines,
          maxLength:       widget.maxLength,
          autofocus:       widget.autofocus,
          autofillHints:   widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          style:           AppTextStyles.body,
          onChanged:       widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap:           widget.onTap,
          validator:       widget.validator,
          buildCounter: widget.maxLength != null
              ? (_, {required currentLength, required isFocused, maxLength}) {
                  return Text(
                    '$currentLength / $maxLength',
                    style: AppTextStyles.caption,
                  );
                }
              : null,
          decoration: InputDecoration(
            hintText:   widget.hint,
            hintStyle:  AppTextStyles.body.copyWith(
              color: AppColors.textHint,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    onTap: () =>
                        setState(() => _obscureText = !_obscureText),
                    child: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size:  AppDimensions.iconMD,
                    ),
                  )
                : widget.suffixIcon,
            helperText: widget.helperText,
          ),
        ),
      ],
    );
  }
}