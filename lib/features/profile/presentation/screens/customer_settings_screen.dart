import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Customer settings (notifications, spice, appearance) from v2 HTML.
class CustomerSettingsScreen extends StatelessWidget {
  /// Creates settings.
  const new({
    required this.mode,
    required this.onTheme,
    super.key,
  });

  /// Current theme mode.
  final ThemeMode mode;

  /// Applies a theme.
  final ValueChanged<ThemeMode> onTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Row(
              children: [
                _Back(onTap: () => Navigator.of(context).pop()),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Apni marzi, apne rules',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Notifications: sirf kaam ki baatein',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const _ToggleBox(
              rows: [
                (GhIcons.bell, 'Order updates', 'Rider ka haal, WhatsApp pe bhi', true),
                (GhIcons.gift, 'Offers and deals', 'Sasti deals, par zyada nahi', false),
                (GhIcons.moon, 'Quiet hours', 'Raat 11 se subah 8 tak chup', true),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Khaane ki pasand',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _Box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spice level', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  const _Seg(labels: ['Halka', 'Medium', 'Teekha'], selected: 2),
                  const SizedBox(height: 12),
                  Text(
                    'Default tip for rider',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  const _Seg(
                    labels: ['Rs 0', 'Rs 20', 'Rs 50', 'Rs 100'],
                    selected: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'App ka mizaj',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _Box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Appearance', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  _ThemeSeg(mode: mode, onTheme: onTheme),
                  const SizedBox(height: 12),
                  Text('Language', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  const _Seg(
                    labels: ['English', 'Roman Urdu', 'اردو'],
                    selected: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bhook Lagi v1.0. Attock ke liye, Attock walon ne banaya.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Back extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? AppColors.darkSurface : AppColors.surface,
      shape: CircleBorder(
        side: BorderSide(color: dark ? AppColors.darkLine : AppColors.line),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(GhIcons.caretLeft, size: 20),
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
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: i == selected
                            ? null
                            : AppColors.textMuted,
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

class _ThemeSeg extends StatelessWidget {
  const new({required this.mode, required this.onTheme});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onTheme;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
    final labels = ['Light', 'Dark', 'System'];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkLine : AppColors.line,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            for (var i = 0; i < modes.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onTheme(modes[i]),
                  borderRadius: BorderRadius.circular(9),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: mode == modes[i]
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
