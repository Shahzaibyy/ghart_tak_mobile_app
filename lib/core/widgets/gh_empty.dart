import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Quiet empty state. One monoline icon, no stock illustration.
class GhEmpty extends StatelessWidget {
  /// Creates an empty state.
  const new({required this.title, required this.body, super.key});

  /// Short title.
  final String title;

  /// Supporting line.
  final String body;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = dark ? AppColors.darkPrimary : AppColors.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GhDuotone(
              front: GhIcons.packageFront,
              back: GhIcons.packageBack,
              size: 42,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
