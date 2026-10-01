import 'package:attock_xpress/app.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_user.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';
import 'package:attock_xpress/features/auth/domain/repositories/auth_repository.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository;

void main() {
  testWidgets('shows welcome when signed out', (tester) async {
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Bhook Lagi'), findsWidgets);
    expect(find.text('Skip to customer home'), findsOneWidget);
    expect(find.text('Skip to rider home'), findsOneWidget);
  });

  testWidgets('skip to customer home opens the feed', (tester) async {
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Skip to customer home'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Featured merchants'), findsOneWidget);
    expect(find.text('Tandoor House'), findsWidgets);
  });

  testWidgets('skip to rider home requests a rider preview', (tester) async {
    final repository = _MockAuthRepository();
    when(repository.currentSession).thenAnswer(
      (_) async => const Success<AuthSession?>(null),
    );
    when(() => repository.enterPreview(const RiderRole())).thenAnswer(
      (_) async => const Success(
        AuthSession(
          user: AppUser(
            id: 'preview-rider',
            role: RiderRole(),
            name: 'Hamza',
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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Skip to rider home'));
    await tester.pump();

    verify(() => repository.enterPreview(const RiderRole())).called(1);
  });
}
