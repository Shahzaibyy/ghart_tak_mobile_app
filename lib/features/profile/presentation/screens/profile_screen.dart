import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/theme/theme_controller.dart';
import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/core/widgets/gh_avatar.dart';
import 'package:attock_xpress/features/profile/domain/entities/user_profile.dart';
import 'package:attock_xpress/features/profile/presentation/providers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Profile, wallet entry, theme, and logout.
class ProfileScreen extends ConsumerWidget {
  /// Creates the profile screen.
  const new({
    required this.onOpenWallet,
    required this.onLogout,
    super.key,
  });

  /// Opens the payments screen.
  final VoidCallback onOpenWallet;

  /// Ends the session.
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: AsyncValueView<UserProfile>(
        value: profile,
        onRetry: () => ref.invalidate(profileControllerProvider),
        data: (value) => _ProfileBody(
          profile: value,
          mode: ref.watch(themeControllerProvider),
          onTheme: (mode) {
            ref.read(themeControllerProvider.notifier).use(mode);
          },
          onOpenWallet: onOpenWallet,
          onLogout: onLogout,
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const new({
    required this.profile,
    required this.mode,
    required this.onTheme,
    required this.onOpenWallet,
    required this.onLogout,
  });

  final UserProfile profile;
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onTheme;
  final VoidCallback onOpenWallet;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            GhAvatar(name: profile.displayName, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    profile.phone,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _ThemeRow(mode: mode, onTheme: onTheme),
        const SizedBox(height: 20),
        _Row(
          icon: GhIcons.wallet,
          label: 'Wallet and payments',
          onTap: onOpenWallet,
        ),
        _Row(
          icon: GhIcons.signOut,
          label: 'Log out',
          onTap: onLogout,
        ),
      ],
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const new({required this.mode, required this.onTheme});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ThemeChip(
          label: 'Light',
          selected: mode == ThemeMode.light,
          onTap: () => onTheme(ThemeMode.light),
        ),
        const SizedBox(width: 8),
        _ThemeChip(
          label: 'Dark',
          selected: mode == ThemeMode.dark,
          onTap: () => onTheme(ThemeMode.dark),
        ),
        const SizedBox(width: 8),
        _ThemeChip(
          label: 'System',
          selected: mode == ThemeMode.system,
          onTap: () => onTheme(ThemeMode.system),
        ),
      ],
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = selected
        ? (dark ? AppColors.darkPrimary : AppColors.primary)
        : (dark ? AppColors.darkSurface : AppColors.surface);
    final foreground = selected
        ? (dark ? AppColors.darkBackground : AppColors.surface)
        : (dark ? AppColors.darkText : AppColors.text);
    final line = selected
        ? Colors.transparent
        : (dark ? AppColors.darkLine : AppColors.line);
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(color: line),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const new({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: muted),
      title: Text(label),
      trailing: Icon(GhIcons.caretRight, color: muted),
      onTap: onTap,
    );
  }
}
