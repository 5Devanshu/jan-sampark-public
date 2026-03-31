import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/helpline_models.dart';

class HelplineRepository extends BaseRepository {
  const HelplineRepository(super.dio);

  Future<ApiResponse<HelplineListResponse>> fetchHelplines({
    String? category,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointHelpline,
        queryParameters: {if (category != null) 'category': category},
      );
      return HelplineListResponse.fromJson(res.data as Map<String, dynamic>);
    });
  }
}

final helplineRepositoryProvider = Provider<HelplineRepository>((ref) {
  return HelplineRepository(ref.watch(dioProvider));
});
