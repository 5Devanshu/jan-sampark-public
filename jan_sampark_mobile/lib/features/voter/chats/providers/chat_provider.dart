import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../models/chat_models.dart';
import '../repositories/chat_repository.dart';

// ─────────────────────────────────────────────
// Chat List State
// ─────────────────────────────────────────────

class ChatListState {
  const ChatListState({
    this.chats = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage = '',
  });

  final List<ChatModel> chats;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty => !isLoading && chats.isEmpty && !hasError;

  ChatListState copyWith({
    List<ChatModel>? chats,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return ChatListState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ChatListNotifier extends StateNotifier<ChatListState> {
  ChatListNotifier(this._repo) : super(const ChatListState()) {
    load();
  }

  final ChatRepository _repo;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: '', currentPage: 1);

    final response = await _repo.fetchChats(page: 1);

    response.when(
      success: (data) {
        state = state.copyWith(
          chats: data.data,
          isLoading: false,
          hasMore: data.hasMore,
          currentPage: 1,
        );
      },
      error: (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final response = await _repo.fetchChats(page: nextPage);

    response.when(
      success: (data) {
        state = state.copyWith(
          chats: [...state.chats, ...data.data],
          isLoadingMore: false,
          hasMore: data.hasMore,
          currentPage: nextPage,
        );
      },
      error: (_) => state = state.copyWith(isLoadingMore: false),
    );
  }
}

final chatListProvider =
    StateNotifierProvider.autoDispose<ChatListNotifier, ChatListState>((ref) {
      return ChatListNotifier(ref.watch(chatRepositoryProvider));
    });

// ─────────────────────────────────────────────
// Chat Room State — messages + reactions
// ─────────────────────────────────────────────

class ChatRoomState {
  const ChatRoomState({
    this.messages = const [],
    this.chat,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.currentPage = 1,
    this.errorMessage = '',
    this.reactingMessageIds = const {},
    this.submittingFeedbackIds = const {},
  });

  final List<ChatMessage> messages;
  final ChatModel? chat;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String errorMessage;

  /// Message IDs currently being reacted to (shows spinner)
  final Set<String> reactingMessageIds;

  /// Message IDs currently submitting feedback
  final Set<String> submittingFeedbackIds;

  bool get hasError => errorMessage.isNotEmpty;

  ChatRoomState copyWith({
    List<ChatMessage>? messages,
    ChatModel? chat,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
    Set<String>? reactingMessageIds,
    Set<String>? submittingFeedbackIds,
  }) {
    return ChatRoomState(
      messages: messages ?? this.messages,
      chat: chat ?? this.chat,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
      reactingMessageIds: reactingMessageIds ?? this.reactingMessageIds,
      submittingFeedbackIds:
          submittingFeedbackIds ?? this.submittingFeedbackIds,
    );
  }
}

// ─────────────────────────────────────────────
// Chat Room Notifier
// ─────────────────────────────────────────────

class ChatRoomNotifier extends StateNotifier<ChatRoomState> {
  ChatRoomNotifier(this._repo, this._chatId) : super(const ChatRoomState()) {
    load();
  }

  final ChatRepository _repo;
  final String _chatId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: '', currentPage: 1);

    // Fetch chat detail and first page of messages concurrently
    final results = await Future.wait([
      _repo.fetchChatDetail(_chatId),
      _repo.fetchMessages(chatId: _chatId, page: 1),
    ]);

    final chatRes = results[0] as ApiResponse<ChatModel>;
    final messagesRes = results[1] as ApiResponse<MessageListResponse>;

    ChatModel? chat;
    List<ChatMessage> messages = [];
    bool hasMore = false;
    String errorMessage = '';

    chatRes.when(
      success: (data) => chat = data,
      error: (e) => errorMessage = e is AppException ? e.message : e.toString(),
    );

    messagesRes.when(
      success: (data) {
        messages = data.data;
        hasMore = data.hasMore;
      },
      error: (e) {
        if (errorMessage.isEmpty) {
          errorMessage = e is AppException ? e.message : e.toString();
        }
      },
    );

    state = state.copyWith(
      chat: chat,
      messages: messages,
      isLoading: false,
      hasMore: hasMore,
      currentPage: 1,
      errorMessage: errorMessage,
    );
  }

  // ── Load more (older messages) ────────────

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final response = await _repo.fetchMessages(chatId: _chatId, page: nextPage);

    response.when(
      success: (data) {
        // Prepend older messages to the top
        state = state.copyWith(
          messages: [...data.data, ...state.messages],
          isLoadingMore: false,
          hasMore: data.hasMore,
          currentPage: nextPage,
        );
      },
      error: (_) => state = state.copyWith(isLoadingMore: false),
    );
  }

  // ── React to message ──────────────────────

  Future<void> react({required String messageId, required String emoji}) async {
    // Mark as reacting (shows spinner on reaction row)
    state = state.copyWith(
      reactingMessageIds: {...state.reactingMessageIds, messageId},
    );

    final response = await _repo.reactToMessage(
      chatId: _chatId,
      messageId: messageId,
      request: ReactRequest(emoji: emoji),
    );

    response.when(
      success: (data) {
        // Parse updated reactions from response
        final rawReactions = data['reactions'] as List<dynamic>? ?? [];
        final reactions = rawReactions
            .map((e) => ReactionSummary.fromJson(e as Map<String, dynamic>))
            .toList();

        // Update message in state with new reactions
        final updated = state.messages.map((m) {
          if (m.id == messageId) {
            return m.copyWithReactions(reactions);
          }
          return m;
        }).toList();

        state = state.copyWith(
          messages: updated,
          reactingMessageIds: state.reactingMessageIds.difference({messageId}),
        );
      },
      error: (_) {
        state = state.copyWith(
          reactingMessageIds: state.reactingMessageIds.difference({messageId}),
        );
      },
    );
  }

  // ── Submit feedback ───────────────────────

  Future<bool> submitFeedback({
    required String messageId,
    required String text,
  }) async {
    state = state.copyWith(
      submittingFeedbackIds: {...state.submittingFeedbackIds, messageId},
    );

    final response = await _repo.submitFeedback(
      chatId: _chatId,
      messageId: messageId,
      request: FeedbackRequest(text: text),
    );

    final success = response.isSuccess;

    state = state.copyWith(
      submittingFeedbackIds: state.submittingFeedbackIds.difference({
        messageId,
      }),
    );

    return success;
  }
}

// ─────────────────────────────────────────────
// Chat Room Provider (family keyed by chatId)
// ─────────────────────────────────────────────

final chatRoomProvider = StateNotifierProvider.autoDispose
    .family<ChatRoomNotifier, ChatRoomState, String>((ref, chatId) {
      return ChatRoomNotifier(ref.watch(chatRepositoryProvider), chatId);
    });
