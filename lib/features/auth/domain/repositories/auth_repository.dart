import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';
import 'package:attock_xpress/features/auth/domain/phone_number.dart';

/// Auth operations available to use cases / onboarding.
abstract interface class AuthRepository {
  /// Restores a session from secure storage, or null when signed out.
  Future<Result<AuthSession?>> currentSession();

  /// Sends an OTP to [phone] for [role] on [channel].
  Future<Result<OtpRequestResult>> requestOtp({
    required String phone,
    required AppRole role,
    OtpChannel channel = OtpChannel.whatsapp,
  });

  /// Verifies [otp] for [phone] / [role] and stores the resulting session.
  Future<Result<AuthSession>> verifyOtp({
    required String phone,
    required AppRole role,
    required String otp,
  });

  /// Email OTP request.
  Future<Result<OtpRequestResult>> requestEmailOtp(String email);

  /// Email OTP verify → session.
  Future<Result<AuthSession>> verifyEmailOtp({
    required String email,
    required String otp,
  });

  /// Google sign-in with a Firebase ID token.
  Future<Result<AuthSession>> signInWithGoogle(String firebaseIdToken);

  /// Dev one-tap login: prefers `/auth/demo/login`, else OTP + `dev_otp`.
  Future<Result<AuthSession>> demoLogin({
    required String phone,
    required AppRole role,
  });

  /// Clears the stored session (and revokes refresh when possible).
  Future<Result<Nothing>> logout();

  /// Opens a local preview session. Tokens are not stored.
  Future<Result<AuthSession>> enterPreview(AppRole role);
}
