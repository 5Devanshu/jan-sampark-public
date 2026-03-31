import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Free-text input for open_ended polls.
class OpenEndedPoll extends StatefulWidget {
  const OpenEndedPoll({
    super.key,
    required this.onChanged,
    this.isEnabled = true,
  });

  final void Function(String text) onChanged;
  final bool isEnabled;

  @override
  State<OpenEndedPoll> createState() => _OpenEndedPollState();
}

class _OpenEndedPollState extends State<OpenEndedPoll> {
  final _ctrl = TextEditingController();
  int _charCount = 0;
  static const _max = 1000;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      setState(() => _charCount = _ctrl.text.length);
      widget.onChanged(_ctrl.text);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Response', style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        TextField(
          controller: _ctrl,
          enabled: widget.isEnabled,
          maxLines: 6,
          maxLength: _max,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Type your response here...',
            counterText: '$_charCount / $_max',
            counterStyle: AppTextStyles.caption,
            filled: true,
            fillColor: AppColors.surfaceGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text('Minimum 1 character required.', style: AppTextStyles.fieldHelper),
      ],
    );
  }
}
