import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/repositories/auth_repository.dart';
import 'package:attock_xpress/features/auth/domain/usecases/request_otp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository;

void main() {
  setUpAll(() {
    registerFallbackValue(const CustomerRole());
  });

  test('rejects a number that is not a Pakistani mobile', () async {
    final repository = _MockAuthRepository();
    final useCase = RequestOtp(repository);

    final result = await useCase.call(
      phone: '123',
      role: const CustomerRole(),
    );

    expect(result, isA<Err<OtpRequestResult>>());
    final failure = (result as Err<OtpRequestResult>).failure;
    expect(failure, isA<ValidationFailure>());
    verifyNever(
      () => repository.requestOtp(phone: any(named: 'phone'), role: any(named: 'role')),
    );
  });

  test('requests an OTP for a valid mobile number', () async {
    final repository = _MockAuthRepository();
    when(
      () => repository.requestOtp(
        phone: any(named: 'phone'),
        role: any(named: 'role'),
      ),
    ).thenAnswer((_) async => const Success(OtpRequestResult(devOtp: '123456')));
    final useCase = RequestOtp(repository);

    final result = await useCase.call(
      phone: '03001234567',
      role: const CustomerRole(),
    );

    expect(result, isA<Success<OtpRequestResult>>());
    verify(
      () => repository.requestOtp(
        phone: '03001234567',
        role: const CustomerRole(),
      ),
    ).called(1);
  });
}
