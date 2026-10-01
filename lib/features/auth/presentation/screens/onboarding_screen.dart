import 'package:attock_xpress/features/auth/presentation/onboarding/customer_onboarding_pages.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/onboarding_step.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/rider_onboarding_pages.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/role_pick_screen.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/welcome_screen.dart';
import 'package:attock_xpress/features/auth/presentation/providers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root onboarding entry. Switches on the sealed step machine.
class OnboardingScreen extends ConsumerWidget {
  /// Creates the onboarding flow.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(onboardingControllerProvider);
    return switch (step) {
      WelcomeStep() => const WelcomeScreen(),
      RolePickStep() => const RolePickScreen(),
      CustomerPhoneStep() ||
      CustomerOtpStep() ||
      CustomerProfileStep() ||
      CustomerIntentStep() => CustomerOnboardingPages(step: step),
      RiderPhoneStep() ||
      RiderOtpStep() ||
      RiderDetailsStep() ||
      RiderDocsStep() ||
      RiderReviewStep() => RiderOnboardingPages(step: step),
    };
  }
}
