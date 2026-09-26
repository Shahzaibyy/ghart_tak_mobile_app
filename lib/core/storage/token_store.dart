/// Persistence for auth tokens. Callers never touch secure storage directly.
abstract interface class TokenStore {
  /// Reads the value stored at [key], or null when it is absent.
  Future<String?> read(String key);

  /// Writes [value] at [key].
  Future<void> write({required String key, required String value});

  /// Removes [key].
  Future<void> delete(String key);
}
