import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ops_constants.dart';
import '../../../core/network/ops_api_response.dart';
import '../../../core/network/ops_dio_client.dart';
import '../models/ops_complaint_models.dart';

class OpsComplaintRepository extends OpsBaseRepository {
  const OpsComplaintRepository(super.dio);

  Future<OpsApiResponse<OpsComplaintListResponse>>
      fetchComplaints({
    int     page          = 1,
    int     pageSize      = OpsConstants.defaultPageSize,
    String? status,
    String? priority,
    String? areaId,
    String? categoryId,
    bool?   escalatedOnly,
    String? search,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        OpsConstants.endpointComplaints,
        queryParameters: {
          'page':      page,
          'page_size': pageSize,
          if (status        != null) 'status':       status,
          if (priority      != null) 'priority':     priority,
          if (areaId        != null) 'area_id':      areaId,
          if (categoryId    != null) 'category_id':  categoryId,
          if (escalatedOnly == true) 'escalated':    true,
          if (search != null && search.isNotEmpty)
            'search': search,
        },
      );
      return OpsComplaintListResponse.fromJson(
          res.data as Map<String, dynamic>);
    });
  }
}

final opsComplaintRepositoryProvider =
    Provider<OpsComplaintRepository>((ref) {
  return OpsComplaintRepository(ref.watch(opsDioProvider));
});