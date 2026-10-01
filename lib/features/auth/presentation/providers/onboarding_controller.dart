import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/onboarding_step.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Which role the user picked during onboarding.
enum OnboardingRole {
  /// Order food, grocery, or errands.
  customer,

  /// Deliver as a rider.
  rider,
}

/// Walks the Gen Z signup flow without requiring real credentials.
@riverpod
class OnboardingController extends _$OnboardingController {
  OnboardingRole? _role;

  @override
  OnboardingStep build() => const WelcomeStep();

  /// Moves from welcome to role pick.
  void start() => state = const RolePickStep();

  /// Remembers [role] before advancing.
  void pickRole(OnboardingRole role) {
    if (_role == role) return;
    _role = role;
  }

  /// Advances after a role is chosen.
  void confirmRole() {
    final role = _role;
    if (role == null) return;
    state = switch (role) {
      OnboardingRole.customer => const CustomerPhoneStep(),
      OnboardingRole.rider => const RiderPhoneStep(),
    };
  }

  /// Customer: phone → OTP. Empty phone is fine for demos.
  void customerSendCode(String phone) {
    final display = phone.trim().isEmpty ? '+92 300 0000000' : phone.trim();
    state = CustomerOtpStep(display);
  }

  /// Customer: OTP → profile. Code is not validated locally.
  void customerVerify() => state = const CustomerProfileStep();

  /// Customer: profile → intent.
  void customerSaveProfile({required String name}) {
    final label = name.trim().isEmpty ? 'Ayesha' : name.trim();
    state = CustomerIntentStep(name: label);
  }

  /// Rider: phone → OTP.
  void riderApply(String phone) {
    final display = phone.trim().isEmpty ? '+92 312 0000000' : phone.trim();
    state = RiderOtpStep(display);
  }

  /// Rider: OTP → details.
  void riderVerify() => state = const RiderDetailsStep();

  /// Rider: details → documents.
  void riderSaveDetails() => state = const RiderDocsStep();

  /// Rider: documents → review.
  void riderSubmitDocs() => state = const RiderReviewStep();

  /// Goes back one step when possible.
  void back() {
    state = switch (state) {
      WelcomeStep() => state,
      RolePickStep() => const WelcomeStep(),
      CustomerPhoneStep() => const RolePickStep(),
      CustomerOtpStep() => const CustomerPhoneStep(),
      CustomerProfileStep() => const CustomerPhoneStep(),
      CustomerIntentStep() => const CustomerProfileStep(),
      RiderPhoneStep() => const RolePickStep(),
      RiderOtpStep() => const RiderPhoneStep(),
      RiderDetailsStep() => const RiderPhoneStep(),
      RiderDocsStep() => const RiderDetailsStep(),
      RiderReviewStep() => const RiderDocsStep(),
    };
  }

  /// Opens home as customer or rider without any form data.
  Future<void> skipToHome({OnboardingRole? role}) {
    final picked = role ?? _role ?? OnboardingRole.customer;
    return _enter(picked);
  }

  /// Finishes onboarding into the matching shell.
  Future<void> finish() {
    final picked = _role ?? OnboardingRole.customer;
    return _enter(picked);
  }

  Future<void> _enter(OnboardingRole role) {
    final appRole = switch (role) {
      OnboardingRole.customer => const CustomerRole(),
      OnboardingRole.rider => const RiderRole(),
    };
    return ref.read(authControllerProvider.notifier).preview(appRole);
  }
}
