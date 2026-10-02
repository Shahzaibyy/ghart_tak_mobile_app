import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/network/api_envelope.dart';
import 'package:dio/dio.dart';

/// Demo-only helper: signs in as Bismillah (`03003333001`) and advances an
/// order to `ready_for_pickup`, then asks the API to dispatch a rider offer.
///
/// Does **not** touch the customer's stored session tokens.
class DemoMerchantAdvance {
  /// Creates the helper.
  const new();

  /// Fateh Jang Bismillah merchant phone (seed guide).
  static const merchantPhone = '03003333001';

  /// Runs accept → preparing → ready → dispatch for [orderId].
  ///
  /// Returns `null` on full success, otherwise a short error / warning.
  Future<String?> advanceToReady(String orderId) async {
    if (!AppConfig.isDemo) {
      return 'Merchant advance is only available in demo builds.';
    }
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        headers: const {'Content-Type': 'application/json'},
      ),
    );
    try {
      final otpRes = await dio.post<Map<String, dynamic>>(
        '/auth/otp/request',
        data: {'phone': merchantPhone, 'role': 'merchant'},
      );
      final otpData = unwrapData<Map<String, dynamic>>(otpRes);
      final otp = otpData['dev_otp'];
      if (otp is! String || otp.isEmpty) {
        return 'Merchant dev_otp missing — API must be APP_ENV=development.';
      }
      final verify = await dio.post<Map<String, dynamic>>(
        '/auth/otp/verify',
        data: {
          'phone': merchantPhone,
          'role': 'merchant',
          'otp': otp,
        },
      );
      final session = unwrapData<Map<String, dynamic>>(verify);
      final token = session['access_token'];
      if (token is! String) return 'Merchant login failed.';
      dio.options.headers['Authorization'] = 'Bearer $token';

      for (final action in ['accept', 'preparing', 'ready']) {
        await dio.post<Map<String, dynamic>>(
          '/merchants/orders/$orderId/$action',
        );
      }

      try {
        await dio.post<Map<String, dynamic>>('/orders/$orderId/dispatch');
      } on DioException catch (error) {
        final api = readApiError(error);
        return 'Kitchen is ready, but dispatch failed'
            ' (${api?.message ?? error.message}). '
            'Rider offers stay empty until POST /orders/{id}/dispatch works.';
      }
      return null;
    } on DioException catch (error) {
      final api = readApiError(error);
      return api?.message ?? error.message ?? 'Merchant advance failed';
    } on FormatException catch (error) {
      return error.message;
    }
  }
}
