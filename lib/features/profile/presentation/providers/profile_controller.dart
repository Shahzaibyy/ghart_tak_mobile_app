import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/network_providers.dart';
import 'package:attock_xpress/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:attock_xpress/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:attock_xpress/features/profile/domain/entities/user_profile.dart';
import 'package:attock_xpress/features/profile/domain/repositories/profile_repository.dart';
import 'package:attock_xpress/features/profile/domain/usecases/read_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

/// Live profile repository (`GET /users/me`).
@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(
    ProfileRemoteDataSource(ref.watch(dioProvider)),
  );
}

/// Profile use case.
@riverpod
ReadProfile readProfile(Ref ref) {
  return ReadProfile(ref.watch(profileRepositoryProvider));
}

/// Signed-in profile from the API.
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
