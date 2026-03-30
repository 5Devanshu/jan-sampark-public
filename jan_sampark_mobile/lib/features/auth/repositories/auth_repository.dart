import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../models/auth_models.dart';

class AuthRepository extends BaseRepository {
  const AuthRepository(super.dio);

  // ─────────────────────────────────────────────
  // OTP
  // ─────────────────────────────────────────────

  Future<ApiResponse<SendOtpResponse>> sendOtp(
      SendOtpRequest request) async {
    return safeCall(() async {
      final res = await dio.post(
        AppConstants.endpointSendOtp,
        data: request.toJson(),
      );
      return SendOtpResponse.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<VerifyOtpResponse>> verifyOtp(
      VerifyOtpRequest request) async {
    return safeCall(() async {
      final res = await dio.post(
        AppConstants.endpointVerifyOtp,
        data: request.toJson(),
      );
      return VerifyOtpResponse.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // Registration
  // ─────────────────────────────────────────────

  Future<ApiResponse<LoginResponse>> register({
    required RegisterRequest request,
    String? documentPath,
  }) async {
    return safeCall(() async {
      // Build multipart form — always multipart so the server
      // can optionally receive the ID document
      final formData = FormData.fromMap({
        ...request.toJson(),
        if (documentPath != null && documentPath.isNotEmpty)
          'id_document': await MultipartFile.fromFile(
            documentPath,
            filename: documentPath.split('/').last,
          ),
      });

      final res = await dio.post(
        AppConstants.endpointRegister,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(
              milliseconds: AppConstants.sendTimeoutMs),
        ),
      );
      return LoginResponse.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // Login
  // ─────────────────────────────────────────────

  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    return safeCall(() async {
      final res = await dio.post(
        AppConstants.endpointLogin,
        data: request.toJson(),
      );
      return LoginResponse.fromJson(
          res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // Areas & Wards (used in registration step 2)
  // ─────────────────────────────────────────────

  Future<ApiResponse<List<AreaModel>>> fetchAreas() async {
    return safeCall(() async {
      final res = await dio.get(AppConstants.endpointAreas);
      final data = res.data as Map<String, dynamic>;
      final list  = data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => AreaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<ApiResponse<List<WardModel>>> fetchWardsByArea(
      String areaId) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointWards,
        queryParameters: {'area_id': areaId},
      );
      final data = res.data as Map<String, dynamic>;
      final list  = data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => WardModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}

// ─────────────────────────────────────────────
// Riverpod Provider
// ─────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});