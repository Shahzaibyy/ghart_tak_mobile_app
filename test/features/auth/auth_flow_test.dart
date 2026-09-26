import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/domain/repositories/auth_repository.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_flow.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository;

void main() {
  test('requestOtp moves to the code step', () async {
    final repository = _MockAuthRepository();
    when(() => repository.requestOtp(any())).thenAnswer(
      (_) async => const Success(nothing),
    );
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(authFlowProvider.notifier).requestOtp('03001234567');

    final step = container.read(authFlowProvider).requireValue;
    expect(step, isA<EnterOtp>());
    expect((step as EnterOtp).phone, '03001234567');
  });
}
