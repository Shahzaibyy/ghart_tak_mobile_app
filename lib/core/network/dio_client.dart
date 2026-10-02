import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/network/auth_interceptor.dart';
import 'package:attock_xpress/core/network/logging_interceptor.dart';
import 'package:attock_xpress/core/network/retry_interceptor.dart';
import 'package:attock_xpress/core/storage/token_store.dart';
import 'package:dio/dio.dart';

/// Builds the single Dio client used by feature data sources.
Dio buildDio({required TokenStore tokenStore}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  dio.interceptors.addAll([
    LoggingInterceptor(),
    AuthInterceptor(store: tokenStore, dio: dio),
    RetryInterceptor(dio),
  ]);
  return dio;
}
