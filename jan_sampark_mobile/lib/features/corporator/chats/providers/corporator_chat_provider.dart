// Corporator chats use the exact same provider and
// repository pattern as the Leader chats.
// The backend resolves scope from the JWT token.

export '../../../leader/chats/providers/leader_chat_provider.dart'
    show
        createChatProvider,
        CreateChatState,
        CreateChatNotifier;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../leader/chats/models/leader_chat_models.dart';
import '../../../leader/chats/repositories/leader_chat_repository.dart';
import '../../../voter/chats/models/chat_models.dart';
import '../../../../core/exceptions/app_exception.dart';

// ─────────────────────────────────────────────
// Corporator Chat List (same shape, scoped by token)
// ─────────────────────────────────────────────

class CorporatorChatListState {
  const CorporatorChatListState({
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
  bool get isEmpty  =>
      !isLoading && chats.isEmpty && !hasError;

  CorporatorChatListState copyWith({
    List<ChatModel>? chats,
    bool?   isLoading,
    bool?   isLoadingMore,
    bool?   hasMore,
    int?    currentPage,
    String? errorMessage,
  }) {
    return CorporatorChatListState(
      chats:         chats         ?? this.chats,
      isLoading:     isLoading     ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore:       hasMore       ?? this.hasMore,
      currentPage:   currentPage   ?? this.currentPage,
      errorMessage:  errorMessage  ?? this.errorMessage,
    );
  }
}

class CorporatorChatListNotifier
    extends StateNotifier<CorporatorChatListState> {
  CorporatorChatListNotifier(this._repo)
      : super(const CorporatorChatListState()) {
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

  void prependChat(ChatModel chat) {
    state = state.copyWith(chats: [chat, ...state.chats]);
  }
}

final corporatorChatListProvider = StateNotifierProvider
    .autoDispose<CorporatorChatListNotifier,
        CorporatorChatListState>((ref) {
  return CorporatorChatListNotifier(
      ref.watch(leaderChatRepositoryProvider));
});

// Reuse leader chat room provider — works identically
export '../../../leader/chats/providers/leader_chat_provider.dart'
    show leaderChatRoomProvider, LeaderChatRoomState;