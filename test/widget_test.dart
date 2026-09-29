import 'package:attock_xpress/app.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_user.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';
import 'package:attock_xpress/features/auth/domain/repositories/auth_repository.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository;

void main() {
  testWidgets('shows phone login when signed out', (tester) async {
    final repository = _MockAuthRepository();
    when(repository.currentSession).thenAnswer(
      (_) async => const Success<AuthSession?>(null),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
        ],
        child: const BhookLagiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Bhook Lagi'), findsOneWidget);
    expect(find.text('Send code'), findsOneWidget);
  });

  testWidgets('shows a validation failure for a bad phone number', (
    tester,
  ) async {
    final repository = _MockAuthRepository();
    when(repository.currentSession).thenAnswer(
      (_) async => const Success<AuthSession?>(null),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
        ],
        child: const BhookLagiApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '123');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();

    expect(find.text('Check your details'), findsOneWidget);
    verifyNever(() => repository.requestOtp(any()));
  });

  testWidgets('preview as customer opens the home feed', (tester) async {
    final repository = _MockAuthRepository();
    when(repository.currentSession).thenAnswer(
      (_) async => const Success<AuthSession?>(null),
    );
    when(() => repository.enterPreview(const CustomerRole())).thenAnswer(
      (_) async => const Success(
        AuthSession(
          user: AppUser(
            id: 'preview-customer',
            role: CustomerRole(),
            name: 'Ayesha',
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
        ],
        child: const BhookLagiApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preview as customer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Featured merchants'), findsOneWidget);
    expect(find.text('Tandoor House'), findsWidgets);
  });
}
