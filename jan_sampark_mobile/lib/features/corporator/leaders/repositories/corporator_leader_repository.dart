import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/corporator_leader_models.dart';

class CorporatorLeaderRepository extends BaseRepository {
  const CorporatorLeaderRepository(super.dio);

  // ─────────────────────────────────────────────
  // List
  // ─────────────────────────────────────────────

  Future<ApiResponse<LeaderListResponse>> fetchLeaders({
    int    page     = 1,
    int    pageSize = 20,
    String? search,
    String? wardId,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointLeaders,
        queryParameters: {
          'role':      'leader',
          'page':      page,
          'page_size': pageSize,
          if (search != null && search.isNotEmpty)
            'search': search,
          if (wardId != null) 'ward_id': wardId,
        },
      );
      return LeaderListResponse.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // Detail
  // ─────────────────────────────────────────────

  Future<ApiResponse<CorporatorLeaderDetail>> fetchLeaderDetail(
      String leaderId) async {
    return safeCall(() async {
      final res = await dio.get(
          '${AppConstants.endpointLeaders}/$leaderId');
      return CorporatorLeaderDetail.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // Create
  // ─────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> createLeader(
      CreateLeaderRequest request) async {
    return safeCall(() async {
      final res = await dio.post(
        AppConstants.endpointLeaders,
        data: request.toJson(),
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ─────────────────────────────────────────────
  // Update responsibilities
  // ─────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> updateResponsibilities(
    String leaderId, {
    required List<String> responsibilities,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointLeaders}/$leaderId/responsibilities',
        data: {'leader_responsibilities': responsibilities},
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ─────────────────────────────────────────────
  // Toggle active
  // ─────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> toggleActive(
    String leaderId, {
    required bool isActive,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointLeaders}/$leaderId',
        data: {'is_active': isActive},
      );
      return res.data as Map<String, dynamic>;
    });
  }
}

final corporatorLeaderRepositoryProvider =
    Provider<CorporatorLeaderRepository>((ref) {
  return CorporatorLeaderRepository(ref.watch(dioProvider));
});
