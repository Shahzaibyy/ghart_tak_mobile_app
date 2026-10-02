import 'package:attock_xpress/features/auth/domain/entities/app_user.dart';
import 'package:attock_xpress/features/auth/domain/entities/auth_session.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';

/// Session payload from `POST /auth/otp/verify` / `POST /auth/refresh`.
///
/// Tokens are persisted separately; [toEntity] only exposes the user.
class AuthSessionModel {
  /// Creates a session model.
  const new({
    required this.accessToken,
    required this.refreshToken,
    required this.accountId,
    required this.role,
    this.status,
    this.name,
    this.phone,
    this.expiresIn,
  });

  /// Access JWT.
  final String accessToken;

  /// Refresh token.
  final String refreshToken;

  /// Account UUID (`account_id`).
  final String accountId;

  /// Role string from the API.
  final String role;

  /// Account status (`active`, …).
  final String? status;

  /// Optional display name from profile merge.
  final String? name;

  /// Optional phone from profile merge.
  final String? phone;

  /// Access lifetime in seconds.
  final int? expiresIn;

  /// Parses the inner session object (already unwrapped from `data`).
  factory fromSessionJson(Map<String, dynamic> json) {
    final access = json['access_token'];
    final refresh = json['refresh_token'];
    final accountId = json['account_id'];
    final role = json['role'];
    if (access is! String ||
        refresh is! String ||
        accountId is! String ||
        role is! String) {
      throw const FormatException('Invalid session payload');
    }
    return AuthSessionModel(
      accessToken: access,
      refreshToken: refresh,
      accountId: accountId,
      role: role,
      status: json['status'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      expiresIn: json['expires_in'] as int?,
    );
  }

  /// Restores a previously persisted session document.
  factory fromJson(Map<String, dynamic> json) =>
      AuthSessionModel.fromSessionJson(json);

  /// JSON for secure storage.
  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'account_id': accountId,
    'role': role,
    if (status != null) 'status': status,
    if (name != null) 'name': name,
    if (phone != null) 'phone': phone,
    if (expiresIn != null) 'expires_in': expiresIn,
  };

  /// Domain session (tokens stay in secure storage).
  AuthSession toEntity() {
    return AuthSession(
      user: AppUser(
        id: accountId,
        role: parseAppRole(role),
        name: name,
      ),
    );
  }

  /// Returns a copy with profile fields filled in.
  AuthSessionModel withProfile({String? name, String? phone}) {
    return AuthSessionModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accountId: accountId,
      role: role,
      status: status,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      expiresIn: expiresIn,
    );
  }
}
