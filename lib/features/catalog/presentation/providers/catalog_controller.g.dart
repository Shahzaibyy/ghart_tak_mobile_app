// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Catalog repository. Sample data until the merchant API is live.

@ProviderFor(catalogRepository)
final catalogRepositoryProvider = CatalogRepositoryProvider._();

/// Catalog repository. Sample data until the merchant API is live.

final class CatalogRepositoryProvider
    extends
        $FunctionalProvider<
          CatalogRepository,
          CatalogRepository,
          CatalogRepository
        >
    with $Provider<CatalogRepository> {
  /// Catalog repository. Sample data until the merchant API is live.
  CatalogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogRepositoryHash();

  @$internal
  @override
  $ProviderElement<CatalogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CatalogRepository create(Ref ref) {
    return catalogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogRepository>(value),
    );
  }
}

String _$catalogRepositoryHash() => r'393f9b92fa0ff2e93ebb58a2cb73759c82e83b6f';

/// Browse use case.

@ProviderFor(browseMerchants)
final browseMerchantsProvider = BrowseMerchantsProvider._();

/// Browse use case.

final class BrowseMerchantsProvider
    extends
        $FunctionalProvider<BrowseMerchants, BrowseMerchants, BrowseMerchants>
    with $Provider<BrowseMerchants> {
  /// Browse use case.
  BrowseMerchantsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browseMerchantsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browseMerchantsHash();

  @$internal
  @override
  $ProviderElement<BrowseMerchants> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BrowseMerchants create(Ref ref) {
    return browseMerchants(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrowseMerchants value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrowseMerchants>(value),
    );
  }
}

String _$browseMerchantsHash() => r'88ce810726b457fd8bd07a1c0e746d9d24f49241';

/// Filtered home feed.

@ProviderFor(CatalogController)
final catalogControllerProvider = CatalogControllerProvider._();

/// Filtered home feed.
final class CatalogControllerProvider
    extends $AsyncNotifierProvider<CatalogController, CatalogFeed> {
  /// Filtered home feed.
  CatalogControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogControllerHash();

  @$internal
  @override
  CatalogController create() => CatalogController();
}

String _$catalogControllerHash() => r'250376ef2d9dd937dfbf97795d1677e6ed062916';

/// Filtered home feed.

abstract class _$CatalogController extends $AsyncNotifier<CatalogFeed> {
  FutureOr<CatalogFeed> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CatalogFeed>, CatalogFeed>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CatalogFeed>, CatalogFeed>,
              AsyncValue<CatalogFeed>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
