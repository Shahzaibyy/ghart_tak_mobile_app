import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';

/// One seeded showcase account from the development seed guide.
class DemoAccount {
  /// Creates a seeded account.
  const new({
    required this.phone,
    required this.name,
    required this.role,
  });

  final String phone;
  final String name;
  final AppRole role;
}

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

  /// Fateh Jang seeded customers for one-tap demo login.
  static const customers = <DemoAccount>[
    DemoAccount(
      phone: '03001111001',
      name: 'Ayesha Khan',
      role: CustomerRole(),
    ),
    DemoAccount(
      phone: '03001111002',
      name: 'Ali Hassan',
      role: CustomerRole(),
    ),
    DemoAccount(
      phone: '03001111003',
      name: 'Sana Malik',
      role: CustomerRole(),
    ),
    DemoAccount(
      phone: '03001111004',
      name: 'Omar Farooq',
      role: CustomerRole(),
    ),
    DemoAccount(
      phone: '03001111005',
      name: 'Hira Bibi',
      role: CustomerRole(),
    ),
  ];

  /// Fateh Jang seeded riders (approved + online).
  static const riders = <DemoAccount>[
    DemoAccount(
      phone: '03002222001',
      name: 'Usman Ali',
      role: RiderRole(),
    ),
    DemoAccount(
      phone: '03002222002',
      name: 'Bilal Khan',
      role: RiderRole(),
    ),
    DemoAccount(
      phone: '03002222003',
      name: 'Hamza Iqbal',
      role: RiderRole(),
    ),
    DemoAccount(
      phone: '03002222004',
      name: 'Saad Raza',
      role: RiderRole(),
    ),
    DemoAccount(
      phone: '03002222005',
      name: 'Farhan Malik',
      role: RiderRole(),
    ),
  ];

  /// Accounts for [role].
  static List<DemoAccount> accountsFor(AppRole role) {
    return switch (role) {
      CustomerRole() => customers,
      RiderRole() => riders,
    };
  }
}
