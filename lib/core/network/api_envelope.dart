import 'package:attock_xpress/core/errors/failure.dart';
import 'package:dio/dio.dart';

/// Unwraps `{ "data": ... }` success envelopes from the GharTak API.
T unwrapData<T>(Response<dynamic> response) {
  final body = response.data;
  if (body is Map && body.containsKey('data')) {
    return body['data'] as T;
  }
  if (body is T) return body;
  throw const FormatException('Expected a data envelope');
}

/// Reads `{ "error": { "code", "message" } }` from a Dio error response.
ApiError? readApiError(DioException error) {
  final data = error.response?.data;
  if (data is! Map) return null;
  final err = data['error'];
  if (err is! Map) return null;
  final code = err['code'];
  final message = err['message'];
  if (code is! String) return null;
  return ApiError(
    code: code,
    message: message is String ? message : code,
  );
}

/// Structured API error from the backend envelope.
class ApiError {
  /// Creates an API error.
  const new({required this.code, required this.message});

  /// Machine code (`unauthorized`, `phone_required`, …).
  final String code;

  /// Human-readable message from the server.
  final String message;
}

/// Maps known API error codes onto typed [Failure]s.
Failure failureFromApiError(ApiError error) {
  return switch (error.code) {
    'unauthorized' || 'forbidden' => AuthFailure(error.message),
    'invalid_input' || 'validation_error' || 'conflict' =>
      ValidationFailure(error.message),
    'rate_limited' => ValidationFailure(error.message),
    'phone_required' => const ValidationFailure(
      'Verify your phone number before placing an order',
    ),
    'unavailable' => ServerFailure(error.message),
    _ => ServerFailure(error.message),
  };
}
