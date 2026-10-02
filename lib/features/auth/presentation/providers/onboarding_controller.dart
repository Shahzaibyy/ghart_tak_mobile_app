import 'package:attock_xpress/core/config/demo_config.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/phone_number.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/onboarding_step.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_controller.dart';
import 'package:attock_xpress/features/auth/presentation/providers/auth_providers.dart';
import 'package:attock_xpress/features/onboarding/data/customer_onboarding_api.dart';
import 'package:attock_xpress/features/onboarding/presentation/onboarding_providers.dart';
import 'package:attock_xpress/features/profile/presentation/providers/profile_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Which role the user picked during onboarding.
enum OnboardingRole {
  /// Order food, grocery, or errands.
  customer,

  /// Deliver as a rider.
  rider,
}

/// Walks the Gen Z signup flow against the live onboarding APIs.
@riverpod
class OnboardingController extends _$OnboardingController {
  OnboardingRole? _role;
  String? _phone;
  String? _zoneId;
  var _busy = false;
  String? _error;
  final _docKeys = <String, String>{};

  @override
  OnboardingStep build() => const WelcomeStep();

  /// Whether a network step is in flight.
  bool get busy => _busy;

  /// Last user-safe error from an API call.
  String? get error => _error;

  /// Moves from welcome to role pick.
  void start() {
    _error = null;
    state = const RolePickStep();
  }

  /// Remembers [role] before advancing.
  void pickRole(OnboardingRole role) {
    if (_role == role) return;
    _role = role;
  }

  /// Advances after a role is chosen.
  void confirmRole() {
    final role = _role;
    if (role == null) return;
    _error = null;
    state = switch (role) {
      OnboardingRole.customer => const CustomerPhoneStep(),
      OnboardingRole.rider => const RiderPhoneStep(),
    };
  }

  /// One-tap Fateh Jang seed login → enters the app with a real session.
  Future<String?> demoQuickLogin(DemoAccount account) async {
    _busy = true;
    _error = null;
    _role = account.role is RiderRole
        ? OnboardingRole.rider
        : OnboardingRole.customer;
    final result = await ref.read(authRepositoryProvider).demoLogin(
          phone: account.phone,
          role: account.role,
        );
    _busy = false;
    return switch (result) {
      Success(:final value) => () {
        ref.read(authControllerProvider.notifier).adopt(value);
        ref.invalidate(profileControllerProvider);
        return null;
      }(),
      Err(:final failure) => failure.message,
    };
  }

  /// Customer: request OTP on [channel] (default WhatsApp).
  Future<String?> customerSendCode(
    String phone, {
    OtpChannel channel = OtpChannel.whatsapp,
  }) async {
    final normalized = _requirePhone(phone);
    if (normalized == null) {
      return 'Enter a valid 10-digit mobile number.';
    }
    _busy = true;
    _error = null;
    final result = await ref.read(authRepositoryProvider).requestOtp(
      phone: normalized,
      role: const CustomerRole(),
      channel: channel,
    );
    _busy = false;
    return switch (result) {
      Success(:final value) => () {
        _phone = normalized;
        state = CustomerOtpStep(
          normalized,
          devOtp: value.devOtp,
          channel: channel,
        );
        return null;
      }(),
      Err(:final failure) => failure.message,
    };
  }

  /// Customer: switch OTP channel to SMS and resend.
  Future<String?> customerSendSms() {
    final phone = _phone;
    if (phone == null) return Future.value('Enter your number first.');
    return customerSendCode(phone, channel: OtpChannel.sms);
  }

  /// Customer: verify OTP and advance to profile.
  Future<String?> customerVerify(String otp) async {
    final phone = _phone;
    if (phone == null) return 'Enter your number first.';
    final code = otp.trim();
    if (code.length != 6) return 'Enter the 6-digit code.';
    _busy = true;
    final result = await ref.read(authRepositoryProvider).verifyOtp(
      phone: phone,
      role: const CustomerRole(),
      otp: code,
    );
    _busy = false;
    return switch (result) {
      Success(:final value) => () {
        ref.read(authControllerProvider.notifier).adopt(value);
        ref.invalidate(profileControllerProvider);
        // Seeded customers already have a name — enter the app.
        if (value.user.name != null && value.user.name!.trim().isNotEmpty) {
          return null;
        }
        state = const CustomerProfileStep();
        return null;
      }(),
      Err(:final failure) => failure.message,
    };
  }

