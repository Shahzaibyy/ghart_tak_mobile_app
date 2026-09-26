import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_controller.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_flow.g.dart';

/// Which login step is on screen.
sealed class AuthStep {
  const new();
}

/// Phone number entry.
final class EnterPhone extends AuthStep {
  /// Creates the phone step.
  const new();
}

/// OTP entry for [phone].
final class EnterOtp extends AuthStep {
  /// Creates the OTP step.
  const new(this.phone);

  /// Number the code was sent to. Not written to logs.
  final String phone;
}

/// Login steps modeled as async state.
@riverpod
class AuthFlow extends _$AuthFlow {
  @override
  Future<AuthStep> build() async => const EnterPhone();

  /// Validates [phone] and advances to the OTP step on success.
  Future<void> requestOtp(String phone) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(requestOtpProvider).call(phone);
      return switch (result) {
        Success() => EnterOtp(phone),
        Err(:final failure) => throw failure,
      };
    });
  }

  /// Verifies [otp] and publishes the session.
  Future<void> verify(String otp) async {
    final step = state.value;
    if (step is! EnterOtp) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(verifyOtpProvider).call(
        phone: step.phone,
        otp: otp,
      );
      return switch (result) {
        Success(:final value) => _adopt(value, step),
        Err(:final failure) => throw failure,
      };
    });
  }

  AuthStep _adopt(AuthSession session, EnterOtp step) {
    ref.read(authControllerProvider.notifier).adopt(session);
    return step;
  }
}
