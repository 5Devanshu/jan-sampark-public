import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../models/leader_voter_models.dart';
import '../repositories/leader_voter_repository.dart';

// ─────────────────────────────────────────────
// Voter List State
// ─────────────────────────────────────────────

class VoterListState {
  const VoterListState({
    this.voters = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.searchQuery = '',
    this.errorMessage = '',
  });

  final List<VoterListItem> voters;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String searchQuery;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty => !isLoading && voters.isEmpty && !hasError;

  VoterListState copyWith({
    List<VoterListItem>? voters,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
    String? errorMessage,
  }) {
    return VoterListState(
      voters: voters ?? this.voters,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class VoterListNotifier extends StateNotifier<VoterListState> {
  VoterListNotifier(this._repo) : super(const VoterListState()) {
    load();
  }

  final LeaderVoterRepository _repo;

  Future<void> load({String? search}) async {
    final q = search ?? state.searchQuery;
    state = state.copyWith(
      isLoading: true,
      errorMessage: '',
      currentPage: 1,
      searchQuery: q,
    );

    final response = await _repo.fetchVoters(page: 1, search: q);

    response.when(
      success: (data) {
        state = state.copyWith(
          voters: data.data,
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

    final response = await _repo.fetchVoters(
      page: nextPage,
      search: state.searchQuery,
    );

    response.when(
      success: (data) {
        state = state.copyWith(
          voters: [...state.voters, ...data.data],
          isLoadingMore: false,
          hasMore: data.hasMore,
          currentPage: nextPage,
        );
      },
      error: (_) => state = state.copyWith(isLoadingMore: false),
    );
  }

  void search(String query) => load(search: query);
}

final leaderVoterListProvider =
    StateNotifierProvider.autoDispose<VoterListNotifier, VoterListState>((ref) {
      return VoterListNotifier(ref.watch(leaderVoterRepositoryProvider));
    });

// ─────────────────────────────────────────────
// Voter Profile Detail
// ─────────────────────────────────────────────

final leaderVoterProfileProvider = FutureProvider.autoDispose
    .family<VoterProfile, String>((ref, voterId) async {
      final repo = ref.watch(leaderVoterRepositoryProvider);
      final response = await repo.fetchVoterProfile(voterId);
      return response.when(success: (data) => data, error: (e) => throw e);
    });
