import 'dart:async';

import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/brand_mark.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/onboarding_step.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/onboarding_widgets.dart';
import 'package:attock_xpress/features/auth/presentation/providers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Customer phone → OTP → profile → intent screens.
class CustomerOnboardingPages extends ConsumerStatefulWidget {
  /// Creates the customer pages for [step].
  const new({required this.step, super.key});

  /// Current customer step.
  final OnboardingStep step;

  @override
  ConsumerState<CustomerOnboardingPages> createState() {
    return _CustomerOnboardingPagesState();
  }
}

class _CustomerOnboardingPagesState
    extends ConsumerState<CustomerOnboardingPages> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _name = TextEditingController();
  final _place = TextEditingController();
  var _label = 'Home';
  String? _phoneError;
  String? _otpError;
  String? _nameError;
  var _resendSeconds = 42;
  Timer? _resendTimer;

  @override
  void didUpdateWidget(covariant CustomerOnboardingPages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.step is CustomerOtpStep && oldWidget.step is! CustomerOtpStep) {
      _startResend();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phone.dispose();
    _otp.dispose();
    _name.dispose();
    _place.dispose();
    super.dispose();
  }

  void _startResend() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 42);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds -= 1);
    });
  }

  bool _isValidPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final local = digits.startsWith('92') ? digits.substring(2) : digits;
    return RegExp(r'^3\d{9}$').hasMatch(local);
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.read(onboardingControllerProvider.notifier);
    return switch (widget.step) {
      CustomerPhoneStep() => _phonePage(flow),
      CustomerOtpStep(:final phone) => _otpPage(flow, phone),
      CustomerProfileStep() => _profilePage(flow),
      CustomerIntentStep(:final name) => _intentPage(flow, name),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _phonePage(OnboardingController flow) {
    return OnboardingScaffold(
      mark: BrandMarkKind.customer,
      onBack: flow.back,
      onSkip: () => unawaited(flow.skipToHome()),
      children: [
        Text(
          'Number batao',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "We'll send a 6-digit code on WhatsApp.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        OnboardingField(
          controller: _phone,
          label: 'Mobile number',
          hint: '300 1234567',
          focused: true,
          keyboardType: TextInputType.phone,
          prefix: Text(
            '+92',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_phoneError != null) ...[
          const SizedBox(height: 8),
          Text(
            _phoneError!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: 'Send code',
          onPrimary: () {
            if (!_isValidPhone(_phone.text) && _phone.text.trim().isNotEmpty) {
              setState(() {
                _phoneError = 'Enter a valid 10-digit mobile number.';
              });
              return;
            }
            setState(() => _phoneError = null);
            flow.customerSendCode(_phone.text);
          },
          secondaryLabel: 'Continue with Google',
          onSecondary: () => unawaited(flow.skipToHome()),
          textLabel: 'Sign up with email',
          onText: () => unawaited(flow.skipToHome()),
        ),
      ],
    );
  }

  Widget _otpPage(OnboardingController flow, String phone) {
    return OnboardingScaffold(
      mark: BrandMarkKind.customer,
      onBack: flow.back,
      onSkip: () => unawaited(flow.skipToHome()),
      children: [
        Text(
          'WhatsApp check karo',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(text: 'Enter the 6-digit code sent to $phone. '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: flow.back,
                  child: Text(
                    'Change number',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OtpBoxes(controller: _otp),
        if (_otpError != null) ...[
          const SizedBox(height: 8),
          Text(
            _otpError!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (_resendSeconds > 0)
          Text(
            'Resend code in 0:${_resendSeconds.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          TextButton(
            onPressed: _startResend,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Resend code',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: 'Verify',
          onPrimary: () {
            final code = _otp.text.trim();
            if (code.isNotEmpty && code.length != 6) {
              setState(() {
                _otpError = 'That code is incorrect. Try again.';
              });
              return;
            }
            setState(() => _otpError = null);
            flow.customerVerify();
          },
          textLabel: 'Send via SMS instead',
          onText: flow.customerVerify,
        ),
      ],
    );
  }

  Widget _profilePage(OnboardingController flow) {
    return OnboardingScaffold(
      mark: BrandMarkKind.customer,
      onBack: flow.back,
      onSkip: () => unawaited(flow.skipToHome()),
      children: [
        Text(
          'Aap ka naam?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        OnboardingField(
          controller: _name,
          label: 'Full name',
          hint: 'Ayesha Khan',
          focused: true,
        ),
        if (_nameError != null) ...[
          const SizedBox(height: 8),
          Text(
            _nameError!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
        const SizedBox(height: 16),
        OnboardingField(
          controller: _place,
          label: 'Delivery address',
          hint: 'House no., street, area',
        ),
        const SizedBox(height: 12),
        ChoiceChips(
          options: const ['Home', 'Work', 'Other'],
          selected: _label,
          onSelect: (value) => setState(() => _label = value),
        ),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: 'Save and continue',
          onPrimary: () {
            setState(() => _nameError = null);
            flow.customerSaveProfile(name: _name.text);
          },
        ),
      ],
    );
  }

  Widget _intentPage(OnboardingController flow, String name) {
    return OnboardingScaffold(
      mark: BrandMarkKind.customer,
      onBack: flow.back,
      onSkip: () => unawaited(flow.skipToHome()),
      children: [
        Text(
          '$name, kya mangwana hai?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        OnboardingTile(
          title: 'Khaana',
          subtitle: 'Fateh Jang ke desi khaane',
          selected: false,
          leading: const _Bub(icon: GhIcons.forkKnife),
          onTap: () => unawaited(flow.finish()),
        ),
        const SizedBox(height: 10),
        OnboardingTile(
          title: 'Grocery',
          subtitle: 'Ghar ka saman, gaon tak',
          selected: false,
          leading: const _Bub(icon: GhIcons.shoppingBag),
          onTap: () => unawaited(flow.finish()),
        ),
        const SizedBox(height: 10),
        OnboardingTile(
          title: 'Dasti',
          subtitle: 'Lunch, file, document. Jo ghar reh gaya',
          selected: false,
          leading: const _Bub(icon: GhIcons.package),
          onTap: () => unawaited(flow.finish()),
        ),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: 'Continue',
          onPrimary: () => unawaited(flow.finish()),
        ),
      ],
    );
  }
}

class _Bub extends StatelessWidget {
  const new({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkPeach : AppColors.tint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}
