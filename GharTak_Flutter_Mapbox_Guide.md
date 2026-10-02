# GharTak — Flutter Mapbox Integration Guide

**Scope:** Customer app + Rider app (Flutter). Maps SDK only (`mapbox_maps_flutter` v2).
**Source:** Mapbox Maps SDK for Flutter docs (install, styles, camera, animations, annotations, layers, user location, pricing). Code below is adapted from those docs and corrected where the docs had Swift leftovers (`let`) or wrong lat/lng order. **It has not been compiled** — if a method signature differs in your installed version, check the API reference for that version (`cameraFor*` signatures in particular have changed between minors).

---

## 0. Read this first (decisions + gotchas)

| # | Point |
|---|---|
| 1 | **Coordinate order is `Position(lng, lat)`** — longitude first. The Mapbox docs' own camera snippet has them swapped. Our backend/DB stores `lat`, `lng` — convert in ONE helper (see §4). |
| 2 | **Flutter Maps SDK = map rendering only.** No routing, no geocoding, no turn-by-turn. Directions/geocoding/ETA come from **our backend** (see `GharTak_Backend_Mapbox_Requirements.md`). |
| 3 | **Turn-by-turn navigation is not part of this SDK.** The fetched docs cover Maps only. For rider navigation: draw the route line in-app, and for voice turn-by-turn deep-link to Google Maps (`google.navigation:q=lat,lng` via `url_launcher`). Revisit if you later want an in-app navigation SDK. (SRS FR-R05 assumed Google Maps SDK — update that line.) |
| 4 | **Billing:** the Maps SDK is billed per **monthly active user (MAU)**; tile loads are included. Directions / Geocoding / Matrix are billed **per request** on the backend token. Reinstalling the app counts as a new MAU. Check the Mapbox pricing page for the current free tier. |
| 5 | **Stay on v2** (`^2.0.0`). A v3 beta (adds web) exists — not needed for the mobile apps. |
| 6 | Annotations are **inefficient for many features**. Use annotations for ≤ ~50 items (rider, pickup, drop). Use a GeoJSON source + layer for merchant lists on the map. |

---

## 1. Tokens

| Token | Where | Notes |
|---|---|---|
| **Public token** (`pk.…`) | Flutter apps | Only used by the Maps SDK for tiles. Create a **new** token named e.g. `ghartak-mobile`, skip scopes/URL restrictions (per docs), do not commit it. |
| **Backend token** | Render env var only | Separate token for Directions/Geocoding/Matrix. Never ship it in the app. Separate tokens also matter because Mapbox rate limits are counted **per token**. |

Pass the public token at build time:

```bash
flutter run --dart-define ACCESS_TOKEN=pk.xxxxx
flutter build apk --dart-define ACCESS_TOKEN=pk.xxxxx
```

Cleaner for a team (file is git-ignored):

```bash
flutter run --dart-define-from-file=env/dev.json
# env/dev.json  ->  { "ACCESS_TOKEN": "pk.xxxxx", "API_BASE_URL": "https://<render-app>.onrender.com" }
```

VS Code `launch.json`:

```json
{ "configurations": [ { "name": "GharTak", "request": "launch", "type": "dart",
  "program": "lib/main.dart",
  "args": ["--dart-define", "ACCESS_TOKEN=pk.xxxxx"] } ] }
```

---

## 2. Install

`pubspec.yaml`:

```yaml
dependencies:
  mapbox_maps_flutter: ^2.0.0
  permission_handler: any     # location permission (pin to latest stable)
  geolocator: any             # raw GPS stream (puck does not expose position to Dart)
  url_launcher: any           # open Google Maps for turn-by-turn
```

`main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(const String.fromEnvironment('ACCESS_TOKEN'));
  runApp(const GharTakApp());
}
```

Set the token **once** in `main()`, not inside `build()`.

### 2.1 Permissions

