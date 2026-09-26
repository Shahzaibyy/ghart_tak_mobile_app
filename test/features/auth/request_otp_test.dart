import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/domain/repositories/auth_repository.dart';
import 'package:attock_xpress/features/auth/domain/usecases/request_otp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository;

void main() {
  test('rejects a number that is not a Pakistani mobile', () async {
    final repository = _MockAuthRepository();
    final useCase = RequestOtp(repository);

    final result = await useCase.call('123');

    expect(result, isA<Err<Nothing>>());
    final failure = (result as Err<Nothing>).failure;
    expect(failure, isA<ValidationFailure>());
    verifyNever(() => repository.requestOtp(any()));
  });

  test('requests an OTP for a valid mobile number', () async {
    final repository = _MockAuthRepository();
    when(() => repository.requestOtp(any())).thenAnswer(
      (_) async => const Success(nothing),
    );
    final useCase = RequestOtp(repository);

    final result = await useCase.call('03001234567');

    expect(result, isA<Success<Nothing>>());
    verify(() => repository.requestOtp('03001234567')).called(1);
  });
}
