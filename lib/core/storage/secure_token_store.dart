import 'package:attock_xpress/core/storage/token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [TokenStore] backed by the platform keychain / keystore.
class SecureTokenStore implements TokenStore {
  /// Creates a store over platform secure storage.
  const new(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
