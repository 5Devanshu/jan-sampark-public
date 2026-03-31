import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/poll_models.dart';

class PollRepository extends BaseRepository {
  const PollRepository(super.dio);

  Future<ApiResponse<PollListResponse>> fetchPolls({
    int page = 1,
    int pageSize = 20,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointPolls,
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return PollListResponse.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<PollModel>> fetchPollDetail(String pollId) async {
    return safeCall(() async {
      final res = await dio.get('${AppConstants.endpointPolls}/$pollId');
      return PollModel.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> vote({
    required String pollId,
    required VoteRequest request,
  }) async {
    return safeCall(() async {
      final res = await dio.post(
        '${AppConstants.endpointPolls}/$pollId/vote',
        data: request.toJson(),
      );
      return res.data as Map<String, dynamic>;
    });
  }

  Future<ApiResponse<PollResults>> fetchResults(String pollId) async {
    return safeCall(() async {
      final res = await dio.get(
        '${AppConstants.endpointPolls}/$pollId/results',
      );
      return PollResults.fromJson(res.data as Map<String, dynamic>);
    });
  }
}

final pollRepositoryProvider = Provider<PollRepository>((ref) {
  return PollRepository(ref.watch(dioProvider));
});
