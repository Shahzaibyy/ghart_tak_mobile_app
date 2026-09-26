/// Secure-storage keys for the auth session.
abstract final class TokenKeys {
  /// Short-lived JWT.
  static const access = 'access_token';

  /// Rotating refresh token.
  static const refresh = 'refresh_token';

  /// Serialized session used to restore the signed-in user.
  static const session = 'auth_session';
}
