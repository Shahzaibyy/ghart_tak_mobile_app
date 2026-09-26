import 'package:attock_xpress/core/storage/hive_boxes.dart';
import 'package:attock_xpress/core/storage/secure_token_store.dart';
import 'package:attock_xpress/core/storage/token_store.dart';
import 'package:attock_xpress/core/utils/geocode_cache.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_providers.g.dart';

/// Keychain-backed token store.
@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) {
  return const SecureTokenStore(FlutterSecureStorage());
}

/// Address geocode cache. The box is opened during bootstrap.
@Riverpod(keepAlive: true)
GeocodeCache geocodeCache(Ref ref) {
  return GeocodeCache(Hive.box<String>(HiveBoxes.geocode));
}
