/// Build-time configuration injected with `--dart-define`.
///
/// Never hardcode API keys or secrets in source.
abstract final class AppConfig {
  /// REST API origin, without a trailing slash.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ghartak-backend-j3g5.onrender.com',
  );

  /// WebSocket origin used for live rider location / chat.
  static const wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'wss://ghartak-backend-j3g5.onrender.com',
  );

  /// Mapbox public token (`pk.…`) for the Maps SDK. Empty until supplied.
  static const mapboxAccessToken = String.fromEnvironment('ACCESS_TOKEN');

  /// Whether the Mapbox Maps SDK can be initialised.
  static bool get hasMapboxToken => mapboxAccessToken.isNotEmpty;

  /// Demo flavor: auto-fill `dev_otp` and soft-fail geo when unavailable.
  static const isDemo = bool.fromEnvironment('DEMO', defaultValue: true);

  /// Legacy Google Maps key (unused while Mapbox is the map stack).
  static const googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );
}
