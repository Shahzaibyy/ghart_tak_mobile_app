import 'package:attock_xpress/features/auth/data/models/auth_session_model.dart';
import 'package:dio/dio.dart';

/// HTTP calls for phone OTP login.
class AuthRemoteDataSource {
  /// Creates a data source over the HTTP client.
  const new(this._dio);

  final Dio _dio;

  /// Requests an OTP. The phone is sent to the API and not logged.
  Future<void> requestOtp(String phone) {
    return _dio.post<void>(
      '/auth/otp/request',
      data: <String, String>{'phone': phone},
    );
  }

  /// Verifies [otp] for [phone].
  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/otp/verify',
      data: <String, String>{'phone': phone, 'otp': otp},
    );
    final raw = response.data;
    if (raw == null) {
      throw const FormatException('Expected an auth session');
    }
    return AuthSessionModel.fromJson(raw);
  }
}
