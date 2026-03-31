import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';

/// Chat room screen — displays messages, reactions, feedback.
///
/// Voters can:
///   - Read messages posted by Leader or Corporator
///   - React with emoji (tap reaction row)
///   - Submit text feedback (tap Feedback button)
///
/// Voters cannot post messages — only Leaders/Corporators can.
/// Load more (older messages) by scrolling to top.
class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.chatId});
  final String chatId;

  @override
  ConsumerState<ChatRoomScreen> createState() =>
      _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _scrollCtrl = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();

    _scrollCtrl.addListener(() {
      // Show scroll-to-bottom FAB when scrolled up
      final showButton = _scrollCtrl.position.pixels 
          _scrollCtrl.position.maxScrollExtent - 300;
      if (showButton != _showScrollToBottom) {
        setState(() => _showScrollToBottom = showButton);
      }

      // Load older messages when scrolled to top
      if (_scrollCtrl.position.pixels <=
          _scrollCtrl.position.minScrollExtent + 100) {
        ref.read(chatRoomProvider(widget.chatId).notifier)
            .loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve:    Curves.easeOut,
      );
    }
  }

  // ── Jump to bottom after messages load ──────

  void _scrollToBottomOnLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(
            _scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomProvider(widget.chatId));

    // Scroll to bottom when messages first load
    ref.listen<ChatRoomState>(
      chatRoomProvider(widget.chatId),
      (prev, next) {
        if (prev?.isLoading == true && !next.isLoading) {
          _scrollToBottomOnLoad();
        }
      },
    );

    return AppScaffold(
      title: state.chat?.title ?? 'Chat',
      body: Stack(
        children: [
          _buildBody(context, state),

          // Scroll to bottom FAB
          if (_showScrollToBottom)
            Positioned(
              bottom: 16,
              right:  16,
              child: FloatingActionButton.small(
                onPressed:   _scrollToBottom,
                backgroundColor: AppColors.primary,
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChatRoomState state) {
    // ── Loading ────────────────────────────────
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    // ── Error ──────────────────────────────────
    if (state.hasError) {
      return EmptyStateWidget(
        icon:     Icons.error_outline_rounded,
        title:    'Could not load chat',
        subtitle: state.errorMessage,
        actionLabel: 'Retry',
        onAction: () => ref
            .read(chatRoomProvider(widget.chatId).notifier)
            .load(),
      );
    }

    // ── Closed chat notice ─────────────────────
    if (state.chat != null && !state.chat!.isOpen) {
      return Column(
        children: [
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            color: AppColors.errorLight,
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded,
                    color: AppColors.error, size: 16),
                const SizedBox(width: 8),
                Text(
                  'This chat is closed. '
                  'New reactions are not accepted.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildMessageList(context, state)),
        ],
      );
    }

    // ── Normal chat ────────────────────────────
    return Column(
      children: [
        // Load older messages indicator
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary,
                ),
              ),
            ),
          ),

        Expanded(child: _buildMessageList(context, state)),

        // Voter read-only notice
        _VoterReadOnlyBanner(isClosed: !(state.chat?.isOpen ?? true)),
      ],
    );
  }

  Widget _buildMessageList(BuildContext context, ChatRoomState state) {
    if (state.messages.isEmpty) {
      return EmptyStateWidget(
        icon:     Icons.chat_bubble_outline_rounded,
        title:    'No Messages Yet',
        subtitle: 'Messages from your representative '
            'will appear here.',
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spaceMD),
      itemCount:   state.messages.length,
      itemBuilder: (context, i) {
        final message = state.messages[i];
        final isReacting = state.reactingMessageIds
            .contains(message.id);
        final isSubmittingFeedback = state
            .submittingFeedbackIds.contains(message.id);

        return MessageBubble(
          key:                 ValueKey(message.id),
          message:             message,
          isReacting:          isReacting,
          isSubmittingFeedback: isSubmittingFeedback,
          onReact: (emoji) {
            if (!(state.chat?.isOpen ?? true)) {
              context.showError(
                  'Reactions are closed for this chat.');
              return;
            }
            ref.read(chatRoomProvider(widget.chatId).notifier)
                .react(messageId: message.id, emoji: emoji);
          },
          onFeedback: (text) async {
            if (!(state.chat?.isOpen ?? true)) {
              context.showError(
                  'Feedback is closed for this chat.');
              return;
            }
            final success = await ref
                .read(chatRoomProvider(widget.chatId).notifier)
                .submitFeedback(
                  messageId: message.id,
                  text:      text,
                );
            if (success && context.mounted) {
              context.showSuccess('Feedback submitted.');
            } else if (!success && context.mounted) {
              context.showError(
                  'Failed to submit feedback. Please try again.');
            }
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Read-only notice at bottom of chat
// ─────────────────────────────────────────────

class _VoterReadOnlyBanner extends StatelessWidget {
  const _VoterReadOnlyBanner({required this.isClosed});
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical:   10),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
            top: BorderSide(color: AppColors.borderGrey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isClosed
                ? Icons.lock_outline_rounded
                : Icons.remove_red_eye_outlined,
            size:  15,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            isClosed
                ? 'This chat is closed'
                : 'Tap a message to react or share feedback',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}