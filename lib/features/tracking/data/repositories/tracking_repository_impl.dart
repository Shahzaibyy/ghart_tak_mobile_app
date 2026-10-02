import 'dart:async';

import 'package:attock_xpress/features/tracking/data/datasources/location_socket.dart';
import 'package:attock_xpress/features/tracking/data/sample_tracking.dart';
import 'package:attock_xpress/features/tracking/domain/entities/rider_location.dart';
import 'package:attock_xpress/features/tracking/domain/repositories/tracking_repository.dart';

/// Prefers the live WS feed; falls back to the sample path when no rider is on
/// the order (common in demos without a seeded rider).
class TrackingRepositoryImpl implements TrackingRepository {
  /// Creates the repository.
  const new({
    required LocationSocket socket,
    this.fallback = const SampleTrackingRepository(),
    this.fallbackAfter = const Duration(seconds: 4),
  }) : _socket = socket;

  final LocationSocket _socket;
  final TrackingRepository fallback;
  final Duration fallbackAfter;

  @override
  Stream<RiderLocation> watch(String orderId) {
    final controller = StreamController<RiderLocation>();
    StreamSubscription<RiderLocation>? liveSub;
    StreamSubscription<RiderLocation>? sampleSub;
    var gotLive = false;
    Timer? timer;

    void startFallback() {
      if (gotLive || sampleSub != null || controller.isClosed) return;
      sampleSub = fallback.watch(orderId).listen(
        controller.add,
        onError: controller.addError,
        onDone: () {
          if (!gotLive) unawaited(controller.close());
        },
      );
    }

    timer = Timer(fallbackAfter, startFallback);

    liveSub = _socket.watch(orderId).listen(
      (fix) {
        gotLive = true;
        timer?.cancel();
        unawaited(sampleSub?.cancel());
        sampleSub = null;
        controller.add(fix);
      },
      onError: (_) {
        // No rider / WS rejected — use the sample path for UI demos.
        startFallback();
      },
      onDone: () {
        if (!gotLive) startFallback();
      },
    );

    controller.onCancel = () async {
      timer?.cancel();
      await liveSub?.cancel();
      await sampleSub?.cancel();
    };

    return controller.stream;
  }
}
