import 'package:attock_xpress/core/network/api_envelope.dart';
import 'package:attock_xpress/features/auth/data/models/auth_session_model.dart';
import 'package:attock_xpress/features/auth/domain/phone_number.dart';
import 'package:dio/dio.dart';

/// Result of `POST /auth/otp/request` / email request (may include `dev_otp`).
class OtpRequestResult {
  /// Creates a request result.
  const new({this.devOtp});

  /// Development-only OTP. Null outside `APP_ENV=development`.
  final String? devOtp;
}

/// Customer profile from `GET /users/me`.
class ProfileDto {
  /// Creates a profile DTO.
  const new({
    required this.id,
    required this.phoneVerified,
    required this.walletBalance,
    this.name,
    this.email,
    this.phone,
  });

  final String id;
  final String? name;
  final String? email;
  final String? phone;
  final bool phoneVerified;
  final String walletBalance;

  factory fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) throw const FormatException('Invalid profile');
    return ProfileDto(
      id: id,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      phoneVerified: json['phone_verified'] == true,
      walletBalance: (json['wallet_balance'] as String?) ?? '0.00',
    );
  }
}

/// HTTP calls for phone/email OTP, Google, and profile.
class AuthRemoteDataSource {
  /// Creates a data source over the HTTP client.
  const new(this._dio);

  final Dio _dio;

  /// Requests an OTP. Returns `dev_otp` when the API is in development.
  Future<OtpRequestResult> requestOtp({
    required String phone,
    required String role,
    OtpChannel channel = OtpChannel.whatsapp,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/otp/request',
      data: <String, String>{
        'phone': phone,
        'role': role,
        'channel': otpChannelWire(channel),
      },
    );
    return _otpFrom(response);
  }

  /// Verifies [otp] for [phone] and [role].
  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String role,
    required String otp,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/otp/verify',
      data: <String, String>{
        'phone': phone,
        'role': role,
        'otp': otp,
      },
    );
    final data = unwrapData<Map<String, dynamic>>(response);
    return AuthSessionModel.fromSessionJson(data);
  }

  /// Email OTP request (`POST /auth/email/request`).
  Future<OtpRequestResult> requestEmailOtp(String email) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/email/request',
      data: <String, String>{'email': email},
    );
    return _otpFrom(response);
  }

  /// Email OTP verify → session.
  Future<AuthSessionModel> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/email/verify',
      data: <String, String>{'email': email, 'otp': otp},
    );
    final data = unwrapData<Map<String, dynamic>>(response);
    return AuthSessionModel.fromSessionJson(data);
  }

  /// Google / Firebase sign-in (customer). May return 503 until configured.
  Future<AuthSessionModel> signInWithGoogle(String firebaseIdToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/google',
      data: <String, String>{'firebase_id_token': firebaseIdToken},
    );
    final data = unwrapData<Map<String, dynamic>>(response);
    return AuthSessionModel.fromSessionJson(data);
  }

  /// Loads the signed-in customer profile.
  Future<ProfileDto> fetchMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/users/me');
    final data = unwrapData<Map<String, dynamic>>(response);
    return ProfileDto.fromJson(data);
  }

  /// Revokes the refresh token. Ignores empty tokens.
  Future<void> logout(String refreshToken) async {
    if (refreshToken.isEmpty) return;
    await _dio.post<void>(
      '/auth/logout',
      data: <String, String>{'refresh_token': refreshToken},
    );
  }

  OtpRequestResult _otpFrom(Response<Map<String, dynamic>> response) {
    final data = unwrapData<Map<String, dynamic>?>(response);
    final otp = data?['dev_otp'];
    return OtpRequestResult(devOtp: otp is String ? otp : null);
  }
}
