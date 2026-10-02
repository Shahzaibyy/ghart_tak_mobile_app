import 'package:attock_xpress/features/auth/domain/phone_number.dart';

/// Local onboarding machine. Network is driven by [OnboardingController].
sealed class OnboardingStep {
  const new();
}

/// Animated welcome slides.
final class WelcomeStep extends OnboardingStep {
  /// Creates the welcome step.
  const new();
}

/// Customer vs rider choice.
final class RolePickStep extends OnboardingStep {
  /// Creates the role pick step.
  const new();
}

/// Customer phone entry.
final class CustomerPhoneStep extends OnboardingStep {
  /// Creates the customer phone step.
  const new();
}

/// Customer OTP entry.
final class CustomerOtpStep extends OnboardingStep {
  /// Creates the customer OTP step.
  const new(
    this.phone, {
    this.devOtp,
    this.channel = OtpChannel.whatsapp,
  });

  /// Display / API phone string.
  final String phone;

  /// Development OTP when present.
  final String? devOtp;

  /// Channel used for the last send.
  final OtpChannel channel;
}

/// Customer name and delivery place.
final class CustomerProfileStep extends OnboardingStep {
  /// Creates the customer profile step.
  const new();
}

/// What the customer wants to order first.
final class CustomerIntentStep extends OnboardingStep {
  /// Creates the intent step.
  const new({required this.name});

  /// First name from the profile step.
  final String name;
}

/// Rider phone and city (zone).
final class RiderPhoneStep extends OnboardingStep {
  /// Creates the rider phone step.
  const new();
}

/// Rider OTP entry.
final class RiderOtpStep extends OnboardingStep {
  /// Creates the rider OTP step.
  const new(
    this.phone, {
    this.devOtp,
    this.channel = OtpChannel.whatsapp,
    this.zoneId,
  });

  /// Display / API phone string.
  final String phone;

  /// Development OTP when present.
  final String? devOtp;

  /// Channel used for the last send.
  final OtpChannel channel;

  /// Selected zone for apply.
  final String? zoneId;
}

/// Rider identity and vehicle.
final class RiderDetailsStep extends OnboardingStep {
  /// Creates the rider details step.
  const new();
}

/// Rider document checklist.
final class RiderDocsStep extends OnboardingStep {
  /// Creates the rider docs step.
  const new();
}

/// Application review timeline.
final class RiderReviewStep extends OnboardingStep {
  /// Creates the rider review step.
  const new();
}
