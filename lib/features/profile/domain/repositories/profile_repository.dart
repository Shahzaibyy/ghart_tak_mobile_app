import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/profile/domain/entities/user_profile.dart';

/// Profile reads.
abstract interface class ProfileRepository {
  /// Returns the signed-in profile.
  Future<Result<UserProfile>> readProfile();
}
