import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/ops_api_response.dart';
import '../models/ops_complaint_models.dart';
import '../repositories/ops_complaint_repository.dart';

// ─────────────────────────────────────────────
// List State
// ─────────────────────────────────────────────

class OpsComplaintListState {
  const OpsComplaintListState({
    this.complaints    = const [],
    this.isLoading     = false,
    this.isLoadingMore = false,
    this.hasMore       = true,
    this.currentPage   = 1,
    this.total         = 0,
    this.escalatedCount = 0,
    this.pendingCount  = 0,
    this.filter        = const OpsComplaintFilter(),
    this.errorMessage  = '',
  });

  final List<OpsComplaintItem> complaints;
  final bool                    isLoading;
  final bool                    isLoadingMore;
  final bool                    hasMore;
  final int                     currentPage;
  final int                     total;
  final int                     escalatedCount;
  final int                     pendingCount;
  final OpsComplaintFilter      filter;
  final String                  errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty  =>
      !isLoading && complaints.isEmpty && !hasError;

  OpsComplaintListState copyWith({
    List<OpsComplaintItem>? complaints,
    bool?                   isLoading,
    bool?                   isLoadingMore,
    bool?                   hasMore,
    int?                    currentPage,
    int?                    total,
    int?                    escalatedCount,
    int?                    pendingCount,
    OpsComplaintFilter?     filter,
    String?                 errorMessage,
  }) {
    return OpsComplaintListState(
      complaints:     complaints     ?? this.complaints,
      isLoading:      isLoading      ?? this.isLoading,
      isLoadingMore:  isLoadingMore  ?? this.isLoadingMore,
      hasMore:        hasMore        ?? this.hasMore,
      currentPage:    currentPage    ?? this.currentPage,
      total:          total          ?? this.total,
      escalatedCount: escalatedCount ?? this.escalatedCount,
      pendingCount:   pendingCount   ?? this.pendingCount,
      filter:         filter         ?? this.filter,
      errorMessage:   errorMessage   ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// List Notifier
// ─────────────────────────────────────────────

class OpsComplaintListNotifier
    extends StateNotifier<OpsComplaintListState> {
  OpsComplaintListNotifier(this._repo)
      : super(const OpsComplaintListState()) {
    load();
  }

  final OpsComplaintRepository _repo;

  Future<void> load({OpsComplaintFilter? filter}) async {
    final f = filter ?? state.filter;
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
      currentPage:  1,
      filter:       f,
    );

    final response = await _repo.fetchComplaints(
      page:            1,
      search:          f.search,
      categoryId:      f.categoryId,
      areaId:          f.areaId,
      status:          f.status,
      priority:        f.priority,
      escalatedOnly:   f.escalatedOnly,
    );

    if (response is OpsSuccess<OpsComplaintListResponse>) {
      final data = response.data;
      state = state.copyWith(
        complaints:     data.data,
        isLoading:      false,
        hasMore:        data.hasMore,
        currentPage:    1,
        total:          data.total,
        escalatedCount: data.escalatedCount,
        pendingCount:   data.pendingCount,
      );
    } else if (response is OpsError) {
      state = state.copyWith(
        isLoading:    false,
        errorMessage: response.exception.message,
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;
    final f = state.filter;

    final response = await _repo.fetchComplaints(
      page:            nextPage,
      search:          f.search,
      categoryId:      f.categoryId,
      areaId:          f.areaId,
      status:          f.status,
      priority:        f.priority,
      escalatedOnly:   f.escalatedOnly,
    );

    if (response is OpsSuccess<OpsComplaintListResponse>) {
      final data = response.data;
      state = state.copyWith(
        complaints:     [...state.complaints, ...data.data],
        isLoadingMore:  false,
        hasMore:        data.hasMore,
        currentPage:    nextPage,
      );
    } else if (response is OpsError) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void search(String q) {
    load(filter: state.filter.copyWith(search: q));
  }

  void applyFilter(OpsComplaintFilter filter) =>
      load(filter: filter);

  void clearFilters() =>
      load(filter: const OpsComplaintFilter());
}

final opsComplaintListProvider = StateNotifierProvider
    .autoDispose<OpsComplaintListNotifier,
        OpsComplaintListState>((ref) {
  return OpsComplaintListNotifier(
      ref.watch(opsComplaintRepositoryProvider));
});
