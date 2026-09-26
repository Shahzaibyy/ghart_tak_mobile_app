import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/domain/repositories/auth_repository.dart';

/// Ends the current session.
class Logout {
  /// Creates a use case over the repository.
  const new(this._repository);

  final AuthRepository _repository;

  /// Clears stored credentials.
  Future<Result<Nothing>> call() => _repository.logout();
}
