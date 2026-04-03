import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ops_constants.dart';
import '../../../core/network/ops_api_response.dart';
import '../../../core/network/ops_dio_client.dart';
import '../models/ops_dashboard_models.dart';

class OpsDashboardRepository extends OpsBaseRepository {
  const OpsDashboardRepository(super.dio);

  Future<OpsApiResponse<OpsDashboardData>> fetchDashboard({
    String period = '30d',
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        OpsConstants.endpointAnalytics,
        queryParameters: {'period': period},
      );
      return OpsDashboardData.fromJson(
        res.data as Map<String, dynamic>,
        period: period,
      );
    });
  }
}

final opsDashboardRepositoryProvider =
    Provider<OpsDashboardRepository>((ref) {
  return OpsDashboardRepository(ref.watch(opsDioProvider));
});