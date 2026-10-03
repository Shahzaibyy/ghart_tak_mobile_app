import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/gh_avatar.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/screens/rider_settings_screen.dart';
import 'package:flutter/material.dart';

/// Rider profile matching v2 (rating KPIs, docs, payout, settings).
class RiderAccountScreen extends StatelessWidget {
  /// Creates the account tab.
  const new({required this.displayName, required this.onLogout, super.key});

  /// Rider's name.
  final String displayName;

  /// Ends the session.
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Row(
          children: [
            GhAvatar(name: displayName, online: true, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Rider · Fateh Jang',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  'Verified',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(child: _Kpi(value: '4.92', label: 'Rating')),
            SizedBox(width: 8),
            Expanded(child: _Kpi(value: '214', label: 'Orders')),
            SizedBox(width: 8),
            Expanded(child: _Kpi(value: '98%', label: 'On time')),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Vehicle and documents',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const _Box(
          child: Column(
            children: [
              _DocRow(
                icon: GhIcons.bicycle,
                title: 'Honda 125',
                subtitle: 'ATK 1234',
              ),
              _DocRow(
                icon: GhIcons.fileText,
                title: 'CNIC',
                tag: 'Verified',
                ok: true,
              ),
              _DocRow(
                icon: GhIcons.fileText,
                title: 'Driving licence',
                subtitle: 'Expires in 18 days',
                tag: 'Renew',
                ok: false,
              ),
              _DocRow(
                icon: GhIcons.fileText,
                title: 'Vehicle registration',
                tag: 'Verified',
                ok: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Payout', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const _Box(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(GhIcons.phone, color: AppColors.primary),
            title: Text('JazzCash'),
            subtitle: Text('0312 ••• 4821'),
            trailing: Text('Default', style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(height: 12),
        _Box(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(GhIcons.gear, color: AppColors.primary),
                title: const Text('Settings'),
                subtitle: const Text('Alerts, navigation, safety'),
                trailing: const Icon(GhIcons.caretRight, size: 18),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RiderSettingsScreen(),
                    ),
                  );
                },
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(GhIcons.chatCircle, color: AppColors.primary),
                title: Text('Rider support'),
                subtitle: Text('WhatsApp'),
                trailing: Icon(GhIcons.caretRight, size: 18),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(GhIcons.signOut, color: AppColors.primary),
                title: const Text('Log out'),
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const new({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dark ? AppColors.darkLine : AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
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

class _DocRow extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    this.subtitle,
    this.tag,
    this.ok = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? tag;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: tag == null
          ? const Icon(GhIcons.caretRight, size: 18)
          : DecoratedBox(
              decoration: BoxDecoration(
                color: ok
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(
                  tag!,
                  style: TextStyle(
                    color: ok ? AppColors.success : const Color(0xFF8A6A2E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
    );
  }
}
