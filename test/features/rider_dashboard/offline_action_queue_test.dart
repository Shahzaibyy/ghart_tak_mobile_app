import 'dart:io';

import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/storage/hive_boxes.dart';
import 'package:attock_xpress/features/rider_dashboard/data/offline_action_queue.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/queued_action.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('ghartak_hive');
    Hive.init(directory.path);
    await Hive.openBox<String>(HiveBoxes.pendingActions);
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('keeps a failed item and removes a later success', () async {
    final queue = OfflineActionQueue(
      box: Hive.box<String>(HiveBoxes.pendingActions),
      delay: (_) async {},
    );
    await queue.enqueue(const ToggleOnlineAction(isOnline: true));
    await queue.enqueue(const ToggleOnlineAction(isOnline: false));

    await queue.flush((action) async {
      if (action is ToggleOnlineAction && action.isOnline) {
        return const Err(NetworkFailure());
      }
      return const Success(nothing);
    });

    expect(await queue.pendingCount(), 1);
    final remaining = Hive.box<String>(HiveBoxes.pendingActions).values.single;
    final action = QueuedAction.decode(remaining);
    expect(action, isA<ToggleOnlineAction>());
    expect((action as ToggleOnlineAction).isOnline, isTrue);
  });
}
