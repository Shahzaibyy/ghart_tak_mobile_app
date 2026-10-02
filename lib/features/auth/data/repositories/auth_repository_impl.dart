import 'package:attock_xpress/core/config/demo_config.dart';
import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/dio_exception_mapper.dart';
import 'package:attock_xpress/core/storage/token_keys.dart';
import 'package:attock_xpress/core/storage/token_store.dart';
import 'package:attock_xpress/features/auth/data/auth_session_store.dart';
import 'package:attock_xpress/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:attock_xpress/features/auth/data/models/auth_session_model.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_user.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';
import 'package:attock_xpress/features/auth/domain/phone_number.dart';
import 'package:attock_xpress/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

/// [AuthRepository] that maps transport errors at this boundary only.
class AuthRepositoryImpl implements AuthRepository {
  /// Creates the repository.
  const new({
    required AuthRemoteDataSource remote,
    required AuthSessionStore sessions,
    required TokenStore tokens,
  }) : _remote = remote,
       _sessions = sessions,
       _tokens = tokens;

  final AuthRemoteDataSource _remote;
  final AuthSessionStore _sessions;
  final TokenStore _tokens;

  @override
  Future<Result<AuthSession?>> currentSession() async {
    try {
      return Success(await _sessions.read());
    } on FormatException {
      return const Err(AuthFailure());
    }
  }

  @override
  Future<Result<OtpRequestResult>> requestOtp({
    required String phone,
    required AppRole role,
    OtpChannel channel = OtpChannel.whatsapp,
  }) async {
    try {
      final result = await _remote.requestOtp(
        phone: normalizePakistaniPhone(phone),
        role: _roleWire(role),
        channel: channel,
      );
      return Success(result);
    } on DioException catch (error) {
      return Err(mapDioException(error));
    }
  }

  @override
  Future<Result<AuthSession>> verifyOtp({
    required String phone,
    required AppRole role,
    required String otp,
  }) async {
    try {
      var model = await _remote.verifyOtp(
        phone: normalizePakistaniPhone(phone),
        role: _roleWire(role),
        otp: otp,
      );
      if (role is CustomerRole) {
        try {
          final profile = await _remote.fetchMe();
          model = model.withProfile(
            name: profile.name,
            phone: profile.phone,
          );
        } on DioException {
          // Session is still valid without the profile enrich.
        }
      }
      await _sessions.save(model);
      return Success(model.toEntity());
    } on DioException catch (error) {
      return Err(mapDioException(error));
    } on FormatException {
      return const Err(ServerFailure());
    }
  }

  @override
  Future<Result<OtpRequestResult>> requestEmailOtp(String email) async {
    try {
      return Success(await _remote.requestEmailOtp(email.trim()));
    } on DioException catch (error) {
      return Err(mapDioException(error));
    }
  }

  @override
  Future<Result<AuthSession>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final model = await _remote.verifyEmailOtp(
        email: email.trim(),
        otp: otp,
      );
      await _sessions.save(model);
      return Success(model.toEntity());
    } on DioException catch (error) {
      return Err(mapDioException(error));
    } on FormatException {
      return const Err(ServerFailure());
    }
  }

  @override
  Future<Result<AuthSession>> signInWithGoogle(String firebaseIdToken) async {
    try {
      final model = await _remote.signInWithGoogle(firebaseIdToken);
      await _sessions.save(model);
      return Success(model.toEntity());
    } on DioException catch (error) {
      return Err(mapDioException(error));
    } on FormatException {
      return const Err(ServerFailure());
    }
  }

  @override
  Future<Result<AuthSession>> demoLogin({
    required String phone,
    required AppRole role,
  }) async {
    final normalized = normalizePakistaniPhone(phone);
    final wire = _roleWire(role);
    final seedName = DemoConfig.accountsFor(role)
        .where((a) => a.phone == normalized)
        .map((a) => a.name)
        .firstOrNull;
    try {
      final direct = await _remote.demoLogin(phone: normalized, role: wire);
      if (direct != null) {
        final saved = await _enrichAndSave(
          direct,
          role,
          seedName: seedName,
          seedPhone: normalized,
        );
        return Success(saved.toEntity());
      }
      // Render may not expose /auth/demo/* yet — OTP + dev_otp is equivalent.
      final otpResult = await _remote.requestOtp(
        phone: normalized,
        role: wire,
      );
      final otp = otpResult.devOtp;
      if (otp == null || otp.isEmpty) {
        return const Err(
          AuthFailure(
            'Demo OTP missing — API must run with APP_ENV=development',
          ),
        );
      }
      var model = await _remote.verifyOtp(
        phone: normalized,
        role: wire,
        otp: otp,
      );
      model = await _enrichAndSave(
        model,
        role,
        seedName: seedName,
        seedPhone: normalized,
      );
      return Success(model.toEntity());
    } on DioException catch (error) {
      return Err(mapDioException(error));
    } on FormatException {
      return const Err(ServerFailure());
    }
  }

  Future<AuthSessionModel> _enrichAndSave(
    AuthSessionModel model,
    AppRole role, {
    String? seedName,
    String? seedPhone,
  }) async {
    var next = model.withProfile(name: seedName, phone: seedPhone);
    if (role is CustomerRole) {
      try {
        final profile = await _remote.fetchMe();
        next = next.withProfile(
          name: profile.name ?? seedName,
          phone: profile.phone ?? seedPhone,
        );
      } on DioException {
        // Session is still valid without the profile enrich.
      }
    }
    await _sessions.save(next);
    return next;
  }

  @override
  Future<Result<AuthSession>> enterPreview(AppRole role) async {
    return Success(_previewSession(role));
  }

  @override
  Future<Result<Nothing>> logout() async {
    try {
      final refresh = await _tokens.read(TokenKeys.refresh) ?? '';
      try {
        await _remote.logout(refresh);
      } on DioException {
        // Always clear local state even if revoke fails.
      }
      await _sessions.clear();
      return const Success(nothing);
    } on FormatException {
      return const Err(AuthFailure());
    }
  }
}

String _roleWire(AppRole role) {
  return switch (role) {
    CustomerRole() => 'customer',
    RiderRole() => 'rider',
  };
}

AuthSession _previewSession(AppRole role) {
  return switch (role) {
    CustomerRole() => const AuthSession(
      user: AppUser(
        id: 'preview-customer',
        role: CustomerRole(),
        name: 'Ayesha Khan',
      ),
    ),
    RiderRole() => const AuthSession(
      user: AppUser(
        id: 'preview-rider',
        role: RiderRole(),
        name: 'Usman Ali',
      ),
    ),
  };
}