**Android** — `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

Rider app additionally needs a foreground service for tracking while the screen is off (see §10).

**iOS** — `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>GharTak uses your location to show nearby stores and deliver to you.</string>
```

Request at runtime before enabling the puck:

```dart
final status = await Permission.locationWhenInUse.request();
```

---

## 3. Recommended folder structure

```
lib/features/map/
  data/
    geo_api.dart              # calls OUR backend: /geo/search, /geo/reverse, /orders/quote
  domain/
    geo_point.dart            # GeoPoint(lat, lng) — app-wide type
  presentation/
    ghartak_map.dart          # reusable MapWidget wrapper (this guide §5)
    map_controller.dart       # owns MapboxMap + annotation managers
    address_picker_page.dart  # §8
    tracking_map.dart         # §9 (customer) / rider task map
  core/
    map_constants.dart        # Attock bounds, zone centers, style ids, layer ids
    mapbox_codec.dart         # GeoPoint <-> Point conversions (lng,lat)
```

Keep Mapbox types out of your domain/state layer: only `map_controller.dart` and `mapbox_codec.dart` should import `mapbox_maps_flutter`.

---

## 4. Coordinate helper (do this first)

```dart
class GeoPoint {
  final double lat;
  final double lng;
  const GeoPoint(this.lat, this.lng);
}

// mapbox_codec.dart — the ONLY place lat/lng order is handled
Point toMapbox(GeoPoint p) => Point(coordinates: Position(p.lng, p.lat));
GeoPoint fromMapbox(Point p) => GeoPoint(p.coordinates.lat.toDouble(), p.coordinates.lng.toDouble());
```

---

## 5. Base map widget

```dart
class GharTakMap extends StatefulWidget {
  final GeoPoint center;
  final double zoom;
  final void Function(MapboxMap) onReady;
  const GharTakMap({super.key, required this.center, this.zoom = 13, required this.onReady});

  @override
  State<GharTakMap> createState() => _GharTakMapState();
}

class _GharTakMapState extends State<GharTakMap> {
  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: const ValueKey('ghartak-map'),         // keep key stable -> map is not recreated
      styleUri: MapboxStyles.MAPBOX_STREETS,       // see §6 for Standard vs Streets
      cameraOptions: CameraOptions(
        center: toMapbox(widget.center),
        zoom: widget.zoom,
      ),
      onMapCreated: _onMapCreated,
    );
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    await map.gestures.updateSettings(
      GesturesSettings(rotateEnabled: false, pitchEnabled: false), // simpler UX for our users
    );
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    widget.onReady(map);
  }
}
```

Starting the camera at the user's **zone center** (from `GET /zones`) makes tiles load faster (docs: SDK loads tiles around the initial camera first).

---

## 6. Styles

- Default style is **Mapbox Standard** (3D buildings, light presets). Constants: `MapboxStyles.STANDARD`, `MapboxStyles.STANDARD_SATELLITE`.
- **Recommendation (our judgment, not from docs):** the target audience has low–medium-end Android phones on 3G/4G. Start with `MapboxStyles.MAPBOX_STREETS` (flat, lighter), or Standard with 3D off. Test on a cheap device before deciding.

Runtime changes:

```dart
// switch style (runtime layers you added are lost -> re-add on style load)
await map.style.setStyleURI(MapboxStyles.STANDARD_SATELLITE);

// Standard-only config (import id is "basemap")
await map.style.setStyleImportConfigProperty('basemap', 'lightPreset', 'dusk');
await map.style.setStyleImportConfigProperty('basemap', 'show3dObjects', false);
await map.style.setStyleImportConfigProperty('basemap', 'showPointOfInterestLabels', false);

