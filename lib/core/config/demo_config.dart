import 'package:attock_xpress/core/utils/geo_point.dart';

/// Stable development seed IDs from the backend demo seed guide.
///
/// Safe to hardcode. Do **not** hardcode catalog item IDs or tokens.
abstract final class DemoConfig {
  /// Default showcase zone — Fateh Jang (8 restaurants + online riders).
  static const String defaultZoneId = fatehJangZoneId;

  /// Fateh Jang zone (migration `0010`).
  static const fatehJangZoneId = '11111111-1111-4111-8111-111111111104';

  /// Attock City zone.
  static const attockZoneId = '11111111-1111-4111-8111-111111111101';

  /// Hasan Abdal zone.
  static const hasanAbdalZoneId = '11111111-1111-4111-8111-111111111102';

  /// Original Attock demo kitchen (still seeded).
  static const demoMerchantId = '22222222-2222-4222-8222-222222222201';

  /// Pre-seeded Fateh Jang customer (Ayesha).
  static const demoCustomerPhone = '03001111001';

  /// Pre-seeded Fateh Jang rider (Usman).
  static const demoRiderPhone = '03002222001';

  /// Attock demo merchant phone.
  static const demoMerchantPhone = '03000000001';

  /// Seeded admin phone.
  static const demoAdminPhone = '03000000002';

  /// Zone centre for Fateh Jang.
  static const zoneCenter = GeoPoint(lat: 33.5672, lng: 72.6417);

  /// Default drop near Bismillah Restaurant / town centre.
  static const demoDropLat = 33.5685;
  static const demoDropLng = 72.6430;
  static const demoDropAddress =
      'Near Bismillah Restaurant, Fateh Jang, Attock District';

  static const demoDrop = GeoPoint(lat: demoDropLat, lng: demoDropLng);
}
