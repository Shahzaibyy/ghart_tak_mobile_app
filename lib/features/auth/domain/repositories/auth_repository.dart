import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';

/// Auth operations available to use cases.
abstract interface class AuthRepository {
  /// Restores a session from secure storage, or null when signed out.
  Future<Result<AuthSession?>> currentSession();

  /// Sends an OTP to [phone]. The phone is not logged.
  Future<Result<Nothing>> requestOtp(String phone);

  /// Verifies [otp] for [phone] and stores the resulting session.
  Future<Result<AuthSession>> verifyOtp({
    required String phone,
    required String otp,
  });

  /// Clears the stored session.
  Future<Result<Nothing>> logout();
}
