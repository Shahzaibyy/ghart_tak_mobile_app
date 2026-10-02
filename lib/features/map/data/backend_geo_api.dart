import 'package:attock_xpress/core/network/api_envelope.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/map/data/geo_api.dart';
import 'package:attock_xpress/features/map/data/sample_geo_api.dart';
import 'package:dio/dio.dart';

/// `GET /geo/search` + `/geo/reverse` against the backend.
///
/// Falls back to [SampleGeoApi] when Mapbox is unavailable on the server
/// (`error.code == unavailable`).
class BackendGeoApi implements GeoApi {
  /// Creates the geo client.
  const new(this._dio, {GeoApi fallback = const SampleGeoApi()})
    : _fallback = fallback;

  final Dio _dio;
  final GeoApi _fallback;

  @override
  Future<String> reverse(GeoPoint point) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/geo/reverse',
        queryParameters: {'lat': point.lat, 'lng': point.lng},
      );
      final data = unwrapData<Map<String, dynamic>>(response);
      final label = data['label'] ?? data['place'];
      if (label is String && label.isNotEmpty) return label;
      return await _fallback.reverse(point);
    } on DioException catch (error) {
      if (_unavailable(error)) return await _fallback.reverse(point);
      rethrow;
    }
  }

  @override
  Future<List<PlaceSuggestion>> search(
    String query, {
    required GeoPoint proximity,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/geo/search',
        queryParameters: {
          'q': query,
          'near_lat': proximity.lat,
          'near_lng': proximity.lng,
          'limit': 5,
        },
      );
      final data = unwrapData<Object?>(response);
      final rows = switch (data) {
        final List<dynamic> list => list,
        final Map<String, dynamic> map when map['places'] is List =>
          List<dynamic>.from(map['places']! as List),
        _ => const <dynamic>[],
      };
      final hits = <PlaceSuggestion>[];
      for (final row in rows) {
        if (row is! Map) continue;
        final label = row['label'] ?? row['place'];
        final lat = row['lat'];
        final lng = row['lng'];
        if (label is! String || lat is! num || lng is! num) continue;
        hits.add(
          PlaceSuggestion(
            label: label,
            point: GeoPoint(lat: lat.toDouble(), lng: lng.toDouble()),
          ),
        );
      }
      if (hits.isEmpty) {
        return await _fallback.search(query, proximity: proximity);
      }
      return hits;
    } on DioException catch (error) {
      if (_unavailable(error)) {
        return await _fallback.search(query, proximity: proximity);
      }
      rethrow;
    }
  }

  bool _unavailable(DioException error) {
    final api = readApiError(error);
    return api?.code == 'unavailable' ||
        error.response?.statusCode == 503 ||
        error.response?.statusCode == 502;
  }
}
