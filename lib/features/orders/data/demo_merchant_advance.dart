import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/network/api_envelope.dart';
import 'package:dio/dio.dart';

/// Demo-only helper: signs in as the Fateh Jang merchant that owns the order,
/// advances it to `ready_for_pickup`, then asks the API to dispatch a rider.
///
/// Does **not** touch the customer's stored session tokens.
class DemoMerchantAdvance {
  /// Creates the helper.
  const new();

  /// Seeded Fateh Jang merchant phones (`03003333001`–`008`).
  static const merchantPhones = <String>[
    '03003333001',
    '03003333002',
    '03003333003',
    '03003333004',
    '03003333005',
    '03003333006',
    '03003333007',
    '03003333008',
  ];

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
      final owner = await _loginOwningMerchant(dio, orderId);
      if (owner == null) {
        return 'No seeded merchant owns this order '
            '(tried Fateh Jang phones 03003333001–008). '
            'Order from a Fateh Jang kitchen, then retry.';
      }
      dio.options.headers['Authorization'] = 'Bearer $owner';

      for (final action in ['preparing', 'ready']) {
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

  /// Logs in each seeded merchant until `accept` succeeds for [orderId].
  Future<String?> _loginOwningMerchant(Dio dio, String orderId) async {
    for (final phone in merchantPhones) {
      final token = await _merchantToken(dio, phone);
      if (token == null) continue;
      dio.options.headers['Authorization'] = 'Bearer $token';
      try {
        await dio.post<Map<String, dynamic>>(
          '/merchants/orders/$orderId/accept',
        );
        return token;
      } on DioException catch (error) {
        final code = readApiError(error)?.code;
        final message = readApiError(error)?.message ?? '';
        // Wrong kitchen for this order — try the next seeded phone.
        if (code == 'forbidden' ||
            message.contains('does not own') ||
            message.contains('not a party')) {
          continue;
        }
        // Already accepted by this merchant — still the owner.
        if (code == 'conflict' || message.contains('already')) {
          return token;
        }
        rethrow;
      }
    }
    return null;
  }

  Future<String?> _merchantToken(Dio dio, String phone) async {
    final otpRes = await dio.post<Map<String, dynamic>>(
      '/auth/otp/request',
      data: {'phone': phone, 'role': 'merchant'},
    );
    final otpData = unwrapData<Map<String, dynamic>>(otpRes);
    final otp = otpData['dev_otp'];
    if (otp is! String || otp.isEmpty) return null;
    final verify = await dio.post<Map<String, dynamic>>(
      '/auth/otp/verify',
      data: {'phone': phone, 'role': 'merchant', 'otp': otp},
    );
    final session = unwrapData<Map<String, dynamic>>(verify);
    final token = session['access_token'];
    return token is String ? token : null;
  }
}
