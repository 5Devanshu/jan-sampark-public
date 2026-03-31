import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../voter/chats/models/chat_models.dart';
import '../models/leader_chat_models.dart';
import '../repositories/leader_chat_repository.dart';

// ─────────────────────────────────────────────
// Chat List — same state shape as voter
// ─────────────────────────────────────────────

class LeaderChatListState {
  const LeaderChatListState({
    this.chats         = const [],
    this.isLoading     = false,
    this.isLoadingMore = false,
    this.hasMore       = true,
    this.currentPage   = 1,
    this.errorMessage  = '',
  });

  final List<ChatModel> chats;
  final bool   isLoading;
  final bool   isLoadingMore;
  final bool   hasMore;
  final int    currentPage;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty  => !isLoading && chats.isEmpty && !hasError;

  LeaderChatListState copyWith({
    List<ChatModel>? chats,
    bool?   isLoading,
    bool?   isLoadingMore,
    bool?   hasMore,
    int?    currentPage,
    String? errorMessage,
  }) {
    return LeaderChatListState(
      chats:         chats         ?? this.chats,
      isLoading:     isLoading     ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore:       hasMore       ?? this.hasMore,
      currentPage:   currentPage   ?? this.currentPage,
      errorMessage:  errorMessage  ?? this.errorMessage,
    );
  }
}

class LeaderChatListNotifier
    extends StateNotifier<LeaderChatListState> {
  LeaderChatListNotifier(this._repo)
      : super(const LeaderChatListState()) {
    load();
  }

  final LeaderChatRepository _repo;

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true, errorMessage: '', currentPage: 1,
    );
    final response = await _repo.fetchChats(page: 1);
    response.when(
      success: (data) => state = state.copyWith(
        chats:       data.data,
        isLoading:   false,
        hasMore:     data.hasMore,
        currentPage: 1,
      ),
      error: (e) => state = state.copyWith(
        isLoading:    false,
        errorMessage: e is AppException ? e.message : e.toString(),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;
    final response = await _repo.fetchChats(page: nextPage);
    response.when(
      success: (data) => state = state.copyWith(
        chats:         [...state.chats, ...data.data],
        isLoadingMore: false,
        hasMore:       data.hasMore,
        currentPage:   nextPage,
      ),
      error: (_) =>
          state = state.copyWith(isLoadingMore: false),
    );
  }

  /// Add the newly created chat to the top of the list.
  void prependChat(ChatModel chat) {
    state = state.copyWith(chats: [chat, ...state.chats]);
  }
}

final leaderChatListProvider = StateNotifierProvider
    .autoDispose<LeaderChatListNotifier, LeaderChatListState>(
        (ref) {
  return LeaderChatListNotifier(
      ref.watch(leaderChatRepositoryProvider));
});

// ─────────────────────────────────────────────
// Chat Room State
// ─────────────────────────────────────────────

class LeaderChatRoomState {
  const LeaderChatRoomState({
    this.messages      = const [],
    this.chat,
    this.isLoading     = false,
    this.isLoadingMore = false,
    this.hasMore       = false,
    this.currentPage   = 1,
    this.isSending     = false,
    this.errorMessage  = '',
  });

  final List<ChatMessage> messages;
  final ChatModel? chat;
  final bool   isLoading;
  final bool   isLoadingMore;
  final bool   hasMore;
  final int    currentPage;
  final bool   isSending;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;

