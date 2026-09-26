import 'dart:convert';

import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket wrapper. Widgets never open a [WebSocketChannel] themselves.
class LocationSocket {
  /// Creates a socket client for [_baseUri].
  new({
    required this._baseUri,
    WebSocketChannel Function(Uri uri)? connect,
  }) : _connect = connect ?? WebSocketChannel.connect;

  final Uri _baseUri;
  final WebSocketChannel Function(Uri uri) _connect;
  WebSocketChannel? _channel;

  /// Connects to the order room and maps frames to locations.
  Stream<RiderLocation> watch(String orderId) {
    final channel = _connect(
      _baseUri.replace(path: '/ws/location/$orderId'),
    );
    _channel = channel;
    return channel.stream.map((event) => _decode(event, orderId));
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
}
