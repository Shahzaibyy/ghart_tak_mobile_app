import 'package:attock_xpress/features/profile/data/models/user_profile_model.dart';
import 'package:dio/dio.dart';

/// HTTP access to the profile.
class ProfileRemoteDataSource {
  /// Creates a data source over the HTTP client.
  const new(this._dio);

  final Dio _dio;

  /// Fetches the profile.
  Future<UserProfileModel> readProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/profile');
    final raw = response.data;
    if (raw == null) {
      throw const FormatException('Expected a profile object');
    }
    return UserProfileModel.fromJson(raw);
  }
}
