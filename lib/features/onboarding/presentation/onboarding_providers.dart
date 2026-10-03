import 'package:attock_xpress/core/network/api_envelope.dart';
import 'package:attock_xpress/core/network/network_providers.dart';
import 'package:attock_xpress/features/onboarding/data/customer_onboarding_api.dart';
import 'package:attock_xpress/features/onboarding/data/rider_onboarding_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Customer onboarding API.
final customerOnboardingApiProvider = Provider<CustomerOnboardingApi>((ref) {
  return CustomerOnboardingApi(ref.watch(dioProvider));
});

/// Rider onboarding API.
final riderOnboardingApiProvider = Provider<RiderOnboardingApi>((ref) {
  return RiderOnboardingApi(ref.watch(dioProvider));
});

/// Active zones for the rider city picker (`GET /zones?active=true`).
final activeZonesProvider = FutureProvider<List<ZoneOption>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get<Map<String, dynamic>>(
      '/zones',
      queryParameters: const {'active': true},
    );
    final data = unwrapData<List<dynamic>>(response);
    return [
      for (final row in data)
        if (row is Map)
          ZoneOption(
            id: '${row['id']}',
            name: '${row['city_name'] ?? row['slug'] ?? row['id']}',
          ),
    ];
  } on DioException {
    return const [
      ZoneOption(
        id: '11111111-1111-4111-8111-111111111104',
        name: 'Fateh Jang',
      ),
      ZoneOption(
        id: '11111111-1111-4111-8111-111111111101',
        name: 'Attock City',
      ),
      ZoneOption(
        id: '11111111-1111-4111-8111-111111111102',
        name: 'Hasan Abdal',
      ),
    ];
  }
});

/// One zone row for city chips.
class ZoneOption {
  /// Creates a zone option.
  const new({required this.id, required this.name});

  final String id;
  final String name;
}
