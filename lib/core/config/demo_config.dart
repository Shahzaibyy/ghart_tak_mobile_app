/// Stable development seed IDs from the backend demo seed guide.
///
/// Safe to hardcode. Do **not** hardcode catalog item IDs or tokens.
abstract final class DemoConfig {
  /// Attock City zone.
  static const attockZoneId = '11111111-1111-4111-8111-111111111101';

  /// Hasan Abdal zone.
  static const hasanAbdalZoneId = '11111111-1111-4111-8111-111111111102';

  /// Seeded demo kitchen (approved).
  static const demoMerchantId = '22222222-2222-4222-8222-222222222201';

  /// Default customer phone for demos (auto-created on first OTP verify).
  static const demoCustomerPhone = '03001234567';

  /// Seeded merchant owner phone.
  static const demoMerchantPhone = '03000000001';

  /// Seeded admin phone.
  static const demoAdminPhone = '03000000002';

  /// Default drop pin inside Attock's 8 km service circle.
  static const demoDropLat = 33.78;
  static const demoDropLng = 72.37;
  static const demoDropAddress = 'House 18, Street 4, Peoples Colony, Attock';
}
