import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ops_constants.dart';
import '../../../core/network/ops_dio_client.dart';
import '../../../core/network/ops_api_response.dart';
import '../models/ops_analytics_models.dart';

// ─────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────

class OpsAnalyticsRepository extends OpsBaseRepository {
  OpsAnalyticsRepository(super.dio);

  /// Fetch platform-wide analytics for a given period.
  ///
  /// Period: '7d', '30d', '90d', '365d'
  Future<OpsApiResponse<OpsAnalyticsData>> fetchAnalytics({
    required String period,
  }) =>
      safeCall(() async {
        final res = await dio.get<Map<String, dynamic>>(
          OpsConstants.endpointAnalytics,
          queryParameters: {
            'period': period,
          },
        );
        final data = res.data ?? {};
        return OpsAnalyticsData.fromJson(data, period: period);
      });

  /// Fetch analytics for a specific area.
  Future<OpsApiResponse<OpsAreaPerformance>> fetchAreaAnalytics({
    required String areaId,
    required String period,
  }) =>
      safeCall(() async {
        final res = await dio.get<Map<String, dynamic>>(
          '${OpsConstants.endpointAnalytics}/areas/$areaId',
          queryParameters: {
            'period': period,
          },
        );
        final data = res.data ?? {};
        return OpsAreaPerformance.fromJson(data);
      });

  /// Fetch comparison data across all areas.
  Future<OpsApiResponse<List<OpsAreaPerformance>>>
      fetchAreaComparison({
    required String period,
    String? sortBy,
    String? sortOrder,
  }) =>
          safeCall(() async {
            final res = await dio.get<List<dynamic>>(
              '${OpsConstants.endpointAnalytics}/areas',
              queryParameters: {
                'period': period,
                if (sortBy != null) 'sort_by': sortBy,
                if (sortOrder != null) 'sort_order': sortOrder,
              },
            );
            final list = res.data ?? [];
            return list
                .map((e) =>
                    OpsAreaPerformance.fromJson(e as Map<String, dynamic>))
                .toList();
          });
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final opsAnalyticsRepositoryProvider =
    Provider<OpsAnalyticsRepository>((ref) {
  return OpsAnalyticsRepository(ref.watch(opsDioProvider));
});
