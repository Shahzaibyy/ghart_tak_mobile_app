import 'dart:async';

import 'package:attock_xpress/app/customer_shell.dart';
import 'package:attock_xpress/app/rider_shell.dart';
import 'package:attock_xpress/core/theme/app_theme.dart';
import 'package:attock_xpress/core/theme/theme_controller.dart';
import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_controller.dart';
import 'package:attock_xpress/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget. Session state chooses the customer or rider home.
class BhookLagiApp extends ConsumerWidget {
  /// Creates the app.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider);
    final mode = ref.watch(themeControllerProvider);
    return MaterialApp(
      title: 'Bhook Lagi',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      debugShowCheckedModeBanner: false,
      home: AsyncValueView<AuthSession?>(
        value: session,
        onRetry: () => ref.invalidate(authControllerProvider),
        data: (value) => _SignedInHome(
          session: value,
          onLogout: () {
            unawaited(ref.read(authControllerProvider.notifier).logout());
          },
        ),
      ),
    );
  }
}

class _SignedInHome extends StatelessWidget {
  const new({required this.session, required this.onLogout});

  final AuthSession? session;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final current = session;
    if (current == null) return const OnboardingScreen();
    final name = current.user.name ?? 'Bhook Lagi';
    return switch (current.user.role) {
      CustomerRole() => CustomerShell(displayName: name),
      RiderRole() => RiderShell(displayName: name, onLogout: onLogout),
    };
  }
}
