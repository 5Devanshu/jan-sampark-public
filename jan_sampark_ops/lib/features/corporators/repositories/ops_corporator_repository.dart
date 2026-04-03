import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ops_constants.dart';
import '../../../core/network/ops_api_response.dart';
import '../../../core/network/ops_dio_client.dart';
import '../models/ops_corporator_models.dart';

class OpsCorporatorRepository extends OpsBaseRepository {
  const OpsCorporatorRepository(super.dio);

  // ─────────────────────────────────────────────
  // List
  // ─────────────────────────────────────────────

  Future<OpsApiResponse<OpsCorporatorListResponse>> fetchCorporators({
    int     page     = 1,
    int     pageSize = OpsConstants.defaultPageSize,
    String? search,
    String? areaId,
    bool?   isActive,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        OpsConstants.endpointCorporators,
        queryParameters: {
          'page':      page,
          'page_size': pageSize,
          if (search   != null && search.isNotEmpty)
            'search':    search,
          if (areaId   != null) 'area_id':   areaId,
          if (isActive != null) 'is_active':  isActive,
        },
      );
      return OpsCorporatorListResponse.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // Detail
  // ─────────────────────────────────────────────

  Future<OpsApiResponse<OpsCorporatorDetail>> fetchDetail(
      String corporatorId) async {
    return safeCall(() async {
      final res = await dio.get(
          '${OpsConstants.endpointCorporators}/$corporatorId');
      return OpsCorporatorDetail.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // Create
  // ─────────────────────────────────────────────

  Future<OpsApiResponse<Map<String, dynamic>>> create(
      OpsCreateCorporatorRequest request) async {
    return safeCall(() async {
      final res = await dio.post(
        OpsConstants.endpointCorporators,
        data: request.toJson(),
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ─────────────────────────────────────────────
  // Toggle active / inactive
  // ─────────────────────────────────────────────

  Future<OpsApiResponse<Map<String, dynamic>>> setActive(
    String corporatorId, {
    required bool isActive,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${OpsConstants.endpointCorporators}/$corporatorId',
        data: {'is_active': isActive},
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ─────────────────────────────────────────────
  // Reset password
  // ─────────────────────────────────────────────

  Future<OpsApiResponse<Map<String, dynamic>>> resetPassword(
    String corporatorId, {
    required String newPassword,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${OpsConstants.endpointCorporators}/$corporatorId/password',
        data: {'new_password': newPassword},
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ─────────────────────────────────────────────
  // Update ward assignments
  // ─────────────────────────────────────────────

  Future<OpsApiResponse<Map<String, dynamic>>> updateWards(
    String corporatorId, {
    required List<String> wardIds,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${OpsConstants.endpointCorporators}/$corporatorId/wards',
        data: {'assigned_ward_ids': wardIds},
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ─────────────────────────────────────────────
  // Area + Ward option lists (for forms)
  // ─────────────────────────────────────────────

  Future<OpsApiResponse<List<OpsAreaOption>>> fetchAreaOptions() async {
    return safeCall(() async {
      final res = await dio.get(
        OpsConstants.endpointAreas,
        queryParameters: {'page_size': OpsConstants.maxPageSize},
      );
      final data = res.data as Map<String, dynamic>;
      return (data['data'] as List<dynamic>? ?? [])
          .map((e) => OpsAreaOption.fromJson(
              e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<OpsApiResponse<List<OpsWardOption>>> fetchWardOptions(
      String areaId) async {
    return safeCall(() async {
      final res = await dio.get(
        OpsConstants.endpointWards,
        queryParameters: {
          'area_id':   areaId,
          'page_size': OpsConstants.maxPageSize,
        },
      );
      final data = res.data as Map<String, dynamic>;
      return (data['data'] as List<dynamic>? ?? [])
          .map((e) => OpsWardOption.fromJson(
              e as Map<String, dynamic>))
          .toList();
    });
  }
}

final opsCorporatorRepositoryProvider =
    Provider<OpsCorporatorRepository>((ref) {
  return OpsCorporatorRepository(ref.watch(opsDioProvider));
});