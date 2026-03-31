import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../models/poll_models.dart';
import '../repositories/poll_repository.dart';

// ─────────────────────────────────────────────
// Poll List
// ─────────────────────────────────────────────

class PollListState {
  const PollListState({
    this.polls = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage = '',
  });

  final List<PollModel> polls;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty => !isLoading && polls.isEmpty && !hasError;

  PollListState copyWith({
    List<PollModel>? polls,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return PollListState(
      polls: polls ?? this.polls,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PollListNotifier extends StateNotifier<PollListState> {
  PollListNotifier(this._repo) : super(const PollListState()) {
    load();
  }

  final PollRepository _repo;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: '', currentPage: 1);
    final response = await _repo.fetchPolls(page: 1);
    response.when(
      success: (data) => state = state.copyWith(
        polls: data.data,
        isLoading: false,
        hasMore: data.hasMore,
        currentPage: 1,
      ),
      error: (e) => state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : e.toString(),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;
    final response = await _repo.fetchPolls(page: nextPage);
    response.when(
      success: (data) => state = state.copyWith(
        polls: [...state.polls, ...data.data],
        isLoadingMore: false,
        hasMore: data.hasMore,
        currentPage: nextPage,
      ),
      error: (_) => state = state.copyWith(isLoadingMore: false),
    );
  }

  void markVoted(String pollId) {
    final updated = state.polls.map((p) {
      if (p.id == pollId) {
        return PollModel(
          id: p.id,
          question: p.question,
          pollType: p.pollType,
          isAnonymous: p.isAnonymous,
          showResults: p.showResults,
          status: p.status,
          totalResponses: p.totalResponses + 1,
          createdByName: p.createdByName,
          hasVoted: true,
          options: p.options,
          closesAt: p.closesAt,
          publishedAt: p.publishedAt,
          createdAt: p.createdAt,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(polls: updated);
  }
}

final pollListProvider =
    StateNotifierProvider.autoDispose<PollListNotifier, PollListState>((ref) {
      return PollListNotifier(ref.watch(pollRepositoryProvider));
    });

// ─────────────────────────────────────────────
// Poll Detail
// ─────────────────────────────────────────────

final pollDetailProvider = FutureProvider.autoDispose.family<PollModel, String>(
  (ref, id) async {
    final repo = ref.watch(pollRepositoryProvider);
    final response = await repo.fetchPollDetail(id);
    return response.when(success: (data) => data, error: (e) => throw e);
  },
);

// ─────────────────────────────────────────────
// Vote State
// ─────────────────────────────────────────────

enum VoteStatus { idle, loading, success, error }

class VoteState {
  const VoteState({
    this.status = VoteStatus.idle,
    this.results,
    this.errorMessage = '',
  });

  final VoteStatus status;
  final PollResults? results;
  final String errorMessage;

  bool get isLoading => status == VoteStatus.loading;
  bool get isSuccess => status == VoteStatus.success;
  bool get hasError => status == VoteStatus.error;

  VoteState copyWith({
    VoteStatus? status,
    PollResults? results,
    String? errorMessage,
  }) {
    return VoteState(
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class VoteNotifier extends StateNotifier<VoteState> {
  VoteNotifier(this._repo) : super(const VoteState());
  final PollRepository _repo;

  Future<bool> vote({
    required String pollId,
    required VoteRequest request,
  }) async {
    state = state.copyWith(status: VoteStatus.loading, errorMessage: '');

    final response = await _repo.vote(pollId: pollId, request: request);

    return response.when(
      success: (data) {
        // Parse results from vote response if show_results=true
        PollResults? results;
        if (data['results'] != null) {
          results = PollResults.fromJson(
            data['results'] as Map<String, dynamic>,
          );
        }
        state = state.copyWith(status: VoteStatus.success, results: results);
        return true;
      },
      error: (e) {
        state = state.copyWith(
          status: VoteStatus.error,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
        return false;
      },
    );
  }
}

final voteProvider = StateNotifierProvider.autoDispose<VoteNotifier, VoteState>(
  (ref) {
    return VoteNotifier(ref.watch(pollRepositoryProvider));
  },
);

// ─────────────────────────────────────────────
// Poll Results
// ─────────────────────────────────────────────

final pollResultsProvider = FutureProvider.autoDispose
    .family<PollResults, String>((ref, pollId) async {
      final repo = ref.watch(pollRepositoryProvider);
      final response = await repo.fetchResults(pollId);
      return response.when(success: (data) => data, error: (e) => throw e);
    });
