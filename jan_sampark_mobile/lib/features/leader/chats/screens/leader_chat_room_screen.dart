import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../voter/chats/widgets/message_bubble.dart';
import '../providers/leader_chat_provider.dart';
import '../widgets/leader_message_composer.dart';

/// Chat room for the Leader — can post messages, pin, close/reopen.
class LeaderChatRoomScreen extends ConsumerStatefulWidget {
  const LeaderChatRoomScreen({super.key, required this.chatId});
  final String chatId;

  @override
  ConsumerState<LeaderChatRoomScreen> createState() =>
      _LeaderChatRoomScreenState();
}

class _LeaderChatRoomScreenState extends ConsumerState<LeaderChatRoomScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels <=
          _scrollCtrl.position.minScrollExtent + 100) {
        ref.read(leaderChatRoomProvider(widget.chatId).notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderChatRoomProvider(widget.chatId));
    final chat = state.chat;

    // Scroll to bottom after first load
    ref.listen<LeaderChatRoomState>(leaderChatRoomProvider(widget.chatId), (
      prev,
      next,
    ) {
      if (prev?.isLoading == true && !next.isLoading) {
        _scrollToBottom();
      }
    });

    return AppScaffold(
      title: chat?.title ?? 'Chat',
      actions: [
        // Toggle open/closed
        if (chat != null)
          IconButton(
            icon: Icon(
              chat.isOpen
                  ? Icons.lock_open_outlined
                  : Icons.lock_outline_rounded,
            ),
            tooltip: chat.isOpen ? 'Close chat' : 'Reopen chat',
            onPressed: () async {
              await ref
                  .read(leaderChatRoomProvider(widget.chatId).notifier)
                  .toggleOpen();
              if (!mounted) return;
              context.showSuccess(
                chat.isOpen
                    ? 'Chat closed — voters can no longer react.'
                    : 'Chat reopened.',
              );
            },
          ),
      ],
      body: Column(
        children: [
          // Closed banner
          if (chat != null && !chat.isOpen)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.errorLight,
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.error,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Chat is closed — voters cannot react.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),

          // Message list
          Expanded(child: _buildMessages(state)),

          // Composer
          LeaderMessageComposer(
            isSending: state.isSending,
            isEnabled: true,
            onSend: (content) async {
              final success = await ref
                  .read(leaderChatRoomProvider(widget.chatId).notifier)
                  .postMessage(content);
              if (success) _scrollToBottom();
              if (!success && mounted) {
                context.showError(
                  ref.read(leaderChatRoomProvider(widget.chatId)).errorMessage,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(LeaderChatRoomState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.hasError) {
      return EmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: 'Could not load chat',
        subtitle: state.errorMessage,
        actionLabel: 'Retry',
        onAction: () =>
            ref.read(leaderChatRoomProvider(widget.chatId).notifier).load(),
      );
    }

    if (state.messages.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'No Messages',
        subtitle: 'Post the first message below.',
      );
    }

    return Column(
      children: [
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spaceMD,
            ),
            itemCount: state.messages.length,
            itemBuilder: (context, i) {
              final msg = state.messages[i];
              return GestureDetector(
                onLongPress: () => _showMessageActions(msg.id),
                child: MessageBubble(
                  key: ValueKey(msg.id),
                  message: msg,
                  isReacting: false,
                  isSubmittingFeedback: false,
                  // Leaders don't react to their own messages
                  onReact: (_) {},
                  onFeedback: (_) {},
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showMessageActions(String messageId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppDimensions.spaceMD),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderGrey,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            ListTile(
              leading: const Icon(
                Icons.push_pin_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Pin / Unpin Message'),
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(leaderChatRoomProvider(widget.chatId).notifier)
                    .pinMessage(messageId);
              },
            ),
            const SizedBox(height: AppDimensions.spaceMD),
          ],
        ),
      ),
    );
  }
}
