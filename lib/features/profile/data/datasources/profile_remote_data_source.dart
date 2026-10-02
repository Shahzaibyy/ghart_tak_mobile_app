import 'package:attock_xpress/core/network/api_envelope.dart';
import 'package:attock_xpress/features/profile/data/models/user_profile_model.dart';
import 'package:dio/dio.dart';

/// HTTP access to `GET /users/me`.
class ProfileRemoteDataSource {
  /// Creates a data source over the HTTP client.
  const new(this._dio);

  final Dio _dio;

  /// Fetches the signed-in profile.
  Future<UserProfileModel> readProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/users/me');
    final data = unwrapData<Map<String, dynamic>>(response);
    final name = (data['name'] as String?)?.trim();
    final phone = (data['phone'] as String?)?.trim();
    return UserProfileModel(
      displayName: (name == null || name.isEmpty) ? 'Customer' : name,
      phone: (phone == null || phone.isEmpty) ? '—' : phone,
    );
  }
}
