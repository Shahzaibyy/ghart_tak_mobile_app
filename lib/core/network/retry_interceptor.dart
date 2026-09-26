import 'dart:async';

import 'package:dio/dio.dart';

/// Retries connection failures with backoff.
///
/// A request that reached the server is not retried here. Auth refresh
/// handles 401 separately.
class RetryInterceptor extends Interceptor {
  /// Creates an interceptor that replays requests through the client.
  new(this._dio, {this.maxAttempts = 2});

  final Dio _dio;

  /// How many times a dropped connection may be replayed.
  final int maxAttempts;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    unawaited(_retry(err, handler));
  }

  Future<void> _retry(DioException err, ErrorInterceptorHandler handler) async {
    if (!_offlineTypes.contains(err.type)) {
      handler.next(err);
      return;
    }
    final attempt = _attemptOf(err.requestOptions);
    if (attempt >= maxAttempts) {
      handler.next(err);
      return;
    }
    await Future<void>.delayed(Duration(milliseconds: 200 * (attempt + 1)));
    err.requestOptions.extra['attempt'] = attempt + 1;
    try {
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (error) {
      handler.next(error);
    }
  }

  int _attemptOf(RequestOptions options) {
    final raw = options.extra['attempt'];
    if (raw is int) return raw;
    return 0;
  }
}

const Set<DioExceptionType> _offlineTypes = {
  DioExceptionType.connectionTimeout,
  DioExceptionType.connectionError,
};
