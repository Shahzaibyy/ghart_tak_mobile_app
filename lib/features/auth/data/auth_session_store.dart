import 'dart:convert';

import 'package:attock_xpress/core/storage/token_keys.dart';
import 'package:attock_xpress/core/storage/token_store.dart';
import 'package:attock_xpress/features/auth/data/models/auth_session_model.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';

/// Persists the session JSON and the raw tokens in secure storage.
class AuthSessionStore {
  /// Creates a store over the token store.
  const new(this._tokens);

  final TokenStore _tokens;

  /// Reads the saved session, or null when signed out or corrupt.
  Future<AuthSession?> read() async {
    final raw = await _tokens.read(TokenKeys.session);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final model = AuthSessionModel.fromJson(
      Map<String, dynamic>.from(decoded),
    );
    return model.toEntity();
  }

  /// Writes tokens and the session document.
  Future<void> save(AuthSessionModel model) async {
    await _tokens.write(key: TokenKeys.access, value: model.accessToken);
    await _tokens.write(key: TokenKeys.refresh, value: model.refreshToken);
    await _tokens.write(
      key: TokenKeys.session,
      value: jsonEncode(model.toJson()),
    );
  }

  /// Removes every auth key.
  Future<void> clear() async {
    await _tokens.delete(TokenKeys.access);
    await _tokens.delete(TokenKeys.refresh);
    await _tokens.delete(TokenKeys.session);
  }
}
