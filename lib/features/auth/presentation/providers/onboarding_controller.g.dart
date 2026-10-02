// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Walks the Gen Z signup flow against the live onboarding APIs.

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

/// Walks the Gen Z signup flow against the live onboarding APIs.
final class OnboardingControllerProvider
    extends $NotifierProvider<OnboardingController, OnboardingStep> {
  /// Walks the Gen Z signup flow against the live onboarding APIs.
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingStep value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingStep>(value),
    );
  }
}

String _$onboardingControllerHash() =>
    r'6b82b2cbd89a943b9aaff1945f9b8b330e30bf80';

/// Walks the Gen Z signup flow against the live onboarding APIs.

abstract class _$OnboardingController extends $Notifier<OnboardingStep> {
  OnboardingStep build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OnboardingStep, OnboardingStep>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingStep, OnboardingStep>,
              OnboardingStep,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