  /// Customer: save name + address via `/customers/onboarding`.
  Future<String?> customerSaveProfile({
    required String name,
    required String addressText,
    required String labelUi,
  }) async {
    final label = name.trim().isEmpty ? 'Customer' : name.trim();
    _busy = true;
    final result = await ref.read(customerOnboardingApiProvider).completeOnboarding(
      name: label,
      label: addressLabelFromUi(labelUi),
      addressText: addressText,
    );
    _busy = false;
    return switch (result) {
      Success() => () {
        state = CustomerIntentStep(name: label);
        return null;
      }(),
      Err(:final failure) => failure.message,
    };
  }

  /// Customer: soft-save preferences then enter the app.
  Future<String?> customerFinishWithIntent(String orderType) async {
    _busy = true;
    await ref.read(customerOnboardingApiProvider).savePreferences([orderType]);
    _busy = false;
    await finish();
    return null;
  }

  /// Rider apply (zone + phone) → OTP.
  Future<String?> riderApply(
    String phone, {
    required String zoneId,
    OtpChannel channel = OtpChannel.whatsapp,
  }) async {
    final normalized = _requirePhone(phone);
    if (normalized == null) {
      return 'Enter a valid 10-digit mobile number.';
    }
    _busy = true;
    final result = await ref.read(riderOnboardingApiProvider).apply(
      phone: normalized,
      zoneId: zoneId,
      channel: channel,
    );
    _busy = false;
    return switch (result) {
      Success(:final value) => () {
        _phone = normalized;
        _zoneId = zoneId;
        _role = OnboardingRole.rider;
        state = RiderOtpStep(
          normalized,
          devOtp: value.devOtp,
          channel: channel,
          zoneId: zoneId,
        );
        return null;
      }(),
      Err(:final failure) => failure.message,
    };
  }

  /// Existing rider login (OTP request only, no apply).
  Future<String?> riderLogin(
    String phone, {
    OtpChannel channel = OtpChannel.whatsapp,
  }) async {
    final normalized = _requirePhone(phone);
    if (normalized == null) {
      return 'Enter a valid 10-digit mobile number.';
    }
    _busy = true;
    final result = await ref.read(authRepositoryProvider).requestOtp(
      phone: normalized,
      role: const RiderRole(),
      channel: channel,
    );
    _busy = false;
    return switch (result) {
      Success(:final value) => () {
        _phone = normalized;
        _role = OnboardingRole.rider;
        state = RiderOtpStep(
          normalized,
          devOtp: value.devOtp,
          channel: channel,
          zoneId: _zoneId ?? DemoConfig.defaultZoneId,
        );
        return null;
      }(),
      Err(:final failure) => failure.message,
    };
  }

  /// Rider: resend via SMS.
  Future<String?> riderSendSms() {
    final phone = _phone;
    final zone = _zoneId ?? DemoConfig.defaultZoneId;
    if (phone == null) return Future.value('Enter your number first.');
    return riderApply(phone, zoneId: zone, channel: OtpChannel.sms);
  }

  /// Rider: verify OTP → details.
  Future<String?> riderVerify(String otp) async {
    final phone = _phone;
    if (phone == null) return 'Enter your number first.';
    final code = otp.trim();
    if (code.length != 6) return 'Enter the 6-digit code.';
    _busy = true;
    final result = await ref.read(authRepositoryProvider).verifyOtp(
      phone: phone,
      role: const RiderRole(),
      otp: code,
    );
    _busy = false;
    return switch (result) {
      Success(:final value) => () {
        ref.read(authControllerProvider.notifier).adopt(value);
        ref.invalidate(profileControllerProvider);
        // Seeded riders are already approved — enter the app.
        if (value.user.name != null && value.user.name!.trim().isNotEmpty) {
          return null;
        }
        state = const RiderDetailsStep();
        return null;
      }(),
      Err(:final failure) => failure.message,
    };
  }

