import 'dart:convert';

import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket wrapper for `GET /ws/location/{order_id}`.
///
/// Send `Authorization: Bearer` as required by the OpenAPI contract.
/// Widgets never open a [WebSocketChannel] themselves.
class LocationSocket {
  /// Creates a socket client for [baseUri].
  new({
    required Uri baseUri,
    Future<String?> Function()? readAccessToken,
    WebSocketChannel Function(Uri uri, {Map<String, dynamic>? headers})?
        connect,
  }) : _baseUri = baseUri,
       _readAccessToken = readAccessToken,
       _connect = connect ?? _defaultConnect;

  final Uri _baseUri;
  final Future<String?> Function()? _readAccessToken;
  final WebSocketChannel Function(Uri uri, {Map<String, dynamic>? headers})
  _connect;
  WebSocketChannel? _channel;

  /// Connects to the order room and maps frames to locations.
  Stream<RiderLocation> watch(String orderId) async* {
    final headers = <String, dynamic>{};
    final token = await _readAccessToken?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final channel = _connect(
      _baseUri.replace(path: '/ws/location/$orderId'),
      headers: headers.isEmpty ? null : headers,
    );
    _channel = channel;
    await for (final event in channel.stream) {
      yield _decode(event, orderId);
    }
  }

  /// Closes the current socket.
  Future<void> close() async {
    await _channel?.sink.close();
    _channel = null;
  }

  RiderLocation _decode(Object? event, String orderId) {
    final text = switch (event) {
      String() => event,
      _ => throw const FormatException('Expected a text location frame'),
    };
    final decoded = jsonDecode(text);
    if (decoded is! Map) {
      throw const FormatException('Expected a location object');
    }
    final json = Map<String, dynamic>.from(decoded);
    final lat = json['lat'];
    final lng = json['lng'];
    if (lat is! num || lng is! num) {
      throw const FormatException('Location is missing coordinates');
    }
    return RiderLocation(
      orderId: orderId,
      lat: lat.toDouble(),
      lng: lng.toDouble(),
    );
  }

  static WebSocketChannel _defaultConnect(
    Uri uri, {
    Map<String, dynamic>? headers,
  }) {
    if (headers == null || headers.isEmpty) {
      return IOWebSocketChannel.connect(uri);
    }
    return IOWebSocketChannel.connect(
      uri,
      headers: headers.map((k, v) => MapEntry(k, '$v')),
    );
  }
}
