import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:flutter/material.dart';

/// Six-digit OTP form. The phone number is not shown.
class OtpForm extends StatelessWidget {
  /// Creates the form.
  const new({
    required this.controller,
    required this.onSubmit,
    this.hint,
    super.key,
  });

  /// OTP field controller.
  final TextEditingController controller;

  /// Submits the code.
  final VoidCallback onSubmit;

  /// Optional helper under the field (e.g. demo `dev_otp` notice).
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Enter the code',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          hint ?? 'We sent a 6-digit code to your phone.',
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(labelText: 'Code'),
        ),
        const SizedBox(height: 16),
        GhButton(label: 'Continue', onPressed: onSubmit),
      ],
    );
  }
}
