import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/phone_number.dart';
import 'package:attock_xpress/features/auth/domain/repositories/auth_repository.dart';

/// Asks the backend to send a login OTP after one validation step.
class RequestOtp {
  /// Creates a use case over the repository.
  const new(this._repository);

  final AuthRepository _repository;

  /// Validates [phone], then requests an OTP for [role] on [channel].
  Future<Result<OtpRequestResult>> call({
    required String phone,
    required AppRole role,
    OtpChannel channel = OtpChannel.whatsapp,
  }) {
    final normalized = normalizePakistaniPhone(phone);
    if (!isPakistaniMobile(normalized)) {
      return Future.value(
        const Err(ValidationFailure('Enter a valid Pakistani mobile number')),
      );
    }
    return _repository.requestOtp(
      phone: normalized,
      role: role,
      channel: channel,
    );
  }
}
