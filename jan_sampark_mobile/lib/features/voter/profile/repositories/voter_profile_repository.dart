// lib/features/voter/profile/repositories/voter_profile_repository.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/voter_profile_models.dart';

class VoterProfileRepository extends BaseRepository {
  const VoterProfileRepository(super.dio);

  // ── GET /users/profile ───────────────────────

  Future<ApiResponse<VoterProfile>> fetchProfile() async {
    return safeCall(() async {
      final res = await dio.get(AppConstants.endpointProfile);
      return VoterProfile.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ── PUT /users/profile ───────────────────────

  Future<ApiResponse<VoterProfile>> updateProfile(
      ProfileUpdateRequest req) async {
    return safeCall(() async {
      final res = await dio.put(
        AppConstants.endpointProfile,
        data: req.toJson(),
      );
      return VoterProfile.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ── POST /users/profile/photo ────────────────

  Future<ApiResponse<String>> uploadPhoto(File imageFile) async {
    return safeCall(() async {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });
      final res = await dio.post(
        AppConstants.endpointProfilePhoto,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final body = res.data as Map<String, dynamic>;
      return body['profile_photo_url'] as String? ?? '';
    });
  }

  // ── GET /ocr/status ──────────────────────────

  Future<ApiResponse<OcrJobStatus>> fetchOcrStatus() async {
    return safeCall(() async {
      final res = await dio.get(AppConstants.endpointOcrStatus);
      return OcrJobStatus.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ── POST /ocr/retry ──────────────────────────

  Future<ApiResponse<bool>> retryOcr() async {
    return safeCall(() async {
      await dio.post(AppConstants.endpointOcrRetry);
      return true;
    });
  }

  // ── GET /voter/verification-status ───────────

  Future<ApiResponse<EpicVerificationStatus>> fetchVerificationStatus() async {
    return safeCall(() async {
      final res = await dio.get(AppConstants.endpointVoterVerifyStatus);
      return EpicVerificationStatus.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  // ── GET /voter/captcha ───────────────────────

  Future<ApiResponse<CaptchaData>> fetchCaptcha() async {
    return safeCall(() async {
      final res = await dio.get(AppConstants.endpointVoterCaptcha);
      return CaptchaData.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ── POST /voter/search-epic ──────────────────

  Future<ApiResponse<EciVoterResult>> searchByEpic({
    required String sessionId,
    required String epic,
    required String state,
    required String captcha,
  }) async {
    return safeCall(() async {
      final res = await dio.post(
        AppConstants.endpointVoterSearchEpic,
        data: {
          'session_id': sessionId,
          'epic':       epic,
          'state':      state,
          'captcha':    captcha,
        },
      );
      return EciVoterResult.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ── POST /voter/search-details ───────────────

  Future<ApiResponse<EciVoterResult>> searchByDetails({
    required String sessionId,
    required String name,
    required String state,
    required String district,
    required String captcha,
    String? fatherName,
    int?    age,
    String? gender,
  }) async {
    return safeCall(() async {
      final res = await dio.post(
        AppConstants.endpointVoterSearchDetails,
        data: {
          'session_id':  sessionId,
          'name':        name,
          'state':       state,
          'district':    district,
          'captcha':     captcha,
          if (fatherName != null) 'father_name': fatherName,
          if (age != null)        'age':          age,
          if (gender != null)     'gender':       gender,
        },
      );
      return EciVoterResult.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ── POST /voter/save ─────────────────────────

  Future<ApiResponse<bool>> saveVerification({
    required String sessionId,
    required String epicNumber,
    required String stateCode,
    required Map<String, dynamic> eciData,
  }) async {
    return safeCall(() async {
      await dio.post(
        AppConstants.endpointVoterSave,
        data: {
          'session_id':  sessionId,
          'epic_number': epicNumber,
          'state_code':  stateCode,
          'eci_data':    eciData,
        },
      );
      return true;
    });
  }
}

// ─────────────────────────────────────────────
// Riverpod Provider
// ─────────────────────────────────────────────

final voterProfileRepositoryProvider =
    Provider<VoterProfileRepository>((ref) {
  return VoterProfileRepository(ref.watch(dioProvider));
});