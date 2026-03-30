import 'package:dio/dio.dart';
import '../exceptions/app_exception.dart';
import 'api_constants.dart';

/// Maps DioException into typed [AppException] subclasses.
///
/// Runs after the response is received and after the
/// RefreshInterceptor has had a chance to handle 401s.
///
/// The error is attached to the DioException so the repository
/// layer can catch [AppException] specifically.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = _mapToAppException(err);
    handler.next(err.copyWith(error: appException));
  }

  AppException _mapToAppException(DioException err) {
    // Already mapped by RefreshInterceptor
    if (err.error is AppException) {
      return err.error as AppException;
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _mapHttpError(err);

      case DioExceptionType.cancel:
        return const UnknownException('Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException('SSL certificate error.');

      default:
        return UnknownException(err.message);
    }
  }

  AppException _mapHttpError(DioException err) {
    final statusCode = err.response?.statusCode;
    final detail = _extractDetail(err.response);

    return switch (statusCode) {
      ApiConstants.statusBadRequest => ValidationException(detail),
      ApiConstants.statusUnauthorized => UnauthorizedException(detail),
      ApiConstants.statusForbidden => ForbiddenException(detail),
      ApiConstants.statusNotFound => NotFoundException(detail),
      ApiConstants.statusConflict => ConflictException(detail),
      ApiConstants.statusTooLarge => FileTooLargeException(detail),
      ApiConstants.statusUnprocessable => ValidationException(detail),
      ApiConstants.statusTooManyRequests => RateLimitException(detail),
      >= 500 => ServerException(detail, statusCode),
      _ => UnknownException(detail),
    };
  }

  /// Extracts the error detail string from FastAPI's response body.
  ///
  /// FastAPI returns errors in these formats:
  ///   { "detail": "some message" }
  ///   { "detail": [{"msg": "...", "loc": [...]}] }
  String? _extractDetail(Response? response) {
    if (response?.data == null) return null;

    try {
      final data = response!.data;

      if (data is Map<String, dynamic>) {
        final detail = data['detail'];

        if (detail is String) return detail;

        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map) {
            return first['msg']?.toString() ?? first.toString();
          }
          return detail.first.toString();
        }
      }
    } catch (_) {
      // Ignore parse errors — return null to use default message
    }

    return null;
  }
}
