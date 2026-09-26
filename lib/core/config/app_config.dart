/// Build-time configuration injected with `--dart-define`.
///
/// Never hardcode API keys or base URLs in source.
abstract final class AppConfig {
  /// REST API origin, without a trailing slash.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.ghartak.local',
  );

  /// WebSocket origin used for live rider location.
  static const wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'wss://api.ghartak.local',
  );

  /// Google Maps key. Empty until supplied at build time.
  static const googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );
}
