import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/ops_constants.dart';
import '../exceptions/ops_exception.dart';
import '../network/ops_api_response.dart';
import '../storage/ops_storage.dart';

// ─────────────────────────────────────────────
// Dio provider
// ─────────────────────────────────────────────

final opsDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl:        OpsConstants.baseUrl,
      connectTimeout: const Duration(
          milliseconds: OpsConstants.connectTimeoutMs),
      receiveTimeout: const Duration(
          milliseconds: OpsConstants.receiveTimeoutMs),
      sendTimeout: const Duration(
          milliseconds: OpsConstants.sendTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept':       'application/json',
      },
    ),
  );

  // Add interceptors in order
  dio.interceptors.addAll([
    _OpsAuthInterceptor(dio),
    _OpsErrorInterceptor(),
    if (const bool.fromEnvironment('dart.vm.product') == false)
      LogInterceptor(
        requestBody:  false,
        responseBody: false,
        logPrint:     (o) => print('[OPS] $o'),
      ),
  ]);

  return dio;
});

// ─────────────────────────────────────────────
// Auth Interceptor — attaches token + handles 401
// ─────────────────────────────────────────────

class _OpsAuthInterceptor extends Interceptor {
  _OpsAuthInterceptor(this._dio);

  final Dio _dio;

  // Lock while refreshing so concurrent calls queue
  bool                   _isRefreshing = false;
  final List<Completer<void>> _queue   = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for auth endpoints
    if (options.path.contains('/auth/')) {
      handler.next(options);
      return;
    }

    final token = await OpsStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Skip if already on refresh endpoint to prevent loop
    if (err.requestOptions.path.contains('/auth/')) {
      await OpsStorage.clearSession();
      handler.next(err);
      return;
    }

    // Queue concurrent 401s while refresh runs
    if (_isRefreshing) {
      final completer = Completer<void>();
      _queue.add(completer);
      await completer.future;

      // Retry with new token
      try {
        final newToken = await OpsStorage.readAccessToken();
        final opts = err.requestOptions;
        if (newToken != null) {
          opts.headers['Authorization'] = 'Bearer $newToken';
        }
        final res = await _dio.request<dynamic>(
          opts.path,
          options: Options(
            method:  opts.method,
            headers: opts.headers,
          ),
          data:            opts.data,
          queryParameters: opts.queryParameters,
        );
        handler.resolve(res);
      } catch (e) {
        handler.next(err);
      }
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await OpsStorage.readRefreshToken();
      if (refreshToken == null) throw const OpsAuthException();

      final refreshResponse = await Dio().post(
        '${OpsConstants.baseUrl}${OpsConstants.endpointRefresh}',
        data: {'refresh_token': refreshToken},
      );

      final data        = refreshResponse.data as Map<String, dynamic>;
      final newAccess   = data['access_token']  as String? ?? '';
      final newRefresh  = data['refresh_token'] as String? ?? '';

      await OpsStorage.writeTokens(
        accessToken:  newAccess,
        refreshToken: newRefresh,
      );

      // Drain queue
      for (final c in _queue) { c.complete(); }
      _queue.clear();

      // Retry original request
      err.requestOptions.headers['Authorization'] =
          'Bearer $newAccess';
      final res = await _dio.request<dynamic>(
        err.requestOptions.path,
        options: Options(
          method:  err.requestOptions.method,
          headers: err.requestOptions.headers,
        ),
        data:            err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
      );
      handler.resolve(res);
    } catch (_) {
      await OpsStorage.clearSession();
      for (final c in _queue) {
        c.completeError(const OpsAuthException());
      }
      _queue.clear();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}

// ─────────────────────────────────────────────
// Error Interceptor — maps DioException → OpsException
// ─────────────────────────────────────────────

class _OpsErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err); // handled in BaseRepository.safeCall
  }
}

// ─────────────────────────────────────────────
// Base Repository
// ─────────────────────────────────────────────

abstract class OpsBaseRepository {
  const OpsBaseRepository(this.dio);
  final Dio dio;

  /// Wraps an async API call in a typed result.
  Future<OpsApiResponse<T>> safeCall<T>(
    Future<T> Function() call,
  ) async {
    try {
      return OpsSuccess(await call());
    } on DioException catch (e) {
      return OpsError(_mapDio(e));
    } on OpsException catch (e) {
      return OpsError(e);
    } catch (e) {
      return OpsError(
          OpsUnknownException(e.toString()));
    }
  }

  OpsException _mapDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const OpsNetworkException();

      case DioExceptionType.badResponse:
        final code   = e.response?.statusCode ?? 0;
        final data   = e.response?.data;
        final detail = data is Map
            ? (data['detail'] as String? ??
               data['message'] as String?)
            : null;
        final message = detail ??
            _statusMessage(code);

        if (code == 401) return const OpsAuthException();
        return OpsApiException(
          statusCode: code,
          message:    message,
          detail:     detail,
        );

      default:
        return OpsUnknownException(
            e.message ?? 'Unknown error');
    }
  }

  String _statusMessage(int code) {
    return switch (code) {
      400 => 'Invalid request.',
      401 => 'Unauthorised. Please sign in.',
      403 => 'You do not have permission.',
      404 => 'Not found.',
      409 => 'Conflict — record already exists.',
      422 => 'Validation error.',
      429 => 'Too many requests. Please slow down.',
      500 => 'Server error. Please try again.',
      503 => 'Service unavailable. Please try later.',
      _   => 'HTTP $code error.',
    };
  }
}