// custom / Streets style layer tweak
await map.style.setStyleLayerProperty('water', 'fill-color', '#45d9ca');
```

**Night mode idea:** switch `lightPreset` between `day` / `dusk` / `night` by local time — one line, big UX win.

**Custom brand style:** build in Mapbox Studio, load with `map.loadStyleURI('mapbox://styles/<user>/<style-id>')` or `MapWidget(styleUri: ...)`. Edits published in Studio show up in the app without a release.

**Layers vanish on style switch.** Either re-add them in `onStyleLoadedListener`, or add with `addPersistentStyleLayer`. Standard style uses **slots** (`bottom`, `middle`, `top`) to position custom layers — use `slot: 'middle'` for route lines, not layer ids.

---

## 7. Camera

```dart
// Instant move
await map.setCamera(CameraOptions(center: toMapbox(p), zoom: 15));

// Animated (only ONE camera animation runs at a time; a new one cancels the old)
await map.flyTo(
  CameraOptions(center: toMapbox(p), zoom: 16),
  MapAnimationOptions(duration: 1200, startDelay: 0),
);
await map.easeTo(
  CameraOptions(center: toMapbox(p), zoom: 16),
  MapAnimationOptions(duration: 600),
);

// Read camera
final state = await map.getCameraState();   // state.center, state.zoom ...
```

### 7.1 Lock the map to Attock district

Stops users panning to the other side of the world and saves tiles/MAU weirdness. Get the bounding box from your zones (or hard-code a generous box for the district).

```dart
await map.setBounds(CameraBoundsOptions(
  bounds: CoordinateBounds(
    southwest: Point(coordinates: Position(72.0, 33.2)),   // PLACEHOLDER lng, lat — replace with real district bbox
    northeast: Point(coordinates: Position(73.1, 34.0)),   // PLACEHOLDER
    infiniteBounds: false,
  ),
  minZoom: 8,
  maxZoom: 19,
));
```

### 7.2 Fit pickup + drop (tracking screen, quote screen)

```dart
final sw = Point(coordinates: Position(min(a.lng, b.lng), min(a.lat, b.lat)));
final ne = Point(coordinates: Position(max(a.lng, b.lng), max(a.lat, b.lat)));
final cam = await map.cameraForCoordinateBounds(
  CoordinateBounds(southwest: sw, northeast: ne, infiniteBounds: false),
  MbxEdgeInsets(top: 120, left: 48, bottom: 320, right: 48), // leave room for bottom sheet
  null, null, null, null,   // bearing, pitch, maxZoom, offset — signature varies by version, verify
);
await map.setCamera(cam);
```

Camera listeners: `MapWidget(onCameraChangeListener: ..., onMapIdleListener: ...)`. Use **idle**, not change, for anything that triggers a network call (§8).

---

## 8. Customer: address picker (map pin → address)

**Pattern:** a pin widget fixed in the **center of the screen** (a normal Flutter `Icon` stacked over the map). User drags the map; when it goes idle, read the camera center and ask the backend for the address.

```dart
Stack(children: [
  MapWidget(
    styleUri: MapboxStyles.MAPBOX_STREETS,
    cameraOptions: CameraOptions(center: toMapbox(initial), zoom: 16),
    onMapCreated: (m) => _map = m,
    onMapIdleListener: (_) => _onIdle(),
  ),
  const Center(child: Icon(Icons.location_pin, size: 48)),   // visually offset so the tip is the center
]);

Timer? _debounce;
void _onIdle() {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 400), () async {
    final cam = await _map.getCameraState();
    final p = fromMapbox(cam.center);
    final addr = await geoApi.reverse(p);   // GET /geo/reverse?lat=&lng=  (backend)
    setState(() { _picked = p; _addressText = addr; });
  });
}
```

Rules:
- Debounce and call only on idle — every reverse-geocode is a billed backend call.
- Let the user **edit the address text** (house number, landmark). In Attock, text like "near Jamia Masjid, 2nd gate" is more useful to a rider than any geocoder output.
- Search box → `GET /geo/search?q=&proximity_lat=&proximity_lng=` (backend adds `country=pk` and district bias). On select, `flyTo` the result and let the pin settle.

---

## 9. Markers & live tracking

### 9.1 Point annotations (rider, pickup, drop)

```dart
late PointAnnotationManager _points;
PointAnnotation? _riderMarker;

