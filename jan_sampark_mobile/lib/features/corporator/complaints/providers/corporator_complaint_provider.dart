import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../leader/complaints/repositories/leader_complaint_repository.dart';
import '../repositories/corporator_complaint_repository.dart';

// ─────────────────────────────────────────────
// Filter Model
// ─────────────────────────────────────────────

class CorporatorComplaintFilter {
  const CorporatorComplaintFilter({
    this.statusFilter,
    this.priority,
    this.escalatedOnly  = false,
    this.assignedToType,
    this.wardId,
  });

  final String? statusFilter;
  final String? priority;
  final bool    escalatedOnly;
  final String? assignedToType;
  final String? wardId;

  bool get hasFilters =>
      statusFilter   != null ||
      priority       != null ||
      escalatedOnly  ||
      assignedToType != null ||
      wardId         != null;

  CorporatorComplaintFilter copyWith({
    String? statusFilter,
    String? priority,
    bool?   escalatedOnly,
    String? assignedToType,
    String? wardId,
  }) {
    return CorporatorComplaintFilter(
      statusFilter:   statusFilter   ?? this.statusFilter,
      priority:       priority       ?? this.priority,
      escalatedOnly:  escalatedOnly  ?? this.escalatedOnly,
      assignedToType: assignedToType ?? this.assignedToType,
      wardId:         wardId         ?? this.wardId,
    );
  }

  CorporatorComplaintFilter cleared() =>
      const CorporatorComplaintFilter();
}

// ─────────────────────────────────────────────
// List State
// ─────────────────────────────────────────────

class CorporatorComplaintListState {
  const CorporatorComplaintListState({
    this.complaints    = const [],
    this.isLoading     = false,
    this.isLoadingMore = false,
    this.hasMore       = true,
    this.currentPage   = 1,
    this.filter        = const CorporatorComplaintFilter(),
    this.errorMessage  = '',
  });

  final List<ComplaintListItem>    complaints;
  final bool                       isLoading;
  final bool                       isLoadingMore;
  final bool                       hasMore;
  final int                        currentPage;
  final CorporatorComplaintFilter  filter;
  final String                     errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty  =>
      !isLoading && complaints.isEmpty && !hasError;

