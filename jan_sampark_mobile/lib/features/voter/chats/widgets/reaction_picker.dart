import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/chat_models.dart';

/// Available reaction emojis matching the backend ReactionEmoji enum.
const _kEmojis = ['👍', '❤️', '🎉', '🙏', '👏', '😢', '😡'];

/// Bottom sheet emoji reaction picker.
///
/// Shows all 7 supported emojis.
/// Highlights the currently selected emoji.
/// Tapping the active emoji triggers removal (toggle off).
///
/// Usage:
///   showReactionPicker(
///     context:     context,
///     currentEmoji: message.myReaction,
///     onSelected:   (emoji) => notifier.react(messageId, emoji),
///   );
Future<void> showReactionPicker({
  required BuildContext context,
  required String? currentEmoji,
  required void Function(String emoji) onSelected,
}) {
  return showModalBottomSheet(
    context:        context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.bottomSheetRadius),
      ),
    ),
    builder: (_) => _ReactionPickerSheet(
      currentEmoji: currentEmoji,
      onSelected:   onSelected,
    ),
  );
}

class _ReactionPickerSheet extends StatelessWidget {
  const _ReactionPickerSheet({
    required this.currentEmoji,
    required this.onSelected,
  });

  final String? currentEmoji;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical:   AppDimensions.spaceLG,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width:  40, height: 4,
                decoration: BoxDecoration(
                  color:        AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            Text(
              'React to this message',
              style: AppTextStyles.heading3,
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            Text(
              currentEmoji != null
                  ? 'Tap the same emoji to remove your reaction.'
                  : 'Choose an emoji to react.',
              style: AppTextStyles.bodySecondary,
            ),

            const SizedBox(height: AppDimensions.spaceXL),

            // Emoji grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _kEmojis.map((emoji) {
                final isActive = emoji == currentEmoji;
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelected(emoji);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width:  52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryLight
                          : AppColors.surfaceGrey,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLG),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : Colors.transparent,
                        width: isActive ? 2 : 0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppDimensions.spaceMD),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reaction Row — inline display on messages
// ─────────────────────────────────────────────

/// Compact inline reaction row shown below each message.
///
/// Tapping the row opens the full reaction picker.
class ReactionRow extends StatelessWidget {
  const ReactionRow({
    super.key,
    required this.reactions,
    required this.isReacting,
    required this.onTap,
  });

  final List<ReactionSummary> reactions;
  final bool         isReacting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty && !isReacting) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color:        AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😊',
                  style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                'React',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      );
    }

    if (isReacting) {
      return const SizedBox(
        width: 20, height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      );
    }

    return Wrap(
      spacing:    6,
      runSpacing: 4,
      children: [
        ...reactions.map((r) => GestureDetector(
              onTap: onTap,
              child: _ReactionChip(reaction: r),
            )),
        // Add reaction button
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color:        AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: const Text('+',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary)),
          ),
        ),
      ],
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({required this.reaction});
  final ReactionSummary reaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: reaction.reacted
            ? AppColors.primaryLight
            : AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: reaction.reacted
              ? AppColors.primary
              : AppColors.borderGrey,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(reaction.emoji,
              style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            '${reaction.count}',
            style: AppTextStyles.captionMedium.copyWith(
              color: reaction.reacted
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

