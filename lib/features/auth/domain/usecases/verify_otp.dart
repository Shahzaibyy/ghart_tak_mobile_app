import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';
import 'package:attock_xpress/features/auth/domain/repositories/auth_repository.dart';

/// Exchanges a phone OTP for a session.
class VerifyOtp {
  /// Creates a use case over the repository.
  const new(this._repository);

  final AuthRepository _repository;

  /// Verifies [otp] for [phone].
  Future<Result<AuthSession>> call({
    required String phone,
    required String otp,
  }) {
    if (otp.length != 6) {
      return Future.value(
        const Err(ValidationFailure('Enter the 6-digit code')),
      );
    }
    return _repository.verifyOtp(phone: phone, otp: otp);
  }
}
