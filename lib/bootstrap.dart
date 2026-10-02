import 'package:attock_xpress/app.dart';
import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/storage/hive_boxes.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Initializes local storage, then starts the widget tree.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Mapbox Maps SDK has no Linux desktop implementation — skip token init.
  if (AppConfig.canUseMapbox) {
    MapboxOptions.setAccessToken(AppConfig.mapboxAccessToken);
  }
  await Hive.initFlutter();
  await Hive.openBox<String>(HiveBoxes.pendingActions);
  await Hive.openBox<String>(HiveBoxes.geocode);
  runApp(const ProviderScope(child: BhookLagiApp()));
}
