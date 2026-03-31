import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../models/chat_models.dart';

/// Chat list tile for the chats screen.
///
/// Shows title, creator, message count and last activity.
class ChatListTile extends StatelessWidget {
  const ChatListTile({super.key, required this.chat, required this.onTap});

  final ChatModel chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.cardPaddingH),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: chat.isPinned
                    ? AppColors.primary
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                chat.isPinned ? Icons.push_pin_rounded : Icons.forum_outlined,
                color: chat.isPinned ? AppColors.white : AppColors.primary,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // ── Content ───────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          chat.title,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.timeAgo(
                          chat.lastMessageAt ?? chat.createdAt,
                        ),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Creator
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(chat.createdByName, style: AppTextStyles.caption),
                      const SizedBox(width: 6),
                      _RoleBadge(role: chat.createdByRole),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Message count + open status
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${chat.messageCount} message'
                        '${chat.messageCount == 1 ? '' : 's'}',
                        style: AppTextStyles.caption,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: chat.isOpen
                              ? AppColors.successLight
                              : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          chat.isOpen ? 'Open' : 'Closed',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: chat.isOpen
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Chevron ───────────────────────────
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
