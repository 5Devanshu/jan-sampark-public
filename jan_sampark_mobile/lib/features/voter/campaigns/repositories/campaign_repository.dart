import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/campaign_models.dart';

class CampaignRepository extends BaseRepository {
  const CampaignRepository(super.dio);

  // ─────────────────────────────────────────────
  // Campaigns
  // ─────────────────────────────────────────────

  Future<ApiResponse<CampaignListResponse>> fetchCampaigns({
    int page = 1,
    int pageSize = 20,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointCampaigns,
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return CampaignListResponse.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<CampaignModel>> fetchCampaignDetail(
    String campaignId,
  ) async {
    return safeCall(() async {
      final res = await dio.get(
        '${AppConstants.endpointCampaigns}/$campaignId',
      );
      return CampaignModel.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // Donations
  // ─────────────────────────────────────────────

  Future<ApiResponse<DonationModel>> submitDonation({
    required DonateRequest request,
    required String screenshotPath,
  }) async {
    return safeCall(() async {
      final formData = FormData.fromMap({
        ...request.toFormFields(),
        'screenshot': await MultipartFile.fromFile(
          screenshotPath,
          filename: screenshotPath.split('/').last,
        ),
      });

      final res = await dio.post(
        AppConstants.endpointDonations,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(milliseconds: AppConstants.sendTimeoutMs),
        ),
      );
      return DonationModel.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<DonationListResponse>> fetchMyDonations({
    int page = 1,
    int pageSize = 20,
    String? campaignId,
    String? status,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointDonations,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (campaignId != null) 'campaign_id': campaignId,
          if (status != null) 'status': status,
        },
      );
      return DonationListResponse.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<DonationModel>> fetchDonationDetail(
    String donationId,
  ) async {
    return safeCall(() async {
      final res = await dio.get(
        '${AppConstants.endpointDonations}/$donationId',
      );
      return DonationModel.fromJson(res.data as Map<String, dynamic>);
    });
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  return CampaignRepository(ref.watch(dioProvider));
});
