import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../models/chat_models.dart';
import 'reaction_picker.dart';
import 'feedback_input.dart';

/// Single message bubble in the chat room.
///
/// Displays:
///   - Sender avatar (initials)
///   - Sender name + role badge
///   - Message content
///   - Timestamp
///   - Reaction row (tap to open picker)
///   - Feedback button (tap to open feedback sheet)
///   - Pinned indicator if isPinned
///
/// All messages from Leaders/Corporators appear
/// in the same left-aligned style (no right-aligned "own" messages
/// since voters only read and react — they do not post messages).
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isReacting,
    required this.isSubmittingFeedback,
    required this.onReact,
    required this.onFeedback,
  });

  final ChatMessage message;
  final bool isReacting;
  final bool isSubmittingFeedback;
  final void Function(String emoji) onReact;
  final void Function(String text) onFeedback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pagePaddingH,
        vertical: AppDimensions.spaceSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Pinned indicator ────────────────────
          if (message.isPinned)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spaceXS),
              child: Row(
                children: [
                  const Icon(
                    Icons.push_pin_rounded,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pinned message',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

          // ── Sender row ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _SenderAvatar(name: message.senderName),
              const SizedBox(width: 10),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + role + time
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  message.senderName,
                                  style: AppTextStyles.bodySemiBold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              _SenderRoleBadge(role: message.senderRole),
                            ],
                          ),
                        ),
                        Text(
                          DateFormatter.timeAgo(message.createdAt),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Message bubble
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spaceMD),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        border: Border.all(color: AppColors.borderGrey),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(message.content, style: AppTextStyles.body),
                    ),

                    const SizedBox(height: 8),

                    // ── Reactions + Feedback row ──────
                    Row(
                      children: [
                        // Reaction row
                        Expanded(
                          child: ReactionRow(
                            reactions: message.reactions,
                            isReacting: isReacting,
                            onTap: () => showReactionPicker(
                              context: context,
                              currentEmoji: message.myReaction,
                              onSelected: onReact,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Feedback button
                        _FeedbackButton(
                          feedbackCount: message.feedbackCount,
                          isSubmitting: isSubmittingFeedback,
                          onTap: () async {
                            final text = await showFeedbackInput(
                              context: context,
                              messagePreview: message.content,
                            );
                            if (text != null && text.length >= 3) {
                              onFeedback(text);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sender Avatar
// ─────────────────────────────────────────────

class _SenderAvatar extends StatelessWidget {
  const _SenderAvatar({required this.name});
  final String name;

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          _initials,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sender Role Badge
// ─────────────────────────────────────────────

class _SenderRoleBadge extends StatelessWidget {
  const _SenderRoleBadge({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final label = switch (role) {
      'corporator' => 'Corporator',
      'leader' => 'Leader',
      _ => role,
    };
    final color = switch (role) {
      'corporator' => AppColors.primary,
      'leader' => AppColors.primaryAccent,
      _ => AppColors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Feedback Button
// ─────────────────────────────────────────────

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({
    required this.feedbackCount,
    required this.isSubmitting,
    required this.onTap,
  });

  final int feedbackCount;
  final bool isSubmitting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isSubmitting) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.edit_note_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              feedbackCount > 0 ? 'Feedback ($feedbackCount)' : 'Feedback',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
