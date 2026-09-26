import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// Signed-in session. Null means the user is logged out.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<AuthSession?> build() async {
    final result = await ref.watch(authRepositoryProvider).currentSession();
    return switch (result) {
      Success(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  /// Adopts a session that was just verified.
  void adopt(AuthSession session) {
    state = AsyncData(session);
  }

  /// Clears the session and returns to the login flow.
  Future<void> logout() async {
    final result = await ref.read(logoutProvider).call();
    if (result case Err(:final failure)) {
      state = AsyncError(failure, StackTrace.current);
      return;
    }
    state = const AsyncData(null);
  }
}
