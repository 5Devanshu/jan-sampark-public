import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/corporator_models.dart';

class CorporatorDashboardRepository extends BaseRepository {
  const CorporatorDashboardRepository(super.dio);

  Future<ApiResponse<AreaDashboard>> fetchDashboard() async {
    return safeCall(() async {
      final res = await dio.get(
          AppConstants.endpointAnalyticsDashboard);
      return AreaDashboard.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<AreaDashboard>> fetchComplaintAnalytics({
    String? period = '30d',
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointAnalyticsComplaints,
        queryParameters: {'period': period},
      );
      return AreaDashboard.fromJson(
          res.data as Map<String, dynamic>);
    });
  }
}

final corporatorDashboardRepositoryProvider =
    Provider<CorporatorDashboardRepository>((ref) {
  return CorporatorDashboardRepository(ref.watch(dioProvider));
});