import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/ops_dio_client.dart';
import '../../../core/network/ops_api_response.dart';
import '../../../core/constants/ops_constants.dart';
import '../models/ops_auth_models.dart';

// ─────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────

class OpsAuthRepository extends OpsBaseRepository {
  OpsAuthRepository(super.dio);

  /// Login with mobile number and password.
  ///
  /// Returns OpsLoginResponse with tokens on success.
  /// Throws OpsApiException on authentication failure.
  Future<OpsApiResponse<OpsLoginResponse>> login({
    required String mobile,
    required String password,
  }) =>
      safeCall(() async {
        final res = await dio.post<Map<String, dynamic>>(
          OpsConstants.endpointLogin,
          data: {
            'mobile':   mobile,
            'password': password,
          },
        );
        final data = res.data ?? {};
        return OpsLoginResponse.fromJson(data);
      });

  /// Refresh expired access token using refresh token.
  Future<OpsApiResponse<OpsLoginResponse>> refresh({
    required String refreshToken,
  }) =>
      safeCall(() async {
        final res = await dio.post<Map<String, dynamic>>(
          OpsConstants.endpointRefresh,
          data: {
            'refresh_token': refreshToken,
          },
        );
        final data = res.data ?? {};
        return OpsLoginResponse.fromJson(data);
      });

  /// Get current user info (requires valid token).
  Future<OpsApiResponse<OpsLoginResponse>> getMe() =>
      safeCall(() async {
        final res = await dio.get<Map<String, dynamic>>(
          OpsConstants.endpointMe,
        );
        final data = res.data ?? {};
        return OpsLoginResponse.fromJson(data);
      });

  /// Logout — invalidate tokens on server.
  Future<OpsApiResponse<Map<String, dynamic>>> logout() =>
      safeCall(() async {
        final res = await dio.post<Map<String, dynamic>>(
          OpsConstants.endpointLogout,
        );
        return res.data ?? {};
      });
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final opsAuthRepositoryProvider =
    Provider<OpsAuthRepository>((ref) {
  return OpsAuthRepository(ref.watch(opsDioProvider));
});
