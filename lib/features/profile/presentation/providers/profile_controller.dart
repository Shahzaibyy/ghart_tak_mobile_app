import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/profile/data/sample_profile.dart';
import 'package:attock_xpress/features/profile/domain/entities/user_profile.dart';
import 'package:attock_xpress/features/profile/domain/repositories/profile_repository.dart';
import 'package:attock_xpress/features/profile/domain/usecases/read_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

/// Profile repository.
@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return const SampleProfileRepository();
}

/// Profile use case.
@riverpod
ReadProfile readProfile(Ref ref) {
  return ReadProfile(ref.watch(profileRepositoryProvider));
}

/// Signed-in profile.
@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<UserProfile> build() async {
    final result = await ref.watch(readProfileProvider).call();
    return switch (result) {
      Success(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }
}
