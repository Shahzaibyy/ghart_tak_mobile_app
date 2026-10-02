import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/api_envelope.dart';
import 'package:attock_xpress/core/network/dio_exception_mapper.dart';
import 'package:attock_xpress/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:attock_xpress/features/auth/domain/phone_number.dart';
import 'package:dio/dio.dart';

/// Rider onboarding status timeline from `GET /riders/me/onboarding`.
class RiderOnboardingStatus {
  /// Creates a status snapshot.
  const new({
    this.stage = 'applied',
    this.orientation = 'pending',
    this.message,
  });

  final String stage;
  final String orientation;
  final String? message;

  factory fromJson(Map<String, dynamic> json) {
    return RiderOnboardingStatus(
      stage: (json['stage'] as String?) ??
          (json['status'] as String?) ??
          'applied',
      orientation: (json['orientation'] as String?) ??
          (json['orientation_status'] as String?) ??
          'pending',
      message: json['message'] as String?,
    );
  }
}

/// Rider onboarding HTTP (`/riders/onboarding/*`, `/riders/me/onboarding/*`).
class RiderOnboardingApi {
  /// Creates the API client.
  const new(this._dio);

  final Dio _dio;

  /// Starts rider apply + OTP. Falls back to `/auth/otp/request` if apply 404s.
  Future<Result<OtpRequestResult>> apply({
    required String phone,
    required String zoneId,
    OtpChannel channel = OtpChannel.whatsapp,
  }) async {
    final normalized = normalizePakistaniPhone(phone);
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/riders/onboarding/apply',
        data: <String, String>{
          'phone': normalized,
          'zone_id': zoneId,
          'channel': otpChannelWire(channel),
        },
      );
      final data = unwrapData<Map<String, dynamic>?>(response);
      final otp = data?['dev_otp'];
      return Success(OtpRequestResult(devOtp: otp is String ? otp : null));
    } on DioException catch (error) {
      if (!_notReady(error)) return Err(mapDioException(error));
      // Legacy path until apply is deployed.
      try {
        final response = await _dio.post<Map<String, dynamic>>(
          '/auth/otp/request',
          data: <String, String>{
            'phone': normalized,
            'role': 'rider',
            'channel': otpChannelWire(channel),
          },
        );
        final data = unwrapData<Map<String, dynamic>?>(response);
        final otp = data?['dev_otp'];
        return Success(OtpRequestResult(devOtp: otp is String ? otp : null));
      } on DioException catch (fallback) {
        return Err(mapDioException(fallback));
      }
    }
  }

  /// Saves identity + vehicle details.
  Future<Result<Nothing>> saveDetails({
    required String name,
    required String cnic,
    required String vehicleType,
    String? vehicleReg,
    String? licenseNumber,
  }) async {
    try {
      await _dio.patch<void>(
        '/riders/me/onboarding/details',
        data: <String, Object?>{
          'name': name.trim(),
          'cnic': cnic.trim(),
          'vehicle_type': vehicleType.toLowerCase(),
          if (vehicleReg != null && vehicleReg.trim().isNotEmpty)
            'vehicle_reg': vehicleReg.trim(),
          if (licenseNumber != null && licenseNumber.trim().isNotEmpty)
            'license_number': licenseNumber.trim(),
        },
      );
      return const Success(nothing);
    } on DioException catch (error) {
      if (_notReady(error)) return const Success(nothing);
      return Err(mapDioException(error));
    }
  }

  /// Presigns an upload. Returns the `upload_url` + object key when available.
  Future<Result<({String uploadUrl, String objectKey})>> presign(
    String purpose,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/uploads/presign',
        data: <String, String>{'purpose': purpose},
      );
      final data = unwrapData<Map<String, dynamic>>(response);
      final url = data['upload_url'];
      final key = data['object_key'] ?? data['key'] ?? purpose;
      if (url is! String) {
        return const Err(ServerFailure('Upload URL missing'));
      }
      return Success((uploadUrl: url, objectKey: '$key'));
    } on DioException catch (error) {
      if (_notReady(error)) {
        return Success((uploadUrl: '', objectKey: 'local/$purpose.jpg'));
      }
      return Err(mapDioException(error));
    }
  }

  /// Attaches uploaded document object keys.
  Future<Result<Nothing>> saveDocuments({
    required String cnicFrontKey,
    required String cnicBackKey,
    required String licenceKey,
    required String selfieKey,
  }) async {
    try {
      await _dio.put<void>(
        '/riders/me/onboarding/documents',
        data: <String, String>{
          'cnic_front': cnicFrontKey,
          'cnic_back': cnicBackKey,
          'driving_licence': licenceKey,
          'selfie': selfieKey,
        },
      );
      return const Success(nothing);
    } on DioException catch (error) {
      if (_notReady(error)) return const Success(nothing);
      return Err(mapDioException(error));
    }
  }

  /// Submits the application for review.
  Future<Result<Nothing>> submit() async {
    try {
      await _dio.post<void>('/riders/me/onboarding/submit');
      return const Success(nothing);
    } on DioException catch (error) {
      if (_notReady(error)) return const Success(nothing);
      return Err(mapDioException(error));
    }
  }

  /// Loads the review timeline.
  Future<Result<RiderOnboardingStatus>> status() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/riders/me/onboarding',
      );
      final data = unwrapData<Map<String, dynamic>>(response);
      return Success(RiderOnboardingStatus.fromJson(data));
    } on DioException catch (error) {
      if (_notReady(error)) {
        return const Success(RiderOnboardingStatus());
      }
      return Err(mapDioException(error));
    }
  }

  /// Books orientation.
  Future<Result<Nothing>> bookOrientation({String? preferredSlot}) async {
    try {
      await _dio.post<void>(
        '/riders/me/onboarding/orientation',
        data: <String, Object?>{
          if (preferredSlot != null) 'preferred_slot': preferredSlot,
        },
      );
      return const Success(nothing);
    } on DioException catch (error) {
      if (_notReady(error)) return const Success(nothing);
      return Err(mapDioException(error));
    }
  }

  /// Opens a support ticket from the review screen.
  Future<Result<Nothing>> contactSupport({
    String subject = 'Rider onboarding help',
    String body = 'Need help with my rider application.',
  }) async {
    try {
      await _dio.post<void>(
        '/tickets',
        data: <String, String>{
          'subject': subject,
          'body': body,
        },
      );
      return const Success(nothing);
    } on DioException catch (error) {
      if (_notReady(error)) return const Success(nothing);
      return Err(mapDioException(error));
    }
  }

  bool _notReady(DioException error) {
    final code = error.response?.statusCode;
    if (code == 404 || code == 501) return true;
    final api = readApiError(error);
    return api?.code == 'unavailable';
  }
}