  /// Rider: PATCH details.
  Future<String?> riderSaveDetails({
    required String name,
    required String cnic,
    required String vehicleType,
    String? vehicleReg,
    String? licenseNumber,
  }) async {
    _busy = true;
    final result = await ref.read(riderOnboardingApiProvider).saveDetails(
      name: name.isEmpty ? 'Usman Ali' : name,
      cnic: cnic.isEmpty ? '00000-0000000-0' : cnic,
      vehicleType: vehicleType,
      vehicleReg: vehicleReg,
      licenseNumber: licenseNumber,
    );
    _busy = false;
    return switch (result) {
      Success() => () {
        state = const RiderDocsStep();
        return null;
      }(),
      Err(:final failure) => failure.message,
    };
  }

  /// Marks a document purpose as uploaded (presign → local key for demo).
  Future<String?> riderMarkDocument(String purpose) async {
    _busy = true;
    final result = await ref.read(riderOnboardingApiProvider).presign(purpose);
    _busy = false;
    return switch (result) {
      Success(:final value) => () {
        _docKeys[purpose] = value.objectKey;
        return null;
      }(),
      Err(:final failure) => failure.message,
    };
  }

  /// PUT documents + submit application.
  Future<String?> riderSubmitDocs() async {
    _busy = true;
    final api = ref.read(riderOnboardingApiProvider);
    final docs = await api.saveDocuments(
      cnicFrontKey: _docKeys['cnic_front'] ?? 'local/cnic_front.jpg',
      cnicBackKey: _docKeys['cnic_back'] ?? 'local/cnic_back.jpg',
      licenceKey: _docKeys['driving_licence'] ?? 'local/licence.jpg',
      selfieKey: _docKeys['selfie'] ?? 'local/selfie.jpg',
    );
    if (docs case Err(:final failure)) {
      _busy = false;
      return failure.message;
    }
    final submitted = await api.submit();
    _busy = false;
    return switch (submitted) {
      Success() => () {
        state = const RiderReviewStep();
        return null;
      }(),
      Err(:final failure) => failure.message,
    };
  }

  /// Book orientation then enter the rider shell.
  Future<String?> riderBookOrientation() async {
    _busy = true;
    final result = await ref
        .read(riderOnboardingApiProvider)
        .bookOrientation();
    _busy = false;
    if (result case Err(:final failure)) return failure.message;
    await finish();
    return null;
  }

  /// Open a support ticket then stay on review (or finish on soft-fail).
  Future<String?> riderContactSupport() async {
    _busy = true;
    final result = await ref.read(riderOnboardingApiProvider).contactSupport();
    _busy = false;
    return switch (result) {
      Success() => null,
      Err(:final failure) => failure.message,
    };
  }

  /// Goes back one step when possible.
  void back() {
    _error = null;
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

  /// Opens home as customer or rider without completing forms.
  Future<void> skipToHome({OnboardingRole? role}) {
    final picked = role ?? _role ?? OnboardingRole.customer;
    return _enter(picked);
  }

  /// Finishes onboarding into the matching shell (session already adopted).
  Future<void> finish() async {
    final session = ref.read(authControllerProvider).asData?.value;
    if (session != null) return;
    final picked = _role ?? OnboardingRole.customer;
    await _enter(picked);
  }

  Future<void> _enter(OnboardingRole role) {
    final appRole = switch (role) {
      OnboardingRole.customer => const CustomerRole(),
      OnboardingRole.rider => const RiderRole(),
    };
    return ref.read(authControllerProvider.notifier).preview(appRole);
  }

  String? _requirePhone(String phone) {
    final raw = phone.trim();
    if (raw.isEmpty) {
      return normalizePakistaniPhone(DemoConfig.demoCustomerPhone);
    }
    final normalized = normalizePakistaniPhone(raw);
    if (!isPakistaniMobile(normalized)) return null;
    return normalized;
  }
}
