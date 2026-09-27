import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';
import 'package:attock_xpress/features/auth/domain/repositories/auth_repository.dart';

/// Starts a local preview without writing tokens.
class EnterPreview {
  /// Creates a use case over the auth repository.
  const new(this._repository);

  final AuthRepository _repository;

  /// Enters as [role].
  Future<Result<AuthSession>> call(AppRole role) {
    return _repository.enterPreview(role);
  }
}
