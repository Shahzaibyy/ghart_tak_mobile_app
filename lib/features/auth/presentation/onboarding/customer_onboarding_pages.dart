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
  var _label = 'Ghar';

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    _name.dispose();
    _place.dispose();
    super.dispose();
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
          'Code WhatsApp pe bhejte hain.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        OnboardingField(
          controller: _phone,
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
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: 'Code bhejo',
          onPrimary: () => flow.customerSendCode(_phone.text),
          secondaryLabel: 'Google se aao',
          onSecondary: () => unawaited(flow.skipToHome()),
          textLabel: 'Email se sign up karo',
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
        Text(
          '6 digit ka code aaya hoga · $phone',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        OtpBoxes(controller: _otp),
        const SizedBox(height: 12),
        Text(
          'Dobara bhejo 0:42',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: 'Verify karo',
          onPrimary: flow.customerVerify,
          textLabel: 'SMS pe bhejo',
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
          hint: 'Ayesha',
          focused: true,
        ),
        const SizedBox(height: 16),
        Text(
          'Kahan deliver karna hai?',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        OnboardingField(
          controller: _place,
          hint: 'Attock Road, Fateh Jang',
        ),
        const SizedBox(height: 12),
        ChoiceChips(
          options: const ['Ghar', 'Office', 'Gaon'],
          selected: _label,
          onSelect: (value) => setState(() => _label = value),
        ),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: 'Chalo shuru',
          onPrimary: () => flow.customerSaveProfile(name: _name.text),
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
          primaryLabel: 'Home pe jao',
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
