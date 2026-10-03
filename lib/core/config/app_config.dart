import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

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

  /// Mapbox public token (`pk.…`) for maps / raster tiles.
  ///
  /// Accepts either `ACCESS_TOKEN` (preferred) or `MAP_API_KEY` (`.env` alias).
  static String get mapboxAccessToken {
    const access = String.fromEnvironment('ACCESS_TOKEN');
    if (access.isNotEmpty) return access;
    return const String.fromEnvironment('MAP_API_KEY');
  }

  /// Whether a Mapbox public token was injected at build time.
  static bool get hasMapboxToken => mapboxAccessToken.isNotEmpty;

  /// Maps SDK is mobile-only in this project (no Linux/desktop plugin).
  static bool get mapsSdkSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Token present **and** current platform can host the Maps SDK.
  static bool get canUseMapbox => hasMapboxToken && mapsSdkSupported;

  /// Demo flavor: soft showcase mode (seed chips, demo advance, etc.).
  static const isDemo = bool.fromEnvironment('DEMO', defaultValue: true);

  /// Auto-fill `dev_otp` from `POST /auth/otp/request` in development.
  ///
  /// Defaults on when [isDemo] is true. Override with
  /// `--dart-define=USE_DEV_OTP_AUTOFILL=false`.
  static bool get useDevOtpAutoFill {
    const raw = String.fromEnvironment('USE_DEV_OTP_AUTOFILL');
    if (raw == 'true') return true;
    if (raw == 'false') return false;
    return isDemo;
  }

  /// Show Google sign-in. Keep false until Firebase + `POST /auth/google`
  /// are configured on the backend.
  static const enableGoogleSignIn = bool.fromEnvironment(
    'ENABLE_GOOGLE_SIGN_IN',
    defaultValue: false,
  );

  /// Call backend `/geo/*` (needs `MAPBOX_BACKEND_TOKEN` on the server).
  /// When false, map address search uses the local sample fallback only.
  static bool get enableMapboxGeo {
    const raw = String.fromEnvironment('ENABLE_MAPBOX_GEO');
    if (raw == 'true') return true;
    if (raw == 'false') return false;
    return true;
  }

  /// Legacy Google Maps key (unused while Mapbox is the map stack).
  static const googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );
}
