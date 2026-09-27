import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/profile/domain/entities/user_profile.dart';
import 'package:attock_xpress/features/profile/domain/repositories/profile_repository.dart';

/// Profile used while the account API is offline.
class SampleProfileRepository implements ProfileRepository {
  /// Creates the sample profile.
  const new();

  @override
  Future<Result<UserProfile>> readProfile() async {
    return const Success(
      UserProfile(displayName: 'Ayesha Khan', phone: '0300 0000000'),
    );
  }
}
