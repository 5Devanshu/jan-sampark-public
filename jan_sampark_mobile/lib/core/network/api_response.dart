import '../exceptions/app_exception.dart';

/// Typed wrapper for every API response.
///
/// Every repository method returns ApiResponse<T>.
/// The UI layer checks [ApiResponse.isSuccess] or uses
/// the [when] method to handle success and error cases.
///
/// Usage:
///   final response = await repository.login(data);
///   response.when(
///     success: (data) => ...,
///     error:   (e)    => ...,
///   );
class ApiResponse<T> {
  const ApiResponse._({
    required this.isSuccess,
    this.data,
    this.exception,
    this.statusCode,
  });

  final bool isSuccess;
  final T? data;
  final Exception? exception;
  final int? statusCode;

  // ─────────────────────────────────────────────
  // Constructors
  // ─────────────────────────────────────────────

  factory ApiResponse.success(T data, {int? statusCode}) =>
      ApiResponse._(
        isSuccess:  true,
        data:       data,
        statusCode: statusCode,
      );

  factory ApiResponse.error(Exception exception, {int? statusCode}) =>
      ApiResponse._(
        isSuccess:  false,
        exception:  exception,
        statusCode: statusCode,
      );

  // ─────────────────────────────────────────────
  // Convenience getters
  // ─────────────────────────────────────────────

  bool get isError => !isSuccess;

  /// Returns data or throws if error.
  T get dataOrThrow {
    if (isSuccess && data != null) return data as T;
    throw exception ?? Exception('ApiResponse has no data');
  }

  /// User-facing error message.
  String get errorMessage {
    if (exception == null) return 'Something went wrong.';
    if (exception is AppException) {
      return (exception as AppException).message;
    }
    return exception.toString();
  }

  // ─────────────────────────────────────────────
  // Pattern matching
  // ─────────────────────────────────────────────

  R when<R>({
    required R Function(T data) success,
    required R Function(Exception exception) error,
  }) {
    if (isSuccess && data != null) {
      return success(data as T);
    } else {
      return error(exception ?? UnknownException());
    }
  }

  R? maybeWhen<R>({
    R Function(T data)? success,
    R Function(Exception exception)? error,
  }) {
    if (isSuccess && data != null) {
      return success?.call(data as T);
    } else {
      return error?.call(exception ?? UnknownException());
    }
  }

  @override
  String toString() => isSuccess
      ? 'ApiResponse.success(data: $data)'
      : 'ApiResponse.error(exception: $exception)';
}

// ─────────────────────────────────────────────
// Bring AppException into scope here so
// ApiResponse.errorMessage can reference it
// ─────────────────────────────────────────────
