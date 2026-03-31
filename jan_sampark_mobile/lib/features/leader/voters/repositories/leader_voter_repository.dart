import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/leader_voter_models.dart';

class LeaderVoterRepository extends BaseRepository {
  const LeaderVoterRepository(super.dio);

  Future<ApiResponse<VoterListResponse>> fetchVoters({
    int page = 1,
    int pageSize = 20,
    String? search,
    bool? epicVerified,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointVoters,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (epicVerified != null) 'epic_verified': epicVerified,
        },
      );
      return VoterListResponse.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<VoterProfile>> fetchVoterProfile(String voterId) async {
    return safeCall(() async {
      final res = await dio.get('${AppConstants.endpointVoters}/$voterId');
      return VoterProfile.fromJson(res.data as Map<String, dynamic>);
    });
  }
}

final leaderVoterRepositoryProvider = Provider<LeaderVoterRepository>((ref) {
  return LeaderVoterRepository(ref.watch(dioProvider));
});
