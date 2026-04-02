
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../repositories/leader_complaint_repository.dart';
import '../../../../core/network/api_response.dart';

// ─────────────────────────────────────────────
// Complaint List State
// ─────────────────────────────────────────────

class LeaderComplaintListState {
  const LeaderComplaintListState({
    this.complaints    = const [],
    this.isLoading     = false,
    this.isLoadingMore = false,
    this.hasMore       = true,
    this.currentPage   = 1,
    this.statusFilter,
    this.priorityFilter,
    this.escalatedOnly = false,
    this.errorMessage  = '',
  });

  final List<ComplaintListItem> complaints;
  final bool    isLoading;
  final bool    isLoadingMore;
  final bool    hasMore;
  final int     currentPage;
  final String? statusFilter;
  final String? priorityFilter;
  final bool    escalatedOnly;
  final String  errorMessage;

  bool get hasError => errorMessage.isNotEmpty;
  bool get isEmpty  =>
      !isLoading && complaints.isEmpty && !hasError;

  LeaderComplaintListState copyWith({
    List<ComplaintListItem>? complaints,
    bool?    isLoading,
    bool?    isLoadingMore,
    bool?    hasMore,
    int?     currentPage,
    String?  statusFilter,
    String?  priorityFilter,
    bool?    escalatedOnly,
    String?  errorMessage,
  }) {
    return LeaderComplaintListState(
      complaints:     complaints     ?? this.complaints,
      isLoading:      isLoading      ?? this.isLoading,
      isLoadingMore:  isLoadingMore  ?? this.isLoadingMore,
      hasMore:        hasMore        ?? this.hasMore,
      currentPage:    currentPage    ?? this.currentPage,
      statusFilter:   statusFilter   ?? this.statusFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
      escalatedOnly:  escalatedOnly  ?? this.escalatedOnly,
      errorMessage:   errorMessage   ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// List Notifier
// ─────────────────────────────────────────────

class LeaderComplaintListNotifier
    extends StateNotifier<LeaderComplaintListState> {
  LeaderComplaintListNotifier(this._repo)
      : super(const LeaderComplaintListState()) {
    load();
  }

  final LeaderComplaintRepository _repo;

  Future<void> load({
    String? statusFilter,
    String? priorityFilter,
    bool?   escalatedOnly,
  }) async {
    state = state.copyWith(
      isLoading:      true,
      errorMessage:   '',
      currentPage:    1,
      statusFilter:   statusFilter   ?? state.statusFilter,
      priorityFilter: priorityFilter ?? state.priorityFilter,
      escalatedOnly:  escalatedOnly  ?? state.escalatedOnly,
    );

    final response = await _repo.fetchComplaints(
      page:         1,
      statusFilter: state.statusFilter,
      priority:     state.priorityFilter,
      escalated:    state.escalatedOnly ? true : null,
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

    final response = await _repo.fetchComplaints(
      page:         nextPage,
      statusFilter: state.statusFilter,
      priority:     state.priorityFilter,
      escalated:    state.escalatedOnly ? true : null,
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
      error: (_) => state = state.copyWith(isLoadingMore: false),
    );
  }

  void applyFilters({
    String? statusFilter,
    String? priorityFilter,
    bool?   escalatedOnly,
  }) {
    load(
      statusFilter:   statusFilter,
      priorityFilter: priorityFilter,
      escalatedOnly:  escalatedOnly,
    );
  }

  void clearFilters() {
    load(
      statusFilter:   null,
      priorityFilter: null,
      escalatedOnly:  false,
    );
  }

  /// Refresh a single item after an action (acknowledge, escalate etc.)
  void refreshItem(String complaintId) {
    load(
      statusFilter:   state.statusFilter,
      priorityFilter: state.priorityFilter,
      escalatedOnly:  state.escalatedOnly,
    );
  }
}

final leaderComplaintListProvider = StateNotifierProvider
    .autoDispose<LeaderComplaintListNotifier,
        LeaderComplaintListState>((ref) {
  return LeaderComplaintListNotifier(
      ref.watch(leaderComplaintRepositoryProvider));
});

// ─────────────────────────────────────────────
// Complaint Detail
// ─────────────────────────────────────────────

final leaderComplaintDetailProvider = FutureProvider.autoDispose
    .family<ComplaintDetail, String>((ref, id) async {
  final repo     = ref.watch(leaderComplaintRepositoryProvider);
  final response = await repo.fetchDetail(id);
  return response.when(
    success: (data) => data,
    error:   (e)    => throw e,
  );
});

// ─────────────────────────────────────────────
// Action State — shared for all complaint actions
// ─────────────────────────────────────────────

enum ActionStatus { idle, loading, success, error }

class ComplaintActionState {
  const ComplaintActionState({
    this.status       = ActionStatus.idle,
    this.errorMessage = '',
  });

  final ActionStatus status;
  final String       errorMessage;

  bool get isLoading => status == ActionStatus.loading;
  bool get isSuccess => status == ActionStatus.success;
  bool get hasError  => status == ActionStatus.error;

  ComplaintActionState copyWith({
    ActionStatus? status,
    String?       errorMessage,
  }) {
    return ComplaintActionState(
      status:       status       ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────
// Action Notifier
// ─────────────────────────────────────────────

class ComplaintActionNotifier
    extends StateNotifier<ComplaintActionState> {
  ComplaintActionNotifier(this._repo)
      : super(const ComplaintActionState());

  final LeaderComplaintRepository _repo;

  Future<bool> acknowledge(String id, {String? note}) async {
    state = state.copyWith(
        status: ActionStatus.loading, errorMessage: '');
    final res = await _repo.acknowledge(id, note: note);
    return _handle(res);
  }

  Future<bool> escalate(
      String id, {
    required String priority,
    required String reason,
  }) async {
    state = state.copyWith(
        status: ActionStatus.loading, errorMessage: '');
    final res = await _repo.escalate(id,
        priority: priority, reason: reason);
    return _handle(res);
  }

  Future<bool> addNote(
      String id, {
    required String noteText,
    bool isInternal = false,
  }) async {
    state = state.copyWith(
        status: ActionStatus.loading, errorMessage: '');
    final res =
        await _repo.addNote(id, noteText: noteText, isInternal: isInternal);
    return _handle(res);
  }

  Future<bool> reject(String id, {required String reason}) async {
    state = state.copyWith(
        status: ActionStatus.loading, errorMessage: '');
    final res = await _repo.reject(id, reason: reason);
    return _handle(res);
  }

  Future<bool> markInProgress(String id) async {
    state = state.copyWith(
        status: ActionStatus.loading, errorMessage: '');
    final res = await _repo.updateStatus(id,
        newStatus: 'in_progress');
    return _handle(res);
  }

  bool _handle(ApiResponse<Map<String, dynamic>> res) {
    return res.when(
      success: (_) {
        state = state.copyWith(status: ActionStatus.success);
        return true;
      },
      error: (e) {
        state = state.copyWith(
          status:       ActionStatus.error,
          errorMessage: e is AppException ? e.message : e.toString(),
        );
        return false;
      },
    );
  }

  void reset() => state = const ComplaintActionState();
}

final complaintActionProvider = StateNotifierProvider
    .autoDispose<ComplaintActionNotifier, ComplaintActionState>(
        (ref) {
  return ComplaintActionNotifier(
      ref.watch(leaderComplaintRepositoryProvider));
});

