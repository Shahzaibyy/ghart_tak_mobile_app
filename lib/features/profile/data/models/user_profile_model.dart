import 'package:attock_xpress/features/profile/domain/entities/user_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

/// Profile payload. `toString` is disabled so the phone is not logged.
@Freezed(toStringOverride: false)
abstract class UserProfileModel with _$UserProfileModel {

  /// Creates a profile model.
  const factory({
    @JsonKey(name: 'name') required String displayName,
    required String phone,
  }) = _UserProfileModel;
  const new _();

  /// Parses [json].
  factory fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  /// Maps this model onto the domain profile.
  UserProfile toEntity() {
    return UserProfile(displayName: displayName, phone: phone);
  }
}
