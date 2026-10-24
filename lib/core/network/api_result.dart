/// Sealed class representing the result of an API operation.
/// Enforces comprehensive handling of success and failure states.
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;

  T? get dataOrNull => switch (this) {
    ApiSuccess<T>(data: final d) => d,
    ApiFailure<T>() => null,
  };

  String? get messageOrNull => switch (this) {
    ApiSuccess<T>(message: final m) => m,
    ApiFailure<T>(message: final m) => m,
  };

  R when<R>({
    required R Function(T data, String? message) success,
    required R Function(String message, int? statusCode, dynamic error) failure,
  }) {
    return switch (this) {
      ApiSuccess<T>(data: final d, message: final m) => success(d, m),
      ApiFailure<T>(
        message: final m,
        statusCode: final code,
        error: final err,
      ) =>
        failure(m, code, err),
    };
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  final String? message;
  final int statusCode;

  const ApiSuccess({required this.data, this.message, this.statusCode = 200});
}

class ApiFailure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  final dynamic error;

  const ApiFailure({required this.message, this.statusCode, this.error});
}
