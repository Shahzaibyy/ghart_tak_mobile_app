import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';

/// Sample Attock pickup → drop path for offline map previews.
abstract final class SampleRoute {
  /// GeoJSON Feature with a LineString (coordinates are lng, lat).
  static const lineStringGeoJson = '''
{
  "type": "Feature",
  "properties": {},
  "geometry": {
    "type": "LineString",
    "coordinates": [
      [72.3650, 33.7680],
      [72.3625, 33.7670],
      [72.3607, 33.7665],
      [72.3580, 33.7645],
      [72.3550, 33.7620]
    ]
  }
}
''';

  /// Intermediate fixes a sample rider stream walks along.
  static const path = <GeoPoint>[
    MapConstants.samplePickup,
    GeoPoint(lat: 33.7670, lng: 72.3625),
    MapConstants.attockCenter,
    GeoPoint(lat: 33.7645, lng: 72.3580),
    MapConstants.sampleDrop,
  ];
}
