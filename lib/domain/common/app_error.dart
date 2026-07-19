/// Stable error model for repository and application boundaries.
sealed class AppError implements Exception {
  const AppError({
    required this.code,
    required this.message,
    this.cause,
    this.details,
  });

  final String code;
  final String message;
  final Object? cause;
  final Map<String, Object?>? details;

  @override
  String toString() => 'AppError($code): $message';
}

final class ValidationError extends AppError {
  const ValidationError({
    required super.code,
    required super.message,
    super.cause,
    super.details,
  });
}

final class ConflictError extends AppError {
  const ConflictError({
    required super.code,
    required super.message,
    super.cause,
    super.details,
  });
}

final class NotFoundError extends AppError {
  const NotFoundError({
    required super.code,
    required super.message,
    super.cause,
    super.details,
  });
}

final class StorageError extends AppError {
  const StorageError({
    required super.code,
    required super.message,
    super.cause,
    super.details,
  });
}
