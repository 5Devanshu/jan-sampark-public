import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/constants/app_constants.dart';

/// 6-box OTP input with automatic focus advancement.
///
/// When the user types a digit the focus moves to the next box.
/// When the user backspaces on an empty box the focus moves back.
/// Calls [onCompleted] when all 6 digits are entered.
///
/// Usage:
///   OtpInputField(
///     onCompleted: (otp) => ref.read(otpProvider.notifier).verify(otp),
///   )
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.length = AppConstants.otpLength,
    this.isEnabled = true,
    this.hasError = false,
  });

  final void Function(String otp) onCompleted;
  final void Function(String otp)? onChanged;
  final int length;
  final bool isEnabled;
  final bool hasError;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes  = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes)  { f.dispose(); }
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.isEmpty) {
      // Backspace on empty box — move focus back
      if (index > 0) _focusNodes[index - 1].requestFocus();
      return;
    }

    // Only keep the last character (handles paste)
    final digit = value[value.length - 1];
    _controllers[index].text = digit;
    _controllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: digit.length),
    );

    // Notify parent
    final otp = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(otp);

    if (index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
      if (otp.length == widget.length) {
        widget.onCompleted(otp);
      }
    }
  }

  /// Clears all boxes and returns focus to first box.
  void clear() {
    for (final c in _controllers) { c.clear(); }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        final isActive = _focusNodes[i].hasFocus;
        final hasValue = _controllers[i].text.isNotEmpty;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.otpBoxSpacing / 2,
          ),
          child: SizedBox(
            width:  AppDimensions.otpBoxWidth,
            height: AppDimensions.otpBoxHeight,
            child: TextFormField(
              controller:     _controllers[i],
              focusNode:      _focusNodes[i],
              enabled:        widget.isEnabled,
              keyboardType:   TextInputType.number,
              textAlign:      TextAlign.center,
              style:          AppTextStyles.heading2,
              maxLength:      2, // 2 so replace works
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled:      true,
                fillColor:   hasValue
                    ? AppColors.primaryLight
                    : AppColors.surfaceGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.otpBoxRadius),
                  borderSide: BorderSide(
                    color: widget.hasError
                        ? AppColors.error
                        : AppColors.inputBorder,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.otpBoxRadius),
                  borderSide: BorderSide(
                    color: widget.hasError
                        ? AppColors.error
                        : (hasValue ? AppColors.primary : AppColors.inputBorder),
                    width: hasValue ? 1.5 : 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.otpBoxRadius),
                  borderSide: BorderSide(
                    color: widget.hasError
                        ? AppColors.error
                        : AppColors.primary,
                    width: 2.0,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) => _onDigitEntered(i, v),
            ),
          ),
        );
      }),
    );
  }
}