import 'dart:developer' as developer;

import 'package:attock_xpress/core/utils/pii_redactor.dart';
import 'package:dio/dio.dart';

/// Logs the method and path only. Bodies, tokens, and PII are omitted.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      PiiRedactor.redact('${options.method} ${options.uri.path}'),
      name: 'ghartak.http',
    );
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      PiiRedactor.redact('${err.requestOptions.uri.path} failed'),
      name: 'ghartak.http',
    );
    handler.next(err);
  }
}
