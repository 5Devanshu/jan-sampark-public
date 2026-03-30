// lib/features/voter/dashboard/providers/voter_dashboard_provider.dart
//
// Riverpod AsyncNotifier that drives all sections of the dashboard.
// Fetches all data in parallel and merges into a single VoterDashboardData.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/voter_dashboard_models.dart';
import '../repositories/voter_dashboard_repository.dart';

// ─────────────────────────────────────────────
// Dashboard Notifier
// ─────────────────────────────────────────────

class VoterDashboardNotifier
    extends AsyncNotifier<VoterDashboardData> {
  @override
  Future<VoterDashboardData> build() => _load();

  // ── Private ───────────────────────────────────

  Future<VoterDashboardData> _load() async {
    final repo = ref.read(voterDashboardRepositoryProvider);

    // All six calls fire in parallel — no sequential waterfall.
    final results = await Future.wait([
      repo.fetchProfile(),            // [0]
      repo.fetchComplaintSummary(),   // [1]
      repo.fetchAnnouncements(),      // [2]
      repo.fetchUpcomingEvents(),     // [3]
      repo.fetchActiveCampaigns(),    // [4]
      repo.fetchLeaderboard(),        // [5]
    ]);

    // Graceful degradation — a failed section shows empty, not a
    // full-screen error.  Critical failures (profile) propagate.
    final profileRes   = results[0];
    if (profileRes.hasError) {
      throw profileRes.error!;
    }

    return VoterDashboardData(
      profile:          profileRes.data   ?? VoterProfileSummary.empty(),
      complaintSummary: results[1].data   ?? VoterComplaintSummary.empty(),
      announcements:    results[2].data   ?? const [],
      upcomingEvents:   results[3].data   ?? const [],
      activeCampaigns:  results[4].data   ?? const [],
      leaderboard:      results[5].data   ?? const [],
    );
  }

  // ── Public ────────────────────────────────────

  /// Pull-to-refresh — re-fetches all sections.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final voterDashboardProvider =
    AsyncNotifierProvider<VoterDashboardNotifier, VoterDashboardData>(
  VoterDashboardNotifier.new,
);

// ─────────────────────────────────────────────
// Convenience derived providers
// (read single sections without rebuilding the whole screen)
// ─────────────────────────────────────────────

final voterProfileSummaryProvider = Provider<VoterProfileSummary?>((ref) {
  return ref.watch(voterDashboardProvider).valueOrNull?.profile;
});