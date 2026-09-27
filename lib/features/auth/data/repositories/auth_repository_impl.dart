import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/dio_exception_mapper.dart';
import 'package:attock_xpress/features/auth/data/auth_session_store.dart';
import 'package:attock_xpress/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_user.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';
import 'package:attock_xpress/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

/// [AuthRepository] that maps transport errors at this boundary only.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates the repository.
  const new({
    required this._remote,
    required this._sessions,
  });

  final AuthRemoteDataSource _remote;
  final AuthSessionStore _sessions;

  @override
  Future<Result<AuthSession?>> currentSession() async {
    try {
      return Success(await _sessions.read());
    } on FormatException {
      return const Err(AuthFailure());
    }
  }

  @override
  Future<Result<Nothing>> requestOtp(String phone) async {
    try {
      await _remote.requestOtp(phone);
      return const Success(nothing);
    } on DioException catch (error) {
      return Err(mapDioException(error));
    }
  }

  @override
  Future<Result<AuthSession>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final model = await _remote.verifyOtp(phone: phone, otp: otp);
      await _sessions.save(model);
      return Success(model.toEntity());
    } on DioException catch (error) {
      return Err(mapDioException(error));
    } on FormatException {
      return const Err(ServerFailure());
    }
  }

  @override
  Future<Result<AuthSession>> enterPreview(AppRole role) async {
    return Success(_previewSession(role));
  }

  @override
  Future<Result<Nothing>> logout() async {
    try {
      await _sessions.clear();
      return const Success(nothing);
    } on FormatException {
      return const Err(AuthFailure());
    }
  }
}

AuthSession _previewSession(AppRole role) {
  return switch (role) {
    CustomerRole() => const AuthSession(
      user: AppUser(
        id: 'preview-customer',
        role: CustomerRole(),
        name: 'Ayesha',
      ),
    ),
    RiderRole() => const AuthSession(
      user: AppUser(
        id: 'preview-rider',
        role: RiderRole(),
        name: 'Hamza',
      ),
    ),
  };
}
