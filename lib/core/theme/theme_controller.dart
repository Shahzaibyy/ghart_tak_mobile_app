import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

/// Light, dark, or follow the device.
@riverpod
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() => ThemeMode.system;

  /// Selects [mode] for the whole app.
  void use(ThemeMode mode) {
    if (state == mode) return;
    state = mode;
  }
}
