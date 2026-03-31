import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Bottom sheet text feedback input for a specific message.
///
/// Voter types their feedback — sentiment is computed by backend.
/// Max 1000 characters.
///
/// Usage:
///   showFeedbackInput(
///     context:    context,
///     messagePreview: message.content.substring(0, 80),
///     onSubmit:   (text) => notifier.submitFeedback(id, text),
///     isLoading:  false,
///   );
Future<String?> showFeedbackInput({
  required BuildContext context,
  required String messagePreview,
}) {
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.bottomSheetRadius),
      ),
    ),
    builder: (ctx) => _FeedbackInputSheet(messagePreview: messagePreview),
  );
}

class _FeedbackInputSheet extends StatefulWidget {
  const _FeedbackInputSheet({required this.messagePreview});
  final String messagePreview;

  @override
  State<_FeedbackInputSheet> createState() => _FeedbackInputSheetState();
}

class _FeedbackInputSheetState extends State<_FeedbackInputSheet> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  int _charCount = 0;

  static const _maxLength = 1000;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      setState(() => _charCount = _ctrl.text.length);
    });
    // Auto-focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.length < 3) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH,
          AppDimensions.spaceLG,
          AppDimensions.pagePaddingH,
          AppDimensions.spaceXL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            Text('Share Your Feedback', style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.spaceSM),

            // Message preview
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceMD),
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.messagePreview.length > 100
                          ? '${widget.messagePreview.substring(0, 100)}…'
                          : widget.messagePreview,
                      style: AppTextStyles.bodySecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Feedback text input
            TextField(
              controller: _ctrl,
              focusNode: _focusNode,
              maxLines: 4,
              maxLength: _maxLength,
              style: AppTextStyles.body,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Write your feedback here...',
                counterText: '$_charCount / $_maxLength',
                counterStyle: AppTextStyles.caption,
                filled: true,
                fillColor: AppColors.surfaceGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.inputRadius,
                  ),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.inputRadius,
                  ),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightMD,
              child: ElevatedButton(
                onPressed: _charCount >= 3 ? _submit : null,
                child: Text(
                  'Submit Feedback',
                  style: AppTextStyles.buttonLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