Future<void> _initMarkers(MapboxMap map) async {
  _points = await map.annotations.createPointAnnotationManager();   // create ONCE per map

  final riderPng = (await rootBundle.load('assets/map/rider.png')).buffer.asUint8List();
  _riderMarker = await _points.create(PointAnnotationOptions(
    geometry: toMapbox(riderStart),
    image: riderPng,
    iconSize: 1.0,
  ));
}
```

Notes:
- There is **no default marker image** — ship your own PNGs (`rider`, `pickup`, `drop`, `merchant`) in `assets/map/` and declare them in `pubspec.yaml`.
- Create the manager once; **update** annotations, don't delete/recreate.
- Circle / polyline / polygon managers exist too (no image needed): `createCircleAnnotationManager`, `createPolylineAnnotationManager`, `createPolygonAnnotationManager`.

Tap handling (pattern from the Mapbox example app):

```dart
class MarkerTapListener extends OnPointAnnotationClickListener {
  final void Function(PointAnnotation) onTap;
  MarkerTapListener(this.onTap);
  @override
  void onPointAnnotationClick(PointAnnotation a) => onTap(a);
}
_points.addOnPointAnnotationClickListener(MarkerTapListener((a) { /* open merchant sheet */ }));
```

### 9.2 Moving the rider marker from WebSocket pings

Backend sends a position every 5–10 s (SRS). Jumping the marker looks bad; interpolate:

```dart
Future<void> moveRider(GeoPoint next) async {
  final from = _lastRider;                      // GeoPoint
  const steps = 20, total = Duration(milliseconds: 1500);
  for (var i = 1; i <= steps; i++) {
    final t = i / steps;
    final cur = GeoPoint(from.lat + (next.lat - from.lat) * t,
                         from.lng + (next.lng - from.lng) * t);
    _riderMarker!.geometry = toMapbox(cur);
    await _points.update(_riderMarker!);
    await Future.delayed(total ~/ steps);
  }
  _lastRider = next;
}
```

Drop stale pings (`ts` older than the last applied one) and cancel an in-flight animation when a new ping arrives. Optionally rotate the icon using `heading` from the payload (`iconRotate`).

### 9.3 Route line (GeoJSON source + LineLayer)

Backend returns the route as a **GeoJSON LineString** (see backend doc) so no polyline decoding is needed here.

```dart
Future<void> drawRoute(MapboxMap map, String lineStringGeoJson) async {
  const srcId = 'route-src', layerId = 'route-layer';
  final exists = await map.style.styleSourceExists(srcId);
  if (exists) {
    final src = await map.style.getSource(srcId) as GeoJsonSource;
    src.updateGeoJSON(lineStringGeoJson);                 // update in place on reroute
    return;
  }
  await map.style.addSource(GeoJsonSource(id: srcId, data: lineStringGeoJson));
  await map.style.addLayer(LineLayer(
    id: layerId,
    sourceId: srcId,
    lineColor: const Color(0xFF1B7F5C).value,
    lineWidth: 5.0,
    lineCap: LineCap.ROUND,
    lineJoin: LineJoin.ROUND,
    slot: 'middle',          // Standard style only; omit for Streets
  ));
}
```

Remember: switching style removes this — re-run `drawRoute` after style load.

### 9.4 Many merchants on the map (not annotations)

Put merchants into one GeoJSON `FeatureCollection` source and render with a `CircleLayer` / `SymbolLayer`. Taps via the Interactions API (Mapbox docs: *User Interaction → Interactions API*). Don't create 200 `PointAnnotation`s.

---

## 10. User location + Rider GPS

### 10.1 Location puck (blue dot)

```dart
if ((await Permission.locationWhenInUse.request()).isGranted) {
  await map.location.updateSettings(LocationComponentSettings(
    enabled: true,
    pulsingEnabled: true,
  ));
}
```

The puck is **display only**. To get coordinates in Dart (recenter button, rider streaming), use `geolocator`:

```dart
final pos = await Geolocator.getCurrentPosition();
map.flyTo(CameraOptions(center: toMapbox(GeoPoint(pos.latitude, pos.longitude)), zoom: 16),
          MapAnimationOptions(duration: 800));
