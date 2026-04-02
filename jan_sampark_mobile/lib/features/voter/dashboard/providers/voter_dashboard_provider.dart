// lib/features/voter/dashboard/providers/voter_dashboard_provider.dart
//
// Aggregates all dashboard data into a single AsyncNotifier.
// Fetches profile, complaints, announcements, events,
// campaigns, and leaderboard in parallel.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/voter_dashboard_models.dart';
import '../repositories/voter_dashboard_repository.dart';

class VoterDashboardNotifier
    extends AsyncNotifier<VoterDashboardData> {
  @override
  Future<VoterDashboardData> build() async {
    return _fetch();
  }

  Future<VoterDashboardData> _fetch() async {
    final repo = ref.read(voterDashboardRepositoryProvider);

    // Fire all requests in parallel
    final results = await Future.wait([
      repo.fetchProfile(),
      repo.fetchComplaintSummary(),
      repo.fetchAnnouncements(),
      repo.fetchUpcomingEvents(),
      repo.fetchActiveCampaigns(),
      repo.fetchLeaderboard(),
    ]);

    final profileRes       = results[0];
    final complaintRes     = results[1];
    final announcementsRes = results[2];
    final eventsRes        = results[3];
    final campaignsRes     = results[4];
    final leaderboardRes   = results[5];

    // Extract data, falling back to empty on error
    final profile = profileRes.when(
      success: (data) => data as VoterProfileSummary,
      error:   (_)    => VoterProfileSummary.empty(),
    );

    final complaintSummary = complaintRes.when(
      success: (data) => data as VoterComplaintSummary,
      error:   (_)    => VoterComplaintSummary.empty(),
    );

    final announcements = announcementsRes.when(
      success: (data) => data as List<DashboardAnnouncement>,
      error:   (_)    => <DashboardAnnouncement>[],
    );

    final upcomingEvents = eventsRes.when(
      success: (data) => data as List<DashboardEvent>,
      error:   (_)    => <DashboardEvent>[],
    );

    final activeCampaigns = campaignsRes.when(
      success: (data) => data as List<DashboardCampaign>,
      error:   (_)    => <DashboardCampaign>[],
    );

    final leaderboard = leaderboardRes.when(
      success: (data) => data as List<DashboardLeaderboardEntry>,
      error:   (_)    => <DashboardLeaderboardEntry>[],
    );

    return VoterDashboardData(
      profile:          profile,
      complaintSummary: complaintSummary,
      announcements:    announcements,
      upcomingEvents:   upcomingEvents,
      activeCampaigns:  activeCampaigns,
      leaderboard:      leaderboard,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

final voterDashboardProvider =
    AsyncNotifierProvider<VoterDashboardNotifier, VoterDashboardData>(
  VoterDashboardNotifier.new,
);