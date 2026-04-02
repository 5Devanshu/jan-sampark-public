import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../models/corporator_leader_models.dart';
import '../repositories/corporator_leader_repository.dart';

// ─────────────────────────────────────────────
// Leader List State
// ─────────────────────────────────────────────

class CorporatorLeaderListState {
  const CorporatorLeaderListState({
    this.leaders       = const [],
    this.isLoading     = false,
    this.isLoadingMore = false,
    this.hasMore       = true,
    this.currentPage   = 1,
    this.searchQuery   = '',
    this.errorMessage  = '',
  });

  final List<CorporatorLeaderItem> leaders;
  final bool   isLoading;
  final bool   isLoadingMore;
  final bool   hasMore;
  final int    currentPage;
  final String searchQuery;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty  =>
      !isLoading && leaders.isEmpty && !hasError;

  CorporatorLeaderListState copyWith({
    List<CorporatorLeaderItem>? leaders,
    bool?   isLoading,
    bool?   isLoadingMore,
    bool?   hasMore,
    int?    currentPage,
    String? searchQuery,
    String? errorMessage,
  }) {
    return CorporatorLeaderListState(
      leaders:       leaders       ?? this.leaders,
      isLoading:     isLoading     ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore:       hasMore       ?? this.hasMore,
      currentPage:   currentPage   ?? this.currentPage,
      searchQuery:   searchQuery   ?? this.searchQuery,
      errorMessage:  errorMessage  ?? this.errorMessage,
    );
  }
}

class CorporatorLeaderListNotifier
    extends StateNotifier<CorporatorLeaderListState> {
  CorporatorLeaderListNotifier(this._repo)
      : super(const CorporatorLeaderListState()) {
    load();
  }

  final CorporatorLeaderRepository _repo;

  Future<void> load({String? search}) async {
    final q = search ?? state.searchQuery;
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
      currentPage:  1,
      searchQuery:  q,
    );

    final response =
        await _repo.fetchLeaders(page: 1, search: q);

    response.when(
      success: (data) {
        state = state.copyWith(
          leaders:     data.data,
          isLoading:   false,
          hasMore:     data.hasMore,
          currentPage: 1,
        );
      },
      error: (e) {
        state = state.copyWith(
          isLoading:    false,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final response = await _repo.fetchLeaders(
      page:   nextPage,
      search: state.searchQuery,
    );

    response.when(
      success: (data) {
        state = state.copyWith(
          leaders:       [...state.leaders, ...data.data],
          isLoadingMore: false,
          hasMore:       data.hasMore,
          currentPage:   nextPage,
        );
      },
      error: (_) =>
          state = state.copyWith(isLoadingMore: false),
    );
  }

  void search(String q) => load(search: q);

  void prependLeader(CorporatorLeaderItem leader) {
    state = state.copyWith(
        leaders: [leader, ...state.leaders]);
  }
}

final corporatorLeaderListProvider = StateNotifierProvider
    .autoDispose<CorporatorLeaderListNotifier,
        CorporatorLeaderListState>((ref) {
  return CorporatorLeaderListNotifier(
      ref.watch(corporatorLeaderRepositoryProvider));
});

// ─────────────────────────────────────────────
// Detail
// ─────────────────────────────────────────────

final corporatorLeaderDetailProvider = FutureProvider
    .autoDispose
    .family<CorporatorLeaderDetail, String>((ref, id) async {
  final repo     = ref.watch(corporatorLeaderRepositoryProvider);
  final response = await repo.fetchLeaderDetail(id);
  return response.when(
    success: (data) => data,
    error:   (e)    => throw e,
  );
});

// ─────────────────────────────────────────────
// Create Leader State
// ─────────────────────────────────────────────

class CreateLeaderState {
  const CreateLeaderState({
    this.isLoading    = false,
    this.isSuccess    = false,
    this.errorMessage = '',
  });

  final bool   isLoading;
  final bool   isSuccess;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;

  CreateLeaderState copyWith({
    bool?   isLoading,
    bool?   isSuccess,
    String? errorMessage,
  }) {
    return CreateLeaderState(
      isLoading:    isLoading    ?? this.isLoading,
      isSuccess:    isSuccess    ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CreateLeaderNotifier
    extends StateNotifier<CreateLeaderState> {
  CreateLeaderNotifier(this._repo)
      : super(const CreateLeaderState());

  final CorporatorLeaderRepository _repo;

  Future<bool> create(CreateLeaderRequest request) async {
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
      isSuccess:    false,
    );

    final response = await _repo.createLeader(request);

    return response.when(
      success: (_) {
        state = state.copyWith(
            isLoading: false, isSuccess: true);
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

  void reset() => state = const CreateLeaderState();
}

final createLeaderProvider = StateNotifierProvider
    .autoDispose<CreateLeaderNotifier, CreateLeaderState>(
        (ref) {
  return CreateLeaderNotifier(
      ref.watch(corporatorLeaderRepositoryProvider));
});

// ─────────────────────────────────────────────
// Update Responsibilities State
// ─────────────────────────────────────────────

class UpdateResponsibilitiesState {
  const UpdateResponsibilitiesState({
    this.isLoading    = false,
    this.isSuccess    = false,
    this.errorMessage = '',
  });
  final bool   isLoading;
  final bool   isSuccess;
  final String errorMessage;
  bool get hasError => errorMessage.isNotEmpty;
}

class UpdateResponsibilitiesNotifier
    extends StateNotifier<UpdateResponsibilitiesState> {
  UpdateResponsibilitiesNotifier(this._repo)
      : super(const UpdateResponsibilitiesState());

  final CorporatorLeaderRepository _repo;

  Future<bool> update(
    String leaderId, {
    required List<String> responsibilities,
  }) async {
    state = const UpdateResponsibilitiesState(isLoading: true);

    final response = await _repo.updateResponsibilities(
      leaderId,
      responsibilities: responsibilities,
    );

    return response.when(
      success: (_) {
        state = const UpdateResponsibilitiesState(
            isSuccess: true);
        return true;
      },
      error: (e) {
        state = UpdateResponsibilitiesState(
          errorMessage:
              e is AppException ? e.message : e.toString(),
        );
        return false;
      },
    );
  }
}

final updateResponsibilitiesProvider = StateNotifierProvider
    .autoDispose<UpdateResponsibilitiesNotifier,
        UpdateResponsibilitiesState>((ref) {
  return UpdateResponsibilitiesNotifier(
      ref.watch(corporatorLeaderRepositoryProvider));
});