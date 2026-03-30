// lib/features/voter/dashboard/repositories/voter_dashboard_repository.dart
//
// All API calls needed to populate the Voter Dashboard.
// Each method maps to one backend endpoint — no business logic here.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/voter_dashboard_models.dart';

class VoterDashboardRepository extends BaseRepository {
  const VoterDashboardRepository(super.dio);

  // ─────────────────────────────────────────────
  // Profile — GET /users/profile
  // ─────────────────────────────────────────────

  Future<ApiResponse<VoterProfileSummary>> fetchProfile() async {
    return safeCall(() async {
      final res = await dio.get(AppConstants.endpointProfile);
      return VoterProfileSummary.fromJson(
        res.data as Map<String, dynamic>,
      );
    });
  }

  // ─────────────────────────────────────────────
  // Complaint Summary — GET /complaints
  // Pulls first 50 items and counts by status locally.
  // ─────────────────────────────────────────────

  Future<ApiResponse<VoterComplaintSummary>> fetchComplaintSummary() async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointComplaints,
        queryParameters: {'page': 1, 'page_size': 50},
      );
      final body  = res.data as Map<String, dynamic>;
      final items = body['data'] as List<dynamic>? ?? [];
      return VoterComplaintSummary.fromList(items);
    });
  }

  // ─────────────────────────────────────────────
  // Announcements — GET /announcements
  // Latest 5, targeting already filtered server-side.
  // ─────────────────────────────────────────────

  Future<ApiResponse<List<DashboardAnnouncement>>> fetchAnnouncements() async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointAnnouncements,
        queryParameters: {'page': 1, 'page_size': 5},
      );
      final body = res.data as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => DashboardAnnouncement.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  // ─────────────────────────────────────────────
  // Upcoming Events — GET /events?status=upcoming
  // ─────────────────────────────────────────────

  Future<ApiResponse<List<DashboardEvent>>> fetchUpcomingEvents() async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointEvents,
        queryParameters: {'page': 1, 'page_size': 4, 'status': 'upcoming'},
      );
      final body = res.data as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => DashboardEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  // ─────────────────────────────────────────────
  // Active Campaigns — GET /campaigns?status=active
  // ─────────────────────────────────────────────

  Future<ApiResponse<List<DashboardCampaign>>> fetchActiveCampaigns() async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointCampaigns,
        queryParameters: {'page': 1, 'page_size': 4, 'status': 'active'},
      );
      final body = res.data as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => DashboardCampaign.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  // ─────────────────────────────────────────────
  // Leaderboard — GET /leaderboard?limit=5&role=all
  // ─────────────────────────────────────────────

  Future<ApiResponse<List<DashboardLeaderboardEntry>>> fetchLeaderboard() async {
    return safeCall(() async {
      final res = await dio.get(
        '/leaderboard',
        queryParameters: {'limit': 5, 'role': 'all'},
      );
      final body    = res.data as Map<String, dynamic>;
      final entries = body['entries'] as List<dynamic>? ?? [];
      return entries
          .map((e) => DashboardLeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}

// ─────────────────────────────────────────────
// Riverpod Provider
// ─────────────────────────────────────────────

final voterDashboardRepositoryProvider =
    Provider<VoterDashboardRepository>((ref) {
  return VoterDashboardRepository(ref.watch(dioProvider));
});