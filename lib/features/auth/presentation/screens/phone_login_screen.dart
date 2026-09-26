import 'dart:async';

import 'package:attock_xpress/core/widgets/async_value_view.dart';
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
}

class _PhoneForm extends StatelessWidget {
  const new({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('GharTak', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('Har cheez, ghar tak.'),
        const SizedBox(height: 24),
        TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Mobile number',
            hintText: '03XXXXXXXXX',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: onSubmit, child: const Text('Send code')),
      ],
    );
  }
}
