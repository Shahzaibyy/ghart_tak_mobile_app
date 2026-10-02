import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/mapbox_codec.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  test('toMapbox / fromMapbox preserve lat/lng (lng first in Position)', () {
    const original = GeoPoint(lat: 33.7665, lng: 72.3607);
    final point = toMapbox(original);

    expect(point.coordinates.lng, 72.3607);
    expect(point.coordinates.lat, 33.7665);

    final roundTrip = fromMapbox(point);
    expect(roundTrip.lat, original.lat);
    expect(roundTrip.lng, original.lng);
  });

  test('Position constructor order is longitude then latitude', () {
    final position = Position(72.36, 33.76);
    expect(position.lng, 72.36);
    expect(position.lat, 33.76);
  });
}
