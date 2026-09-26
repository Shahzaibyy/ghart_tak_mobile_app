import 'dart:async';

import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/storage/storage_providers.dart';
import 'package:attock_xpress/features/tracking/data/datasources/location_socket.dart';
import 'package:attock_xpress/features/tracking/data/geocode_lookup.dart';
import 'package:attock_xpress/features/tracking/data/repositories/tracking_repository_impl.dart';
import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:attock_xpress/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tracking_providers.g.dart';

/// Live-location socket.
@Riverpod(keepAlive: true)
LocationSocket locationSocket(Ref ref) {
  final socket = LocationSocket(baseUri: Uri.parse(AppConfig.wsBaseUrl));
  ref.onDispose(() => unawaited(socket.close()));
  return socket;
}

/// Tracking repository.
@Riverpod(keepAlive: true)
TrackingRepository trackingRepository(Ref ref) {
  return TrackingRepositoryImpl(ref.watch(locationSocketProvider));
}

/// Local geocode cache used before any Maps geocode request.
@Riverpod(keepAlive: true)
GeocodeLookup geocodeLookup(Ref ref) {
  return GeocodeLookup(ref.watch(geocodeCacheProvider));
}

/// Rider position stream for [orderId].
@riverpod
Stream<RiderLocation> riderLocation(Ref ref, String orderId) {
  return ref.watch(trackingRepositoryProvider).watch(orderId);
}
