import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// API user. `toString` is disabled so the phone number is not logged.
@Freezed(toStringOverride: false)
abstract class UserModel with _$UserModel {

  /// Creates a user model.
  const factory({
    required String id,
    required String phone,
    required String role,
    String? name,
  }) = _UserModel;
  const new _();

  /// Parses [json] from the API.
  factory fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Maps this model onto the domain user.
  AppUser toEntity() {
    return AppUser(id: id, role: parseAppRole(role), name: name);
  }
}
