import 'dart:async';

import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/brand_mark.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/onboarding_step.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/onboarding_widgets.dart';
import 'package:attock_xpress/features/auth/presentation/providers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rider phone → OTP → details → docs → review screens.
class RiderOnboardingPages extends ConsumerStatefulWidget {
  /// Creates the rider pages for [step].
  const new({required this.step, super.key});

  /// Current rider step.
  final OnboardingStep step;

  @override
  ConsumerState<RiderOnboardingPages> createState() {
    return _RiderOnboardingPagesState();
  }
}

class _RiderOnboardingPagesState extends ConsumerState<RiderOnboardingPages> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _name = TextEditingController();
  final _cnic = TextEditingController();
  final _plate = TextEditingController();
  final _licence = TextEditingController();
  var _city = 'Fateh Jang';
  var _vehicle = 'Bike';
  var _frontDone = true;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    _name.dispose();
    _cnic.dispose();
    _plate.dispose();
    _licence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.read(onboardingControllerProvider.notifier);
    return switch (widget.step) {
      RiderPhoneStep() => _phonePage(flow),
      RiderOtpStep(:final phone) => _otpPage(flow, phone),
      RiderDetailsStep() => _detailsPage(flow),
      RiderDocsStep() => _docsPage(flow),
      RiderReviewStep() => _reviewPage(flow),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _phonePage(OnboardingController flow) {
    return OnboardingScaffold(
      mark: BrandMarkKind.rider,
      onBack: flow.back,
      onSkip: () => unawaited(
        flow.skipToHome(role: OnboardingRole.rider),
      ),
      children: [
        Text(
          'Apni bike, apna time',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Number aur sheher batao, code WhatsApp pe aaye ga.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        OnboardingField(
          controller: _phone,
          hint: '312 7654321',
          focused: true,
          keyboardType: TextInputType.phone,
          prefix: Text(
            '+92',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ChoiceChips(
          options: const [
            'Fateh Jang',
            'Attock City',
            'Hazro',
            'Hassan Abdal',
          ],
          selected: _city,
          onSelect: (value) => setState(() => _city = value),
        ),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: 'Apply karo',
          onPrimary: () => flow.riderApply(_phone.text),
          textLabel: 'Pehle se rider ho? Login',
          onText: () => unawaited(
            flow.skipToHome(role: OnboardingRole.rider),
          ),
        ),
      ],
    );
  }

  Widget _otpPage(OnboardingController flow, String phone) {
    return OnboardingScaffold(
      mark: BrandMarkKind.rider,
      onBack: flow.back,
      onSkip: () => unawaited(
        flow.skipToHome(role: OnboardingRole.rider),
      ),
      children: [
        Text(
          'WhatsApp check karo',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Code bheja · $phone',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        OtpBoxes(controller: _otp),
        const SizedBox(height: 12),
        Text(
          'Dobara bhejo 0:38',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: 'Verify',
          onPrimary: flow.riderVerify,
          textLabel: 'SMS pe bhejo',
          onText: flow.riderVerify,
        ),
      ],
    );
  }

  Widget _detailsPage(OnboardingController flow) {
    return OnboardingScaffold(
      mark: BrandMarkKind.rider,
      onBack: flow.back,
      onSkip: () => unawaited(
        flow.skipToHome(role: OnboardingRole.rider),
      ),
      children: [
        Text(
          'Apni details',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'CNIC pe jo likha hai, wahi likho.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        OnboardingField(
          controller: _name,
          hint: 'Usman Ali',
          focused: true,
        ),
        const SizedBox(height: 10),
        OnboardingField(
          controller: _cnic,
          hint: 'CNIC: 37101-1234567-1',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        ChoiceChips(
          options: const ['Bike', 'Cycle'],
          selected: _vehicle,
          onSelect: (value) => setState(() => _vehicle = value),
        ),
        const SizedBox(height: 12),
        OnboardingField(
          controller: _plate,
          hint: 'Number plate: ATK 1234',
        ),
        const SizedBox(height: 10),
        OnboardingField(
          controller: _licence,
          hint: 'Licence number',
        ),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: 'Aage chalo',
          onPrimary: flow.riderSaveDetails,
        ),
      ],
    );
  }

  Widget _docsPage(OnboardingController flow) {
    return OnboardingScaffold(
      mark: BrandMarkKind.rider,
      onBack: flow.back,
      onSkip: () => unawaited(
        flow.skipToHome(role: OnboardingRole.rider),
      ),
      children: [
        Text(
          'Documents bhejo',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sirf check karne ke liye, aur kahin use nahi hote.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        _DocRow(
          title: 'CNIC aage',
          done: _frontDone,
          onTap: () => setState(() => _frontDone = true),
        ),
        const SizedBox(height: 10),
        const _DocRow(title: 'CNIC peeche', done: false),
        const SizedBox(height: 10),
        const _DocRow(title: 'Licence', done: false),
        const SizedBox(height: 10),
        const _DocRow(title: 'Selfie', done: false),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: 'Bhej do',
          onPrimary: flow.riderSubmitDocs,
        ),
      ],
    );
  }

  Widget _reviewPage(OnboardingController flow) {
    return OnboardingScaffold(
      mark: BrandMarkKind.rider,
      onBack: flow.back,
      onSkip: () => unawaited(
        flow.skipToHome(role: OnboardingRole.rider),
      ),
      children: [
        Text(
          'Hum check kar rahe hain',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '24 se 48 ghante lagte hain.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        const _Timeline(),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: 'Training book karo',
          onPrimary: () => unawaited(flow.finish()),
          textLabel: 'Support se baat karo',
          onText: () => unawaited(flow.finish()),
        ),
      ],
    );
  }
}

class _DocRow extends StatelessWidget {
  const new({required this.title, required this.done, this.onTap});

  final String title;
  final bool done;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? AppColors.darkSurface : AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: dark ? AppColors.darkLine : AppColors.line,
            ),
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.success.withValues(alpha: 0.14)
                      : (dark ? AppColors.darkPeach : AppColors.tint),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    done ? GhIcons.check : GhIcons.image,
                    color: done ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _Tag(done: done),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const new({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: done
            ? AppColors.success.withValues(alpha: 0.14)
            : AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        done ? 'Ho gaya' : 'Zaroori',
        style: TextStyle(
          color: done ? AppColors.success : AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _TlItem(
          title: 'Application mil gayi',
          detail: 'Documents bhi aa gaye',
          state: _TlState.done,
        ),
        _TlItem(
          title: 'Documents check',
          detail: 'Chal raha hai',
          state: _TlState.now,
        ),
        _TlItem(
          title: 'Chhoti si training',
          detail: 'Online ya aamne saamne',
          state: _TlState.next,
        ),
        _TlItem(
          title: 'Online ho ja',
          detail: 'Orders aana shuru',
          state: _TlState.next,
          last: true,
        ),
      ],
    );
  }
}

enum _TlState { done, now, next }

class _TlItem extends StatelessWidget {
  const new({
    required this.title,
    required this.detail,
    required this.state,
    this.last = false,
  });

  final String title;
  final String detail;
  final _TlState state;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final line = dark ? AppColors.darkLine : AppColors.line;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              _Dot(state: state),
              if (!last)
                Container(width: 2, height: 36, color: line),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const new({required this.state});

  final _TlState state;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (state) {
      _TlState.done => const DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 20,
          height: 20,
          child: Icon(GhIcons.check, size: 12, color: Colors.white),
        ),
      ),
      _TlState.now => DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? AppColors.darkPeach : AppColors.tint,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: const SizedBox(width: 20, height: 20),
      ),
      _TlState.next => DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? AppColors.darkBackground : AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(
            color: dark ? AppColors.darkLine : AppColors.line,
            width: 2,
          ),
        ),
        child: const SizedBox(width: 20, height: 20),
      ),
    };
  }
}
