import 'dart:async';

import 'package:attock_xpress/core/config/demo_config.dart';
import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/brand_mark.dart';
import 'package:attock_xpress/features/auth/domain/phone_number.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/onboarding_step.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/onboarding_widgets.dart';
import 'package:attock_xpress/features/auth/presentation/providers/onboarding_controller.dart';
import 'package:attock_xpress/features/onboarding/presentation/onboarding_providers.dart';
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
  var _zoneId = DemoConfig.attockZoneId;
  var _zoneName = 'Attock City';
  var _vehicle = 'Motorcycle';
  final _docsDone = <String>{};
  String? _phoneError;
  String? _otpError;
  var _busy = false;
  var _resendSeconds = 38;
  Timer? _resendTimer;

  @override
  void didUpdateWidget(covariant RiderOnboardingPages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.step is RiderOtpStep && oldWidget.step is! RiderOtpStep) {
      final step = widget.step as RiderOtpStep;
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
    _cnic.dispose();
    _plate.dispose();
    _licence.dispose();
    super.dispose();
  }

  void _startResend() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 38);
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
      RiderPhoneStep() => _phonePage(flow),
      RiderOtpStep(:final phone, :final channel, :final devOtp) =>
        _otpPage(flow, phone, channel, devOtp),
      RiderDetailsStep() => _detailsPage(flow),
      RiderDocsStep() => _docsPage(flow),
      RiderReviewStep() => _reviewPage(flow),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _phonePage(OnboardingController flow) {
    final zones = ref.watch(activeZonesProvider);
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
          "Enter your mobile number. We'll confirm it with a WhatsApp code.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        OnboardingField(
          controller: _phone,
          label: 'Mobile number',
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
        if (_phoneError != null) ...[
          const SizedBox(height: 8),
          Text(
            _phoneError!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          'City',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        zones.when(
          data: (list) {
            final names = list.map((z) => z.name).toList();
            if (names.isEmpty) {
              return Text(
                _zoneName,
                style: Theme.of(context).textTheme.bodyMedium,
              );
            }
            return ChoiceChips(
              options: names,
              selected: _zoneName,
              onSelect: (value) {
                final match = list.firstWhere((z) => z.name == value);
                setState(() {
                  _zoneName = match.name;
                  _zoneId = match.id;
                });
              },
            );
          },
          loading: () => const LinearProgressIndicator(minHeight: 2),
          error: (_, _) => ChoiceChips(
            options: const ['Attock City', 'Hasan Abdal'],
            selected: _zoneName,
            onSelect: (value) => setState(() {
              _zoneName = value;
              _zoneId = value == 'Hasan Abdal'
                  ? DemoConfig.hasanAbdalZoneId
                  : DemoConfig.attockZoneId;
            }),
          ),
        ),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: _busy ? 'Sending…' : 'Apply now',
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
                      () => flow.riderApply(
                        _phone.text,
                        zoneId: _zoneId,
                        channel: OtpChannel.whatsapp,
                      ),
                    ),
                  );
                },
          textLabel: 'Already a rider? Log in',
          onText: _busy
              ? () {}
              : () => unawaited(
                  _run(
                    () => flow.riderLogin(
                      _phone.text,
                      channel: OtpChannel.whatsapp,
                    ),
                  ),
                ),
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
      mark: BrandMarkKind.rider,
      onBack: flow.back,
      onSkip: () => unawaited(
        flow.skipToHome(role: OnboardingRole.rider),
      ),
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
              _run(
                () => flow.riderApply(
                  phone,
                  zoneId: _zoneId,
                  channel: channel,
                ),
              ),
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
                  unawaited(_run(() => flow.riderVerify(code)));
                },
          textLabel: 'Send via SMS instead',
          onText: () => unawaited(_run(flow.riderSendSms)),
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
          'Enter them exactly as on your CNIC.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        OnboardingField(
          controller: _name,
          label: 'Full name',
          hint: 'Usman Ali',
          focused: true,
        ),
        const SizedBox(height: 10),
        OnboardingField(
          controller: _cnic,
          label: 'CNIC number',
          hint: '00000-0000000-0',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        Text(
          'Vehicle type',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        ChoiceChips(
          options: const ['Motorcycle', 'Bicycle'],
          selected: _vehicle,
          onSelect: (value) => setState(() => _vehicle = value),
        ),
        const SizedBox(height: 12),
        OnboardingField(
          controller: _plate,
          label: 'Number plate',
          hint: 'ATK 1234',
        ),
        const SizedBox(height: 10),
        OnboardingField(
          controller: _licence,
          label: 'Driving licence number',
          hint: 'Enter licence number',
        ),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: _busy ? 'Saving…' : 'Continue',
          onPrimary: _busy
              ? () {}
              : () => unawaited(
                  _run(
                    () => flow.riderSaveDetails(
                      name: _name.text,
                      cnic: _cnic.text,
                      vehicleType: _vehicle,
                      vehicleReg: _plate.text,
                      licenseNumber: _licence.text,
                    ),
                  ),
                ),
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
          'Your documents are used only for verification.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        _DocRow(
          title: 'CNIC (front)',
          done: _docsDone.contains('cnic_front'),
          onTap: () => unawaited(_markDoc(flow, 'cnic_front')),
        ),
        const SizedBox(height: 10),
        _DocRow(
          title: 'CNIC (back)',
          done: _docsDone.contains('cnic_back'),
          onTap: () => unawaited(_markDoc(flow, 'cnic_back')),
        ),
        const SizedBox(height: 10),
        _DocRow(
          title: 'Driving licence',
          done: _docsDone.contains('driving_licence'),
          onTap: () => unawaited(_markDoc(flow, 'driving_licence')),
        ),
        const SizedBox(height: 10),
        _DocRow(
          title: 'Selfie',
          done: _docsDone.contains('selfie'),
          onTap: () => unawaited(_markDoc(flow, 'selfie')),
        ),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: _busy ? 'Submitting…' : 'Submit application',
          onPrimary: _busy
              ? () {}
              : () => unawaited(_run(flow.riderSubmitDocs)),
        ),
      ],
    );
  }

  Future<void> _markDoc(OnboardingController flow, String purpose) async {
    await _run(() async {
      final err = await flow.riderMarkDocument(purpose);
      if (err == null && mounted) {
        setState(() => _docsDone.add(purpose));
      }
      return err;
    });
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
          'We usually respond within 24 to 48 hours.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        const _Timeline(),
        const SizedBox(height: 28),
        OnboardingActions(
          primaryLabel: _busy ? 'Booking…' : 'Book orientation',
          onPrimary: _busy
              ? () {}
              : () => unawaited(_run(flow.riderBookOrientation)),
          textLabel: 'Contact support',
          onText: () => unawaited(_run(flow.riderContactSupport)),
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
        done ? 'Uploaded' : 'Required',
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
          title: 'Application received',
          detail: 'Details and documents received',
          state: _TlState.done,
        ),
        _TlItem(
          title: 'Document check',
          detail: 'In progress',
          state: _TlState.now,
        ),
        _TlItem(
          title: 'Orientation',
          detail: 'Short training, online or in person',
          state: _TlState.next,
        ),
        _TlItem(
          title: 'Go online',
          detail: 'Start receiving orders',
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
              if (!last) Container(width: 2, height: 36, color: line),
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
