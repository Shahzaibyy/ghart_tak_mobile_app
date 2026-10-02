// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_flow.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Login steps modeled as async state.

@ProviderFor(AuthFlow)
final authFlowProvider = AuthFlowProvider._();

/// Login steps modeled as async state.
final class AuthFlowProvider
    extends $AsyncNotifierProvider<AuthFlow, AuthStep> {
  /// Login steps modeled as async state.
  AuthFlowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authFlowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authFlowHash();

  @$internal
  @override
  AuthFlow create() => AuthFlow();
}

String _$authFlowHash() => r'b1bf4226b67a62b91971ddb4e6d4353ed13007a5';

/// Login steps modeled as async state.

abstract class _$AuthFlow extends $AsyncNotifier<AuthStep> {
  FutureOr<AuthStep> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthStep>, AuthStep>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthStep>, AuthStep>,
              AsyncValue<AuthStep>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
