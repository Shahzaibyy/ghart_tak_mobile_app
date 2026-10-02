import 'dart:async';

import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/config/demo_config.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/core/widgets/brand_logo.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_controller.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_flow.dart';
import 'package:attock_xpress/features/auth/presentation/screens/otp_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Phone OTP + Fateh Jang seeded demo login.
class PhoneLoginScreen extends ConsumerStatefulWidget {
  /// Creates the login screen.
  const new({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  var _seededPhone = false;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(authFlowProvider);
    return Scaffold(
      body: SafeArea(
        child: AsyncValueView<AuthStep>(
          value: flow,
          onRetry: () => ref.invalidate(authFlowProvider),
          data: (step) {
            if (step is EnterPhone && !_seededPhone && AppConfig.isDemo) {
              _seededPhone = true;
              final seed = step.role is RiderRole
                  ? DemoConfig.demoRiderPhone
                  : DemoConfig.demoCustomerPhone;
              _phone.text = seed;
            }
            if (step is EnterOtp &&
                step.devOtp != null &&
                _otp.text.isEmpty) {
              _otp.text = step.devOtp!;
            }
            return switch (step) {
              EnterPhone(:final role) => _PhoneForm(
                  controller: _phone,
                  role: role,
                  onRoleChanged: (next) {
                    ref.read(authFlowProvider.notifier).setRole(next);
                    _phone.text = next is RiderRole
                        ? DemoConfig.demoRiderPhone
                        : DemoConfig.demoCustomerPhone;
                  },
                  onSubmit: () => unawaited(
                    ref.read(authFlowProvider.notifier).requestOtp(
                          _phone.text.trim(),
                          role: role,
                        ),
                  ),
                  onDemoAccount: (account) => unawaited(
                    ref.read(authFlowProvider.notifier).demoLogin(account),
                  ),
                  onPreviewCustomer: () => unawaited(
                    ref
                        .read(authControllerProvider.notifier)
                        .preview(const CustomerRole()),
                  ),
                  onPreviewRider: () => unawaited(
                    ref
                        .read(authControllerProvider.notifier)
                        .preview(const RiderRole()),
                  ),
                ),
              EnterOtp(:final devOtp) => OtpForm(
                  controller: _otp,
                  onSubmit: () => unawaited(
                    ref
                        .read(authFlowProvider.notifier)
                        .verify(_otp.text.trim()),
                  ),
                  hint: devOtp == null
                      ? null
                      : 'Dev OTP filled automatically ($devOtp)',
                ),
            };
          },
        ),
      ),
    );
  }
}

class _PhoneForm extends StatelessWidget {
  const new({
    required this.controller,
    required this.role,
    required this.onRoleChanged,
    required this.onSubmit,
    required this.onDemoAccount,
    required this.onPreviewCustomer,
    required this.onPreviewRider,
  });

  final TextEditingController controller;
  final AppRole role;
  final ValueChanged<AppRole> onRoleChanged;
  final VoidCallback onSubmit;
  final ValueChanged<DemoAccount> onDemoAccount;
  final VoidCallback onPreviewCustomer;
  final VoidCallback onPreviewRider;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall;
    final accounts = DemoConfig.accountsFor(role);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: BrandLogo(),
        ),
        const SizedBox(height: 24),
        Text(
          'Sign in',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          AppConfig.isDemo
              ? 'Fateh Jang demo — tap a seeded account (no SMS).'
              : 'Enter your mobile number to continue.',
          style: muted,
        ),
        const SizedBox(height: 20),
        SegmentedButton<AppRole>(
          segments: const [
            ButtonSegment(
              value: CustomerRole(),
              label: Text('Customer'),
              icon: Icon(Icons.shopping_bag_outlined, size: 18),
            ),
            ButtonSegment(
              value: RiderRole(),
              label: Text('Rider'),
              icon: Icon(Icons.two_wheeler, size: 18),
            ),
          ],
          selected: {role},
          onSelectionChanged: (next) {
            if (next.isEmpty) return;
            onRoleChanged(next.first);
          },
        ),
        if (AppConfig.isDemo) ...[
          const SizedBox(height: 20),
          Text(
            role is RiderRole
                ? 'Seeded riders (approved + online)'
                : 'Seeded customers',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final account in accounts)
                ActionChip(
                  avatar: CircleAvatar(
                    backgroundColor: AppColors.tint,
                    child: Text(
                      account.name.isEmpty
                          ? '?'
                          : account.name.substring(0, 1),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  label: Text(
                    '${account.name.split(' ').first} · ${account.phone}',
                  ),
                  onPressed: () => onDemoAccount(account),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'One tap signs in via API (dev_otp). Zone Fateh Jang.',
            style: muted?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text('Or enter any phone', style: muted),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Mobile number',
            hintText: '03XXXXXXXXX',
          ),
        ),
        const SizedBox(height: 16),
        GhButton(label: 'Send code', onPressed: onSubmit),
        const SizedBox(height: 28),
        Text('Look around first (offline preview)', style: muted),
        const SizedBox(height: 12),
        GhButton(
          label: 'Preview as customer',
          secondary: true,
          onPressed: onPreviewCustomer,
        ),
        const SizedBox(height: 8),
        GhButton(
          label: 'Preview as rider',
          secondary: true,
          onPressed: onPreviewRider,
        ),
      ],
    );
  }
}
