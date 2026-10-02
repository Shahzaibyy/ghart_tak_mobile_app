import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';
import 'package:attock_xpress/features/map/data/geo_api.dart';

/// Offline stand-in for `/geo/reverse` and `/geo/search` while the backend is offline.
class SampleGeoApi implements GeoApi {
  /// Creates the sample geo client.
  const new();

  static const _places = <PlaceSuggestion>[
    PlaceSuggestion(
      label: 'Shop 12, Mall Road, Attock City',
      point: MapConstants.samplePickup,
    ),
    PlaceSuggestion(
      label: 'House 18, Street 4, Peoples Colony',
      point: MapConstants.sampleDrop,
    ),
    PlaceSuggestion(
      label: 'Near Jamia Masjid, 2nd gate, Attock City',
      point: MapConstants.attockCenter,
    ),
    PlaceSuggestion(
      label: 'Hasan Abdal GT Road',
      point: GeoPoint(lat: 33.8195, lng: 72.6890),
    ),
  ];

  @override
  Future<String> reverse(GeoPoint point) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    PlaceSuggestion? best;
    var bestDist = double.infinity;
    for (final place in _places) {
      final d = _approxKm(point, place.point);
      if (d < bestDist) {
        bestDist = d;
        best = place;
      }
    }
    if (best == null || bestDist > 2.5) {
      return 'Near ${point.lat.toStringAsFixed(4)}, '
          '${point.lng.toStringAsFixed(4)} · Attock';
    }
    return best.label;
  }

  @override
  Future<List<PlaceSuggestion>> search(
    String query, {
    required GeoPoint proximity,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final hits = _places
        .where((p) => p.label.toLowerCase().contains(q))
        .toList(growable: false);
    if (hits.isNotEmpty) return hits;
    return [
      PlaceSuggestion(
        label: '$query · Attock District',
        point: proximity,
      ),
    ];
  }

  double _approxKm(GeoPoint a, GeoPoint b) {
    final dLat = a.lat - b.lat;
    final dLng = a.lng - b.lng;
    return (dLat * dLat + dLng * dLng) * 111 * 111;
  }
}
