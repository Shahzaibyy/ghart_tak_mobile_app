import 'package:attock_xpress/app/customer_shell.dart';
import 'package:attock_xpress/core/theme/app_theme.dart';
import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_controller.dart';
import 'package:attock_xpress/features/auth/presentation/screens/phone_login_screen.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/screens/rider_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget. Session state chooses the customer or rider home.
class GharTakApp extends ConsumerWidget {
  /// Creates the app.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider);
    return MaterialApp(
      title: 'GharTak',
      theme: AppTheme.light,
      home: AsyncValueView<AuthSession?>(
        value: session,
        onRetry: () => ref.invalidate(authControllerProvider),
        data: (value) => _SignedInHome(session: value),
      ),
    );
  }
}

class _SignedInHome extends StatelessWidget {
  const new({required this.session});

  final AuthSession? session;

  @override
  Widget build(BuildContext context) {
    final current = session;
    if (current == null) return const PhoneLoginScreen();
    return switch (current.user.role) {
      CustomerRole() => const CustomerShell(),
      RiderRole() => const RiderDashboardScreen(),
    };
  }
}
