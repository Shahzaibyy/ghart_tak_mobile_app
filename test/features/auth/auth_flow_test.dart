import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/repositories/auth_repository.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_flow.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository;

void main() {
  setUpAll(() {
    registerFallbackValue(const CustomerRole());
  });

  test('requestOtp moves to the code step', () async {
    final repository = _MockAuthRepository();
    when(
      () => repository.requestOtp(
        phone: any(named: 'phone'),
        role: any(named: 'role'),
      ),
    ).thenAnswer((_) async => const Success(OtpRequestResult(devOtp: '482913')));
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(authFlowProvider.notifier).requestOtp('03001234567');

    final step = container.read(authFlowProvider).requireValue;
    expect(step, isA<EnterOtp>());
    expect((step as EnterOtp).phone, '03001234567');
    expect(step.devOtp, '482913');
  });
}
