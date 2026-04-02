// lib/features/voter/dashboard/providers/voter_dashboard_provider.dart
//
// Riverpod AsyncNotifier that drives all sections of the dashboard.
// Fetches all data in parallel and merges into a single VoterDashboardData.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/voter_dashboard_models.dart';
import '../repositories/voter_dashboard_repository.dart';

// -----------------------------------------------------------------------------
// Dashboard Notifier
// -----------------------------------------------------------------------------

class VoterDashboardNotifier extends AsyncNotifier<VoterDashboardData> {
  @override
  Future<VoterDashboardData> build() => _load();

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<VoterDashboardData> _load() async {
    final repo = ref.read(voterDashboardRepositoryProvider);

    // All six calls fire in parallel — no sequential waterfall.
    final futures = <Future<ApiResponse<dynamic>>>[
      repo.fetchProfile(), // [0]
      repo.fetchComplaintSummary(), // [1]
      repo.fetchAnnouncements(), // [2]
      repo.fetchUpcomingEvents(), // [3]
      repo.fetchActiveCampaigns(), // [4]
      repo.fetchLeaderboard(), // [5]
    ];

    final results = await Future.wait(futures);

    // Graceful degradation — a failed section shows empty, not a
    // full-screen error. Critical failures (profile) propagate.
    final profileRes = results[0] as ApiResponse<VoterProfileSummary>;
    if (profileRes.isError) {
      throw profileRes.exception ?? const UnknownException();
    }

    final complaintRes = results[1] as ApiResponse<VoterComplaintSummary>;
    final announcementsRes =
        results[2] as ApiResponse<List<DashboardAnnouncement>>;
    final eventsRes = results[3] as ApiResponse<List<DashboardEvent>>;
    final campaignsRes = results[4] as ApiResponse<List<DashboardCampaign>>;
    final leaderboardRes =
        results[5] as ApiResponse<List<DashboardLeaderboardEntry>>;

    return VoterDashboardData(
      profile: profileRes.data ?? VoterProfileSummary.empty(),
      complaintSummary:
          complaintRes.data ?? VoterComplaintSummary.empty(),
      announcements: announcementsRes.data ?? const [],
      upcomingEvents: eventsRes.data ?? const [],
      activeCampaigns: campaignsRes.data ?? const [],
      leaderboard: leaderboardRes.data ?? const [],
    );
  }

  // ---------------------------------------------------------------------------
  // Public
  // ---------------------------------------------------------------------------

  /// Pull-to-refresh — re-fetches all sections.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }
}

// -----------------------------------------------------------------------------
// Provider
// -----------------------------------------------------------------------------

final voterDashboardProvider =
    AsyncNotifierProvider<VoterDashboardNotifier, VoterDashboardData>(
  VoterDashboardNotifier.new,
);

// -----------------------------------------------------------------------------
// Convenience derived providers
// (read single sections without rebuilding the whole screen)
// -----------------------------------------------------------------------------

final voterProfileSummaryProvider = Provider<VoterProfileSummary?>((ref) {
  return ref.watch(voterDashboardProvider).valueOrNull?.profile;
});