  LeaderChatRoomState copyWith({
    List<ChatMessage>? messages,
    ChatModel? chat,
    bool?   isLoading,
    bool?   isLoadingMore,
    bool?   hasMore,
    int?    currentPage,
    bool?   isSending,
    String? errorMessage,
  }) {
    return LeaderChatRoomState(
      messages:      messages      ?? this.messages,
      chat:          chat          ?? this.chat,
      isLoading:     isLoading     ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore:       hasMore       ?? this.hasMore,
      currentPage:   currentPage   ?? this.currentPage,
      isSending:     isSending     ?? this.isSending,
      errorMessage:  errorMessage  ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// Chat Room Notifier
// ─────────────────────────────────────────────

class LeaderChatRoomNotifier
    extends StateNotifier<LeaderChatRoomState> {
  LeaderChatRoomNotifier(this._repo, this._chatId)
      : super(const LeaderChatRoomState()) {
    load();
  }

  final LeaderChatRepository _repo;
  final String               _chatId;

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true, errorMessage: '', currentPage: 1,
    );

    final results = await Future.wait([
      _repo.fetchChatDetail(_chatId),
      _repo.fetchMessages(chatId: _chatId, page: 1),
    ]);

    final chatRes     = results[0] as ApiResponse<ChatModel>;
    final messagesRes =
        results[1] as ApiResponse<MessageListResponse>;

    ChatModel?        chat;
    List<ChatMessage> messages = [];
    bool   hasMore       = false;
    String errorMessage  = '';

    chatRes.when(
      success: (d) => chat = d,
      error:   (e) =>
          errorMessage = e is AppException ? e.message : e.toString(),
    );
    messagesRes.when(
      success: (d) {
        messages = d.data;
        hasMore  = d.hasMore;
      },
      error: (e) {
        if (errorMessage.isEmpty) {
          errorMessage =
              e is AppException ? e.message : e.toString();
        }
      },
    );

    state = state.copyWith(
      chat:         chat,
      messages:     messages,
      isLoading:    false,
      hasMore:      hasMore,
      currentPage:  1,
      errorMessage: errorMessage,
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;
    final response = await _repo.fetchMessages(
        chatId: _chatId, page: nextPage);
    response.when(
      success: (data) => state = state.copyWith(
        messages:      [...data.data, ...state.messages],
        isLoadingMore: false,
        hasMore:       data.hasMore,
        currentPage:   nextPage,
      ),
      error: (_) =>
          state = state.copyWith(isLoadingMore: false),
    );
  }

  // ── Post message ──────────────────────────

  Future<bool> postMessage(String content) async {
    if (content.trim().isEmpty) return false;
    state = state.copyWith(isSending: true);

    final response = await _repo.postMessage(
      chatId:  _chatId,
      request: PostMessageRequest(content: content.trim()),
    );

    return response.when(
      success: (msg) {
        // Append new message to bottom
        state = state.copyWith(
          messages:  [...state.messages, msg],
          isSending: false,
        );
        return true;
      },
      error: (e) {
        state = state.copyWith(
          isSending:    false,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
        return false;
      },
    );
  }

  // ── Pin message ───────────────────────────

  Future<void> pinMessage(String messageId) async {
    await _repo.pinMessage(
        chatId: _chatId, messageId: messageId);
    // Refresh messages to reflect pin status
    final response =
        await _repo.fetchMessages(chatId: _chatId, page: 1);
    response.when(
      success: (data) => state = state.copyWith(
        messages:    data.data,
        hasMore:     data.hasMore,
        currentPage: 1,
      ),
      error: (_) {},
    );
  }

  // ── Toggle chat open/closed ───────────────

  Future<void> toggleOpen() async {
    if (state.chat == null) return;
    final newState = !state.chat!.isOpen;
    await _repo.toggleChatOpen(
        chatId: _chatId, isOpen: newState);
    // Reload detail to reflect change
    final response = await _repo.fetchChatDetail(_chatId);
    response.when(
      success: (chat) => state = state.copyWith(chat: chat),
      error:   (_) {},
    );
  }
}

final leaderChatRoomProvider = StateNotifierProvider.autoDispose
    .family<LeaderChatRoomNotifier, LeaderChatRoomState,
        String>((ref, chatId) {
  return LeaderChatRoomNotifier(
      ref.watch(leaderChatRepositoryProvider), chatId);
});

// ─────────────────────────────────────────────
// Create Chat State
// ─────────────────────────────────────────────

class CreateChatState {
  const CreateChatState({
    this.isLoading    = false,
    this.isSuccess    = false,
    this.errorMessage = '',
    this.createdChat,
  });

  final bool      isLoading;
  final bool      isSuccess;
  final String    errorMessage;
  final ChatModel? createdChat;

  bool get hasError => errorMessage.isNotEmpty;

  CreateChatState copyWith({
    bool?      isLoading,
    bool?      isSuccess,
    String?    errorMessage,
    ChatModel? createdChat,
  }) {
    return CreateChatState(
      isLoading:    isLoading    ?? this.isLoading,
      isSuccess:    isSuccess    ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      createdChat:  createdChat  ?? this.createdChat,
    );
  }
}

class CreateChatNotifier extends StateNotifier<CreateChatState> {
  CreateChatNotifier(this._repo) : super(const CreateChatState());
  final LeaderChatRepository _repo;

  Future<bool> create(CreateChatRequest request) async {
    state = state.copyWith(
      isLoading: true, errorMessage: '', isSuccess: false,
    );
    final response = await _repo.createChat(request);
    return response.when(
      success: (chat) {
        state = state.copyWith(
          isLoading:   false,
          isSuccess:   true,
          createdChat: chat,
        );
        return true;
      },
      error: (e) {
        state = state.copyWith(
          isLoading:    false,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
        return false;
      },
    );
  }

  void reset() => state = const CreateChatState();
}

final createChatProvider = StateNotifierProvider
    .autoDispose<CreateChatNotifier, CreateChatState>((ref) {
  return CreateChatNotifier(
      ref.watch(leaderChatRepositoryProvider));
});

import '../../../../core/network/api_response.dart';