import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/leader_models.dart';
import '../../complaints/repositories/leader_complaint_repository.dart';

// ─────────────────────────────────────────────
// Leader Profile
// ─────────────────────────────────────────────

final leaderProfileProvider = FutureProvider.autoDispose<LeaderProfile>((
  ref,
) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(AppConstants.endpointMe);
  return LeaderProfile.fromJson(response.data as Map<String, dynamic>);
});

// ─────────────────────────────────────────────
// Ward Complaint Summary
// ─────────────────────────────────────────────

class DashboardState {
  const DashboardState({
    this.summary,
    this.isLoading = false,
    this.errorMessage = '',
  });

  final WardComplaintSummary? summary;
  final bool isLoading;
  final String errorMessage;

  bool get hasError => errorMessage.isNotEmpty;

  DashboardState copyWith({
    WardComplaintSummary? summary,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LeaderDashboardNotifier extends StateNotifier<DashboardState> {
  LeaderDashboardNotifier(this._repo) : super(const DashboardState()) {
    load();
  }

  final LeaderComplaintRepository _repo;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    // Fetch counts for each complaint status
    final results = await Future.wait([
      _repo.fetchComplaints(page: 1, pageSize: 1),
      _repo.fetchComplaints(page: 1, pageSize: 1, statusFilter: 'pending'),
      _repo.fetchComplaints(page: 1, pageSize: 1, statusFilter: 'in_progress'),
      _repo.fetchComplaints(page: 1, pageSize: 1, escalated: true),
      _repo.fetchComplaints(page: 1, pageSize: 1, statusFilter: 'resolved'),
    ]);

    int getTotal(dynamic res) {
      return res.when(success: (data) => data.total as int, error: (_) => 0);
    }

    state = state.copyWith(
      isLoading: false,
      summary: WardComplaintSummary(
        total: getTotal(results[0]),
        pending: getTotal(results[1]),
        inProgress: getTotal(results[2]),
        escalated: getTotal(results[3]),
        resolved: getTotal(results[4]),
      ),
    );
  }
}

final leaderDashboardProvider =
    StateNotifierProvider.autoDispose<LeaderDashboardNotifier, DashboardState>((
      ref,
    ) {
      return LeaderDashboardNotifier(
        ref.watch(leaderComplaintRepositoryProvider),
      );
    });
