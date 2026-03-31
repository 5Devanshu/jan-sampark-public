import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/announcement_models.dart';

class AnnouncementRepository extends BaseRepository {
  const AnnouncementRepository(super.dio);

  Future<ApiResponse<AnnouncementListResponse>> fetchAnnouncements({
    int page = 1,
    int pageSize = 20,
    String? category,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointAnnouncements,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (category != null && category != 'all') 'category': category,
        },
      );
      return AnnouncementListResponse.fromJson(
        res.data as Map<String, dynamic>,
      );
    });
  }

  Future<ApiResponse<AnnouncementModel>> fetchDetail(String id) async {
    return safeCall(() async {
      final res = await dio.get('${AppConstants.endpointAnnouncements}/$id');
      return AnnouncementModel.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> acknowledge(String id) async {
    return safeCall(() async {
      final res = await dio.post(
        '${AppConstants.endpointAnnouncements}/$id/acknowledge',
      );
      return res.data as Map<String, dynamic>;
    });
  }
}

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(ref.watch(dioProvider));
});
