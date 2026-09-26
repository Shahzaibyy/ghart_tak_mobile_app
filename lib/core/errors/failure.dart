/// Typed failure produced at the repository boundary.
///
/// Presentation code switches on the subtype. It does not inspect
/// raw exception text.
sealed class Failure implements Exception {
  /// Creates a failure with a user-safe [message].
  const new(this.message);

  /// Short copy safe to show in the UI.
  final String message;

  @override
  String toString() => message;
}

/// The device could not reach the server.
final class NetworkFailure extends Failure {
  /// Creates a network failure.
  const new([super.message = 'You appear to be offline']);
}

/// The server returned an unexpected response.
final class ServerFailure extends Failure {
  /// Creates a server failure.
  const new([super.message = 'Something went wrong']);
}

/// Input was rejected before a request was sent.
final class ValidationFailure extends Failure {
  /// Creates a validation failure.
  const new([super.message = 'Check the details and try again']);
}

/// The session is missing or was rejected.
final class AuthFailure extends Failure {
  /// Creates an auth failure.
  const new([super.message = 'Sign in again to continue']);
}
