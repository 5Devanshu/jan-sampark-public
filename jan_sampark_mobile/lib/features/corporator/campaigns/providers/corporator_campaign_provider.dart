import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../voter/campaigns/models/campaign_models.dart';
import '../../../voter/campaigns/repositories/campaign_repository.dart';

// ─────────────────────────────────────────────
// Reuse voter campaign list provider
// ─────────────────────────────────────────────

export '../../../voter/campaigns/providers/campaign_provider.dart'
    show campaignListProvider, campaignDetailProvider;

// ─────────────────────────────────────────────
// Create Campaign State
// ─────────────────────────────────────────────

class CreateCampaignState {
  const CreateCampaignState({
    this.isLoading      = false,
    this.isSuccess      = false,
    this.errorMessage   = '',
    this.createdId,
  });

  final bool    isLoading;
  final bool    isSuccess;
  final String  errorMessage;
  final String? createdId;

  bool get hasError => errorMessage.isNotEmpty;

  CreateCampaignState copyWith({
    bool?   isLoading,
    bool?   isSuccess,
    String? errorMessage,
    String? createdId,
  }) {
    return CreateCampaignState(
      isLoading:    isLoading    ?? this.isLoading,
      isSuccess:    isSuccess    ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      createdId:    createdId    ?? this.createdId,
    );
  }
}

class CreateCampaignNotifier
    extends StateNotifier<CreateCampaignState> {
  CreateCampaignNotifier(this._dio)
      : super(const CreateCampaignState());

  final Dio _dio;

  Future<bool> create({
    required String title,
    required String description,
    required String campaignType,
    required double targetAmount,
    required String startDate,
    required String endDate,
    String? coverImagePath,
  }) async {
    state = state.copyWith(
      isLoading: true, errorMessage: '', isSuccess: false,
    );

    try {
      final fields = <String, dynamic>{
        'title':         title,
        'description':   description,
        'campaign_type': campaignType,
        'target_amount': targetAmount,
        'start_date':    startDate,
        'end_date':      endDate,
      };

      dynamic data;
      if (coverImagePath != null && coverImagePath.isNotEmpty) {
        data = FormData.fromMap({
          ...fields,
          'cover_image': await MultipartFile.fromFile(
            coverImagePath,
            filename: coverImagePath.split('/').last,
          ),
        });
      } else {
        data = fields;
      }

      final res = await _dio.post(
        AppConstants.endpointCampaigns,
        data: data,
      );

      final id =
          (res.data as Map<String, dynamic>)['id'] as String? ?? '';

      state = state.copyWith(
        isLoading: false, isSuccess: true, createdId: id,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading:    false,
        errorMessage: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const CreateCampaignState();
}

final createCampaignProvider = StateNotifierProvider
    .autoDispose<CreateCampaignNotifier, CreateCampaignState>((ref) {
  return CreateCampaignNotifier(ref.watch(dioProvider));
});

// ─────────────────────────────────────────────
// Pending Donations for a campaign
// ─────────────────────────────────────────────

final campaignPendingDonationsProvider = FutureProvider
    .autoDispose
    .family<DonationListResponse, String>((ref, campaignId) async {
  final repo     = ref.watch(campaignRepositoryProvider);
  final response = await repo.fetchMyDonations(
    page:       1,
    pageSize:   50,
    campaignId: campaignId,
    status:     'pending',
  );
  return response.when(
    success: (data) => data,
    error:   (e)    => throw e,
  );
});

// ─────────────────────────────────────────────
// All pending donations (across campaigns)
// ─────────────────────────────────────────────

final allPendingDonationsProvider = FutureProvider
    .autoDispose<DonationListResponse>((ref) async {
  final repo     = ref.watch(campaignRepositoryProvider);
  final response = await repo.fetchMyDonations(
    page:     1,
    pageSize: 50,
    status:   'pending',
  );
  return response.when(
    success: (data) => data,
    error:   (e)    => throw e,
  );
});

// ─────────────────────────────────────────────
// Donation verify action
// ─────────────────────────────────────────────

enum DonationVerifyStatus { idle, loading, success, error }

class DonationVerifyState {
  const DonationVerifyState({
    this.status       = DonationVerifyStatus.idle,
    this.errorMessage = '',
  });
  final DonationVerifyStatus status;
  final String               errorMessage;

  bool get isLoading => status == DonationVerifyStatus.loading;
  bool get isSuccess => status == DonationVerifyStatus.success;
  bool get hasError  => status == DonationVerifyStatus.error;

  DonationVerifyState copyWith({
    DonationVerifyStatus? status,
    String?               errorMessage,
  }) {
    return DonationVerifyState(
      status:       status       ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DonationVerifyNotifier
    extends StateNotifier<DonationVerifyState> {
  DonationVerifyNotifier(this._dio)
      : super(const DonationVerifyState());

  final Dio _dio;

  Future<bool> verify({
    required String donationId,
    required bool   accept,
    String?         rejectionReason,
  }) async {
    state = state.copyWith(
      status:       DonationVerifyStatus.loading,
      errorMessage: '',
    );

    try {
      await _dio.patch(
        '${AppConstants.endpointDonations}/$donationId/verify',
        data: {
          'action': accept ? 'accept' : 'reject',
          if (!accept && rejectionReason != null)
            'rejection_reason': rejectionReason,
        },
      );
      state = state.copyWith(
          status: DonationVerifyStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status:       DonationVerifyStatus.error,
        errorMessage: e is AppException ? e.message : e.toString(),
      );
      return false;
    }
  }

  void reset() => state = const DonationVerifyState();
}

final donationVerifyProvider = StateNotifierProvider
    .autoDispose<DonationVerifyNotifier, DonationVerifyState>(
        (ref) {
  return DonationVerifyNotifier(ref.watch(dioProvider));
});