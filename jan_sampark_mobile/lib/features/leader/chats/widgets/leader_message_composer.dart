import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Message composer bar for Leader/Corporator chat rooms.
/// Voters do not see this — leaders and corporators can post.
class LeaderMessageComposer extends StatefulWidget {
  const LeaderMessageComposer({
    super.key,
    required this.onSend,
    required this.isSending,
    this.isEnabled = true,
  });

  final void Function(String content) onSend;
  final bool isSending;
  final bool isEnabled;

  @override
  State<LeaderMessageComposer> createState() => _LeaderMessageComposerState();
}

class _LeaderMessageComposerState extends State<LeaderMessageComposer> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || widget.isSending) return;
    widget.onSend(text);
    _ctrl.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.pagePaddingH,
        AppDimensions.spaceSM,
        AppDimensions.pagePaddingH,
        AppDimensions.spaceSM + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderGrey)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                enabled: widget.isEnabled && !widget.isSending,
                maxLines: null,
                style: AppTextStyles.body,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: widget.isEnabled
                      ? 'Type a message...'
                      : 'Chat is closed',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Send button
          GestureDetector(
            onTap: _hasText && !widget.isSending ? _send : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _hasText && !widget.isSending
                    ? AppColors.primary
                    : AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: widget.isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: _hasText
                          ? AppColors.white
                          : AppColors.primaryAccent,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
