import '../exceptions/ops_exception.dart';

/// Typed wrapper for every API response.
///
/// Every repository method returns OpsApiResponse<T>.
/// The UI layer checks [OpsApiResponse.isSuccess] or uses
/// pattern matching to handle success and error cases.
///
/// Usage:
///   final response = await repository.login(data);
///   if (response is OpsSuccess<Data>) {
///     // Handle success
///   } else if (response is OpsError) {
///     // Handle error
///   }
sealed class OpsApiResponse<T> {
  const OpsApiResponse();

  bool get isSuccess;
  bool get isError => !isSuccess;

  /// Pattern match on success/error without the sealed pattern.
  R when<R>({
    required R Function(T data) success,
    required R Function(OpsException exception) error,
  }) {
    if (this is OpsSuccess<T>) {
      return success((this as OpsSuccess<T>).data);
    } else if (this is OpsError) {
      return error((this as OpsError).exception);
    }
    throw StateError('Unexpected OpsApiResponse type');
  }
}

/// Successful API response with typed data.
class OpsSuccess<T> extends OpsApiResponse<T> {
  const OpsSuccess(this.data);

  final T data;

  @override
  bool get isSuccess => true;
}

/// Failed API response with exception.
class OpsError extends OpsApiResponse<Never> {
  const OpsError(this.exception);

  final OpsException exception;

  @override
  bool get isSuccess => false;
}
