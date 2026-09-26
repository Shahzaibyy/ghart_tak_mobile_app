import 'package:attock_xpress/core/errors/failure.dart';
import 'package:dio/dio.dart';

const Set<DioExceptionType> _offlineTypes = {
  DioExceptionType.connectionTimeout,
  DioExceptionType.sendTimeout,
  DioExceptionType.receiveTimeout,
  DioExceptionType.connectionError,
};

const Set<int> _authStatuses = {401, 403};
const Set<int> _validationStatuses = {400, 422};

/// Maps a [DioException] to a [Failure] once, at the repository boundary.
Failure mapDioException(DioException error) {
  if (_offlineTypes.contains(error.type)) return const NetworkFailure();
  if (error.type != DioExceptionType.badResponse) {
    return const NetworkFailure();
  }
  return failureForStatus(error.response?.statusCode);
}

/// Maps an HTTP status code to a [Failure].
Failure failureForStatus(int? code) {
  if (_authStatuses.contains(code)) return const AuthFailure();
  if (_validationStatuses.contains(code)) return const ValidationFailure();
  return const ServerFailure();
}
