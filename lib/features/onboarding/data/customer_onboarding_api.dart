import 'package:attock_xpress/core/config/demo_config.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/api_envelope.dart';
import 'package:attock_xpress/core/network/dio_exception_mapper.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:dio/dio.dart';

/// Address label for `POST /customers/onboarding`.
enum AddressLabel {
  home,
  work,
  other,
}

String addressLabelWire(AddressLabel label) {
  return switch (label) {
    AddressLabel.home => 'home',
    AddressLabel.work => 'work',
    AddressLabel.other => 'other',
  };
}

AddressLabel addressLabelFromUi(String raw) {
  return switch (raw.toLowerCase()) {
    'work' => AddressLabel.work,
    'other' => AddressLabel.other,
    _ => AddressLabel.home,
  };
}

/// Customer onboarding HTTP (`/customers/*`).
class CustomerOnboardingApi {
  /// Creates the API client.
  const new(this._dio);

  final Dio _dio;

  /// Saves name + first delivery address.
  Future<Result<Nothing>> completeOnboarding({
    required String name,
    required AddressLabel label,
    required String addressText,
    GeoPoint? point,
  }) async {
    try {
      await _dio.post<void>(
        '/customers/onboarding',
        data: <String, Object?>{
          'name': name.trim(),
          'address': {
            'label': addressLabelWire(label),
            'lat': point?.lat ?? DemoConfig.demoDropLat,
            'lng': point?.lng ?? DemoConfig.demoDropLng,
            'address_text': addressText.trim().isEmpty
                ? DemoConfig.demoDropAddress
                : addressText.trim(),
          },
        },
      );
      return const Success(nothing);
    } on DioException catch (error) {
      if (_notReady(error)) return const Success(nothing);
      return Err(mapDioException(error));
    }
  }

  /// Soft-saves category preferences after the intent screen.
  Future<Result<Nothing>> savePreferences(List<String> orderTypes) async {
    try {
      await _dio.patch<void>(
        '/customers/me/preferences',
        data: <String, Object?>{
          'preferred_order_types': orderTypes,
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