```

### 10.2 Rider app: streaming location while a task is active

```dart
final stream = Geolocator.getPositionStream(
  locationSettings: AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,                        // meters
    intervalDuration: const Duration(seconds: 5),
    foregroundNotificationConfig: const ForegroundNotificationConfig(
      notificationTitle: 'GharTak delivery active',
      notificationText: 'Sharing your location with the customer',
      enableWakeLock: true,
    ),
  ),
);
// Push to WS `/ws/location/{order_id}` ~every 5–10 s:
// { "lat":..., "lng":..., "heading":..., "speed":..., "ts": <unix ms> }
```

Rules: stream **only while a task is active** (SRS FR-R06); stop on `delivered`/`cancelled`; if the socket drops, buffer the latest point only and resend on reconnect (SRS offline-resilience). Android also needs the foreground-service/location declarations required by the `geolocator` docs for your target SDK.

---

## 11. Rider navigation (what's realistic)

1. Show pickup → drop route line (§9.3) using the geometry from the backend.
2. "Navigate" button → hand off to Google Maps:

```dart
final uri = Uri.parse('google.navigation:q=${p.lat},${p.lng}&mode=d');
await launchUrl(uri, mode: LaunchMode.externalApplication);
```

Add the `<queries>` entry for the `google.navigation` intent on Android 11+ if `canLaunchUrl` returns false. iOS: use `comgooglemaps://?daddr=lat,lng&directionsmode=driving` or Apple Maps fallback.

---

## 12. Offline & poor network

The SDK supports offline tile packs (see Mapbox example *Offline Map*: `OfflineManager`/`TileStore`). Candidate use: pre-download tiles for Attock City + Hasan Abdal for riders. Before building it, check the Mapbox pricing page for offline tile-pack terms and measure pack size for our zones. Cheaper first step: keep cameras bounded (§7.1) and avoid reloading the style repeatedly.

---

## 13. Performance & cost checklist

- [ ] One `MapWidget` per screen, stable `key`; don't rebuild it on every `setState` (wrap in its own `StatefulWidget`/`const` subtree).
- [ ] Create annotation managers once; update objects, don't recreate.
- [ ] Reverse-geocode only on map **idle**, debounced (≥ 400 ms).
- [ ] No Directions call from the app — use backend `quote`/`route` (cached).
- [ ] Throttle marker updates to backend interval; interpolate visually.
- [ ] Test on a low-end Android with Standard vs Streets.
- [ ] Watch Mapbox dashboard usage weekly in the first month; set a billing alert.
- [ ] Don't enable 3D/terrain/globe unless there's a product reason.

---

## 14. Screen → feature map

| Screen | App | Uses |
|---|---|---|
| Home / merchants near me | Customer | Zone-centered map (optional), GeoJSON merchant layer, puck |
| Address picker | Customer | §8 center-pin + `/geo/reverse` + `/geo/search` |
| Checkout / quote | Customer | `/orders/quote` → fee, ETA, route preview (§9.3, §7.2) |
| Live tracking | Customer | WS location → §9.2 marker, route line, fit camera |
| Task offer | Rider | Pickup/drop markers + distance from quote payload |
| Active task | Rider | Route line, puck, GPS stream (§10.2), Google Maps handoff (§11) |
| Errand pickup/drop | Customer | Two pickers (§8) + quote |

---

## 15. Testing

- Unit-test `toMapbox` / `fromMapbox` (lng/lat order regression).
- Keep Mapbox calls inside `map_controller.dart` behind an interface so widget tests can fake it.
- Manual: airplane-mode mid-tracking, deny location permission, background the rider app for 5 min, switch style with a route on screen.
