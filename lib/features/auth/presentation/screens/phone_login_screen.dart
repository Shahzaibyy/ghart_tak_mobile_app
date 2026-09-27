import 'dart:async';

import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_controller.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_flow.dart';
import 'package:attock_xpress/features/auth/presentation/screens/otp_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Phone OTP entry. The visible step comes from [AuthFlow].
class PhoneLoginScreen extends ConsumerStatefulWidget {
  /// Creates the login screen.
  const new({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();

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
          data: (step) => switch (step) {
            EnterPhone() => _PhoneForm(
              controller: _phone,
              onSubmit: () => unawaited(_requestOtp()),
              onPreviewCustomer: () => unawaited(
                _preview(const CustomerRole()),
              ),
              onPreviewRider: () => unawaited(
                _preview(const RiderRole()),
              ),
            ),
            EnterOtp() => OtpForm(
              controller: _otp,
              onSubmit: () => unawaited(_verify()),
            ),
          },
        ),
      ),
    );
  }

  Future<void> _requestOtp() {
    return ref.read(authFlowProvider.notifier).requestOtp(_phone.text.trim());
  }

  Future<void> _verify() {
    return ref.read(authFlowProvider.notifier).verify(_otp.text.trim());
  }

  Future<void> _preview(AppRole role) {
    return ref.read(authControllerProvider.notifier).preview(role);
  }
}

class _PhoneForm extends StatelessWidget {
  const new({
    required this.controller,
    required this.onSubmit,
    required this.onPreviewCustomer,
    required this.onPreviewRider,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onPreviewCustomer;
  final VoidCallback onPreviewRider;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      children: [
        Text('GharTak', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 8),
        Text('Har cheez, ghar tak.', style: muted),
        const SizedBox(height: 32),
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
        Text('Look around first', style: muted),
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
        const SizedBox(height: 16),
        Text(
          'Preview stays on this phone. No code is sent.',
          style: muted?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}
