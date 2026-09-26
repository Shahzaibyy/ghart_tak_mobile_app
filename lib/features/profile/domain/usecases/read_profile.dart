import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/profile/domain/entities/user_profile.dart';
import 'package:attock_xpress/features/profile/domain/repositories/profile_repository.dart';

/// Loads the profile.
class ReadProfile {
  /// Creates a use case over the repository.
  const new(this._repository);

  final ProfileRepository _repository;

  /// Fetches the profile.
  Future<Result<UserProfile>> call() => _repository.readProfile();
}
