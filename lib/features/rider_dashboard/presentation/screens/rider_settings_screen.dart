import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Rider settings from v2 HTML (sound, nav, SOS, battery).
class RiderSettingsScreen extends StatelessWidget {
  /// Creates rider settings.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(GhIcons.caretLeft),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Rider ki marzi',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Orders', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const _ToggleBox(
              rows: [
                (
                  GhIcons.speakerHigh,
                  'New request sound',
                  'Loud, taake traffic mein bhi sunai de',
                  true,
                ),
                (
                  GhIcons.bicycle,
                  'Auto-accept nearby',
                  'Pehle dekho, phir hamari hami',
                  false,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Navigation', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const _Box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Map app'),
                  SizedBox(height: 8),
                  _Seg(labels: ['In-app', 'Google Maps'], selected: 0),
                  SizedBox(height: 12),
                  Text('Map theme'),
                  SizedBox(height: 8),
                  _Seg(labels: ['Auto', 'Light', 'Dark'], selected: 0),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Safety', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const _ToggleBox(
              rows: [
                (
                  GhIcons.phone,
                  'Emergency contact',
                  '0300 ••• 1122',
                  true,
                ),
                (
                  GhIcons.siren,
                  'Shake to send SOS',
                  'Phone hilao, madad bulao',
                  true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Battery and data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const _ToggleBox(
              rows: [
                (
                  GhIcons.chartBar,
                  'Data saver',
                  'Kam internet use karo',
                  true,
                ),
                (
                  GhIcons.batteryCharging,
                  'Battery saver',
                  'Idle ho to location kam bhejo',
                  true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleBox extends StatelessWidget {
  const new({required this.rows});

  final List<(IconData, String, String, bool)> rows;

  @override
  Widget build(BuildContext context) {
    return _Box(
      child: Column(
        children: [
          for (final row in rows)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(row.$1, color: AppColors.primary),
              title: Text(row.$2),
              subtitle: Text(row.$3),
              value: row.$4,
              onChanged: (_) {},
            ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const new({required this.labels, required this.selected});

  final List<String> labels;
  final int selected;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkLine : AppColors.line,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: i == selected
                        ? (dark ? AppColors.darkSurface : AppColors.surface)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: dark ? AppColors.darkLine : AppColors.line),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}
