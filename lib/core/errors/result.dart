import 'package:attock_xpress/core/errors/failure.dart';

/// Success or a typed [Failure]. Exceptions do not cross this type.
sealed class Result<T> {
  const new();
}

/// A completed call that produced [value].
final class Success<T> extends Result<T> {
  /// Creates a successful result.
  const new(this.value);

  /// The produced value.
  final T value;
}

/// A completed call that failed with [failure].
final class Err<T> extends Result<T> {
  /// Creates a failed result.
  const new(this.failure);

  /// Why the call failed.
  final Failure failure;
}

/// Placeholder for a successful call that has no payload.
final class Nothing {
  /// Creates an empty payload.
  const new();
}

/// Shared empty payload for `Result<Nothing>`.
const Nothing nothing = Nothing();
