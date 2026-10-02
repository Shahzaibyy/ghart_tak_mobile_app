import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';

/// Sample Fateh Jang pickup → drop path for offline map previews.
abstract final class SampleRoute {
  /// GeoJSON Feature with a LineString (coordinates are lng, lat).
  static const lineStringGeoJson = '''
{
  "type": "Feature",
  "properties": {},
  "geometry": {
    "type": "LineString",
    "coordinates": [
      [72.641856, 33.567565],
      [72.642400, 33.567900],
      [72.643000, 33.568200],
      [72.643400, 33.568400],
      [72.643000, 33.568500]
    ]
  }
}
''';

  /// Intermediate fixes a sample rider stream walks along.
  static const path = <GeoPoint>[
    MapConstants.samplePickup,
    GeoPoint(lat: 33.5679, lng: 72.6424),
    MapConstants.zoneCenter,
    GeoPoint(lat: 33.5684, lng: 72.6434),
    MapConstants.sampleDrop,
  ];

  /// Same path as [GeoPoint] list for desktop polylines.
  static List<GeoPoint> get points => path;
}
