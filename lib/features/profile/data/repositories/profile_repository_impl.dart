import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/dio_exception_mapper.dart';
import 'package:attock_xpress/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:attock_xpress/features/profile/domain/entities/user_profile.dart';
import 'package:attock_xpress/features/profile/domain/repositories/profile_repository.dart';
import 'package:dio/dio.dart';

/// [ProfileRepository] that maps transport errors once.
class ProfileRepositoryImpl implements ProfileRepository {
  /// Creates the repository.
  const new(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<Result<UserProfile>> readProfile() async {
    try {
      final model = await _remote.readProfile();
      return Success(model.toEntity());
    } on DioException catch (error) {
      return Err(mapDioException(error));
    } on FormatException {
      return const Err(ServerFailure());
    }
  }
}
