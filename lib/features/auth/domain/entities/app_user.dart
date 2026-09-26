import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';

/// Signed-in user. Phone numbers stay out of this type.
class AppUser {
  /// Creates a user.
  const new({required this.id, required this.role, this.name});

  /// Stable user id.
  final String id;

  /// Customer or rider.
  final AppRole role;

  /// Display name, when the account has one.
  final String? name;
}
