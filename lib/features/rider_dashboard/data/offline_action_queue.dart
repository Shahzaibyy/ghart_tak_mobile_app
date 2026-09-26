import 'dart:convert';

import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/queued_action.dart';
import 'package:hive/hive.dart';

/// FIFO queue of rider actions, flushed one item at a time.
class OfflineActionQueue {
  /// Creates a queue over [_box].
  ///
  /// [delay] is the per-attempt backoff. Tests pass an instant delay.
  new({
    required this._box,
    Future<void> Function(int attempt)? delay,
    this.maxAttempts = 3,
  }) : _delay = delay ?? _backoff;

  final Box<String> _box;
  final Future<void> Function(int attempt) _delay;

  /// Attempts per item before it stays in the queue.
  final int maxAttempts;

  static Future<void> _backoff(int attempt) {
    return Future<void>.delayed(Duration(milliseconds: 200 * (1 << attempt)));
  }

  /// Appends [action].
  Future<void> enqueue(QueuedAction action) {
    return _box.add(jsonEncode(action.toJson()));
  }

  /// How many actions are still stored.
  Future<int> pendingCount() async => _box.length;

  /// Sends each item in order. A failure does not roll back earlier items.
  Future<void> flush(
    Future<Result<Nothing>> Function(QueuedAction action) send,
  ) async {
    final keys = _box.keys.toList();
    for (final key in keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      final delivered = await _deliver(QueuedAction.decode(raw), send);
      if (!delivered) continue;
      await _box.delete(key);
    }
  }

  Future<bool> _deliver(
    QueuedAction action,
    Future<Result<Nothing>> Function(QueuedAction action) send,
  ) async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final result = await send(action);
      if (result is Success<Nothing>) return true;
      await _delay(attempt);
    }
    return false;
  }
}
