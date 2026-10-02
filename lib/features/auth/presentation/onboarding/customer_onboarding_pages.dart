import 'dart:async';

import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/brand_mark.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/phone_number.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/demo_seed_chips.dart';
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
  var _busy = false;
  var _resendSeconds = 42;
  Timer? _resendTimer;

  @override
  void didUpdateWidget(covariant CustomerOnboardingPages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.step is CustomerOtpStep && oldWidget.step is! CustomerOtpStep) {
      final step = widget.step as CustomerOtpStep;
      if (step.devOtp != null && _otp.text.isEmpty) {
        _otp.text = step.devOtp!;
      }
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

  Future<void> _run(Future<String?> Function() action) async {
    setState(() => _busy = true);
    final error = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.read(onboardingControllerProvider.notifier);
    return switch (widget.step) {
      CustomerPhoneStep() => _phonePage(flow),
      CustomerOtpStep(:final phone, :final channel, :final devOtp) =>
        _otpPage(flow, phone, channel, devOtp),
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
          "We'll send a 6-digit code on WhatsApp — or tap a demo account below.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        DemoSeedChips(
          role: const CustomerRole(),
          onSelect: (account) {
            _phone.text = account.phone.replaceFirst(RegExp(r'^0'), '');
            unawaited(_run(() => flow.demoQuickLogin(account)));
          },
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
          primaryLabel: _busy ? 'Sending…' : 'Send code',
          onPrimary: _busy
              ? () {}
              : () {
                  if (!_isValidPhone(_phone.text) &&
                      _phone.text.trim().isNotEmpty) {
                    setState(() {
                      _phoneError = 'Enter a valid 10-digit mobile number.';
                    });
                    return;
                  }
                  setState(() => _phoneError = null);
                  unawaited(
                    _run(
                      () => flow.customerSendCode(
                        _phone.text,
                        channel: OtpChannel.whatsapp,
                      ),
                    ),
                  );
                },
          secondaryLabel: 'Continue with Google',
          onSecondary: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Google sign-in needs Firebase. Use phone OTP for demos.',
                ),
              ),
            );
          },
          textLabel: 'Sign up with email',
          onText: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Email OTP is not on this API yet. Use phone OTP for demos.',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _otpPage(
    OnboardingController flow,
    String phone,
    OtpChannel channel,
    String? devOtp,
  ) {
    return OnboardingScaffold(
      mark: BrandMarkKind.customer,
      onBack: flow.back,
      onSkip: () => unawaited(flow.skipToHome()),
      children: [
        Text(
          channel == OtpChannel.sms ? 'SMS check karo' : 'WhatsApp check karo',
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
        if (devOtp != null) ...[
          const SizedBox(height: 8),
          Text(
            'Dev OTP: $devOtp',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
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
            onPressed: () => unawaited(
              _run(() => flow.customerSendCode(phone, channel: channel)),
            ),
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
          primaryLabel: _busy ? 'Verifying…' : 'Verify',
          onPrimary: _busy
              ? () {}
              : () {
                  final code = _otp.text.trim();
                  if (code.isNotEmpty && code.length != 6) {
                    setState(() {
                      _otpError = 'That code is incorrect. Try again.';
                    });
                    return;
                  }
                  setState(() => _otpError = null);
                  unawaited(_run(() => flow.customerVerify(code)));
                },
          textLabel: channel == OtpChannel.sms
              ? 'Send via WhatsApp instead'
              : 'Send via SMS instead',
          onText: () => unawaited(
            _run(
              () => flow.customerSendCode(
                phone,
                channel: channel == OtpChannel.sms
                    ? OtpChannel.whatsapp
                    : OtpChannel.sms,
              ),
            ),
          ),
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
          primaryLabel: _busy ? 'Saving…' : 'Save and continue',
          onPrimary: _busy
              ? () {}
              : () {
                  setState(() => _nameError = null);
                  unawaited(
                    _run(
                      () => flow.customerSaveProfile(
                        name: _name.text,
                        addressText: _place.text,
                        labelUi: _label,
                      ),
                    ),
                  );
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
          onTap: () => unawaited(
            _run(() => flow.customerFinishWithIntent('food')),
          ),
        ),
        const SizedBox(height: 10),
        OnboardingTile(
          title: 'Grocery',
          subtitle: 'Ghar ka saman, gaon tak',
          selected: false,
          leading: const _Bub(icon: GhIcons.shoppingBag),
          onTap: () => unawaited(
            _run(() => flow.customerFinishWithIntent('mart')),
          ),
        ),
        const SizedBox(height: 10),
        OnboardingTile(
          title: 'Dasti',
          subtitle: 'Lunch, file, document. Jo ghar reh gaya',
          selected: false,
          leading: const _Bub(icon: GhIcons.package),
          onTap: () => unawaited(
            _run(() => flow.customerFinishWithIntent('courier')),
          ),
        ),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: 'Continue',
          onPrimary: () => unawaited(
            _run(() => flow.customerFinishWithIntent('food')),
          ),
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
