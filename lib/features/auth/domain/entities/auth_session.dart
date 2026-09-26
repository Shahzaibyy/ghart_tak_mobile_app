import 'package:attock_xpress/features/auth/domain/entities/app_user.dart';

/// Active session. Tokens stay in secure storage, not on this object.
class AuthSession {
  /// Creates a session for [user].
  const new({required this.user});

  /// Signed-in user.
  final AppUser user;
}
