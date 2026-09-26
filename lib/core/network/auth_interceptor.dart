import 'dart:async';

import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/storage/token_keys.dart';
import 'package:attock_xpress/core/storage/token_store.dart';
import 'package:dio/dio.dart';

/// Attaches the JWT and retries a request once after a silent refresh.
class AuthInterceptor extends Interceptor {
  /// Creates an interceptor that reads tokens from [_store].
  new({
    required this._store,
    required this._dio,
    Dio? refreshClient,
  }) : _refreshClient =
           refreshClient ??
           Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

  final TokenStore _store;
  final Dio _dio;
  final Dio _refreshClient;
  Future<bool>? _refreshing;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    unawaited(_attach(options, handler));
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    unawaited(_refreshAndRetry(err, handler));
  }

  Future<void> _attach(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _store.read(TokenKeys.access);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _refreshAndRetry(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra['refreshed'] == true;
    if (status != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }
    final refreshed = await _refresh();
    if (!refreshed) {
      handler.next(err);
      return;
    }
    err.requestOptions.extra['refreshed'] = true;
    final token = await _store.read(TokenKeys.access);
    if (token != null) {
      err.requestOptions.headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (error) {
      handler.next(error);
    }
  }

  Future<bool> _refresh() {
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight;
    final future = _requestRefresh();
    _refreshing = future;
    return future.whenComplete(() => _refreshing = null);
  }

  Future<bool> _requestRefresh() async {
    final refresh = await _store.read(TokenKeys.refresh);
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final response = await _refreshClient.post<Map<String, dynamic>>(
        '/auth/token/refresh',
        data: <String, String>{'refresh_token': refresh},
      );
      return await _storeRotatedTokens(response.data);
    } on DioException {
      return false;
    }
  }

  Future<bool> _storeRotatedTokens(Object? data) async {
    if (data is! Map) return false;
    final json = Map<String, dynamic>.from(data);
    final access = json['jwt'];
    final refresh = json['refresh_token'];
    if (access is! String || refresh is! String) return false;
    await _store.write(key: TokenKeys.access, value: access);
    await _store.write(key: TokenKeys.refresh, value: refresh);
    return true;
  }
}