  CorporatorComplaintListState copyWith({
    List<ComplaintListItem>?   complaints,
    bool?                      isLoading,
    bool?                      isLoadingMore,
    bool?                      hasMore,
    int?                       currentPage,
    CorporatorComplaintFilter? filter,
    String?                    errorMessage,
  }) {
    return CorporatorComplaintListState(
      complaints:    complaints    ?? this.complaints,
      isLoading:     isLoading     ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore:       hasMore       ?? this.hasMore,
      currentPage:   currentPage   ?? this.currentPage,
      filter:        filter        ?? this.filter,
      errorMessage:  errorMessage  ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// List Notifier
// ─────────────────────────────────────────────

class CorporatorComplaintListNotifier
    extends StateNotifier<CorporatorComplaintListState> {
  CorporatorComplaintListNotifier(this._repo)
      : super(const CorporatorComplaintListState()) {
    load();
  }

  final CorporatorComplaintRepository _repo;

  Future<void> load({CorporatorComplaintFilter? filter}) async {
    final f = filter ?? state.filter;
    state = state.copyWith(
      isLoading:    true,
      errorMessage: '',
      currentPage:  1,
      filter:       f,
    );

    final response = await _repo.fetchComplaints(
      page:           1,
      statusFilter:   f.statusFilter,
      priority:       f.priority,
      escalated:      f.escalatedOnly ? true : null,
      assignedToType: f.assignedToType,
      wardId:         f.wardId,
    );

    response.when(
      success: (data) {
        state = state.copyWith(
          complaints:  data.data,
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
    final f = state.filter;

    final response = await _repo.fetchComplaints(
      page:           nextPage,
      statusFilter:   f.statusFilter,
      priority:       f.priority,
      escalated:      f.escalatedOnly ? true : null,
      assignedToType: f.assignedToType,
      wardId:         f.wardId,
    );

    response.when(
      success: (data) {
        state = state.copyWith(
          complaints:    [...state.complaints, ...data.data],
          isLoadingMore: false,
          hasMore:       data.hasMore,
          currentPage:   nextPage,
        );
      },
      error: (_) =>
          state = state.copyWith(isLoadingMore: false),
    );
  }

  void applyFilter(CorporatorComplaintFilter filter) =>
      load(filter: filter);

  void clearFilters() =>
      load(filter: const CorporatorComplaintFilter());
}

final corporatorComplaintListProvider = StateNotifierProvider
    .autoDispose<CorporatorComplaintListNotifier,
        CorporatorComplaintListState>((ref) {
  return CorporatorComplaintListNotifier(
      ref.watch(corporatorComplaintRepositoryProvider));
});

// ─────────────────────────────────────────────
// Detail
// ─────────────────────────────────────────────

final corporatorComplaintDetailProvider = FutureProvider
    .autoDispose.family<ComplaintDetail, String>((ref, id) async {
  final repo     = ref.watch(corporatorComplaintRepositoryProvider);
  final response = await repo.fetchDetail(id);
  return response.when(
    success: (data) => data,
    error:   (e)    => throw e,
  );
});

// ─────────────────────────────────────────────
// Action State — shared for all corporator actions
// ─────────────────────────────────────────────

enum CorporatorActionStatus { idle, loading, success, error }

class CorporatorActionState {
  const CorporatorActionState({
    this.status       = CorporatorActionStatus.idle,
    this.errorMessage = '',
  });

  final CorporatorActionStatus status;
  final String                 errorMessage;

  bool get isLoading => status == CorporatorActionStatus.loading;
  bool get isSuccess => status == CorporatorActionStatus.success;
  bool get hasError  => status == CorporatorActionStatus.error;

  CorporatorActionState copyWith({
    CorporatorActionStatus? status,
    String?                 errorMessage,
  }) {
    return CorporatorActionState(
      status:       status       ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// Action Notifier
// ─────────────────────────────────────────────

class CorporatorComplaintActionNotifier
    extends StateNotifier<CorporatorActionState> {
  CorporatorComplaintActionNotifier(this._repo)
      : super(const CorporatorActionState());

  final CorporatorComplaintRepository _repo;

  Future<bool> resolve(
    String id, {
    required String resolutionNotes,
  }) async {
    _setLoading();
    final res = await _repo.resolve(id,
        resolutionNotes: resolutionNotes);
    return _handle(res);
  }

  Future<bool> close(String id) async {
    _setLoading();
    final res = await _repo.close(id);
    return _handle(res);
  }

  Future<bool> reject(String id, {required String reason}) async {
    _setLoading();
    final res = await _repo.reject(id, reason: reason);
    return _handle(res);
  }

  Future<bool> reassign(
    String id, {
    required String leaderId,
  }) async {
    _setLoading();
    final res = await _repo.reassign(id, leaderId: leaderId);
    return _handle(res);
  }

  Future<bool> addNote(
    String id, {
    required String noteText,
    bool isInternal = false,
  }) async {
    _setLoading();
    final res = await _repo.addNote(id,
        noteText: noteText, isInternal: isInternal);
    return _handle(res);
  }

  void _setLoading() => state = state.copyWith(
    status:       CorporatorActionStatus.loading,
    errorMessage: '',
  );

  bool _handle(ApiResponse<Map<String, dynamic>> res) {
    return res.when(
      success: (_) {
        state = state.copyWith(
            status: CorporatorActionStatus.success);
        return true;
      },
      error: (e) {
        state = state.copyWith(
          status:       CorporatorActionStatus.error,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
        return false;
      },
    );
  }

  void reset() => state = const CorporatorActionState();
}

final corporatorComplaintActionProvider = StateNotifierProvider
    .autoDispose<CorporatorComplaintActionNotifier,
        CorporatorActionState>((ref) {
  return CorporatorComplaintActionNotifier(
      ref.watch(corporatorComplaintRepositoryProvider));
});