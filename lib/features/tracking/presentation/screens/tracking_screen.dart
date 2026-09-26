import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:attock_xpress/features/tracking/presentation/providers/tracking_providers.dart';
import 'package:attock_xpress/features/tracking/presentation/widgets/rider_marker_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live rider map for one order.
class TrackingScreen extends ConsumerWidget {
  /// Creates the tracking screen for [orderId].
  const new({required this.orderId, super.key});

  /// Order whose rider is being followed.
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(riderLocationProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: const Text('Live tracking')),
      body: AsyncValueView<RiderLocation>(
        value: location,
        onRetry: () => ref.invalidate(riderLocationProvider(orderId)),
        data: (fix) => RiderMarkerMap(location: fix),
      ),
    );
  }
}
