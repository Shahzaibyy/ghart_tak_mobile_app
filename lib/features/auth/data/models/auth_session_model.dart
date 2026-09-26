import 'package:attock_xpress/features/auth/data/models/user_model.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session_model.freezed.dart';
part 'auth_session_model.g.dart';

/// Verify-OTP payload. Tokens are not included in `toString`.
@Freezed(toStringOverride: false)
abstract class AuthSessionModel with _$AuthSessionModel {

  /// Creates a session model.
  const factory({
    @JsonKey(name: 'jwt') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    required UserModel user,
  }) = _AuthSessionModel;
  const new _();

  /// Parses [json] from the API.
  factory fromJson(Map<String, dynamic> json) =>
      _$AuthSessionModelFromJson(json);

  /// Maps this model onto a domain session.
  AuthSession toEntity() => AuthSession(user: user.toEntity());
}
