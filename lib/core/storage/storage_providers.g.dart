// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keychain-backed token store.

@ProviderFor(tokenStore)
final tokenStoreProvider = TokenStoreProvider._();

/// Keychain-backed token store.

final class TokenStoreProvider
    extends $FunctionalProvider<TokenStore, TokenStore, TokenStore>
    with $Provider<TokenStore> {
  /// Keychain-backed token store.
  TokenStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStoreHash();

  @$internal
  @override
  $ProviderElement<TokenStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TokenStore create(Ref ref) {
    return tokenStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenStore>(value),
    );
  }
}

String _$tokenStoreHash() => r'27281bb2efdcea526e98affc0cb7c9e8d85f1ccb';

/// Address geocode cache. The box is opened during bootstrap.

@ProviderFor(geocodeCache)
final geocodeCacheProvider = GeocodeCacheProvider._();

/// Address geocode cache. The box is opened during bootstrap.

final class GeocodeCacheProvider
    extends $FunctionalProvider<GeocodeCache, GeocodeCache, GeocodeCache>
    with $Provider<GeocodeCache> {
  /// Address geocode cache. The box is opened during bootstrap.
  GeocodeCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geocodeCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geocodeCacheHash();

  @$internal
  @override
  $ProviderElement<GeocodeCache> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeocodeCache create(Ref ref) {
    return geocodeCache(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeocodeCache value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeocodeCache>(value),
    );
  }
}

String _$geocodeCacheHash() => r'b4da775c38d38942fe2da2973b75e13cf077a8b3';
