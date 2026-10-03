import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/theme/theme_controller.dart';
import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/core/widgets/gh_avatar.dart';
import 'package:attock_xpress/features/profile/domain/entities/user_profile.dart';
import 'package:attock_xpress/features/profile/presentation/providers/profile_controller.dart';
import 'package:attock_xpress/features/profile/presentation/screens/customer_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Profile hub matching v2 (stats, menu rows, refer card, logout).
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
      body: SafeArea(
        child: AsyncValueView<UserProfile>(
          value: profile,
          onRetry: () => ref.invalidate(profileControllerProvider),
          data: (value) => _ProfileBody(
            profile: value,
            onOpenWallet: onOpenWallet,
            onLogout: onLogout,
            onOpenSettings: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CustomerSettingsScreen(
                    mode: ref.read(themeControllerProvider),
                    onTheme: (mode) {
                      ref.read(themeControllerProvider.notifier).use(mode);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const new({
    required this.profile,
    required this.onOpenWallet,
    required this.onLogout,
    required this.onOpenSettings,
  });

  final UserProfile profile;
  final VoidCallback onOpenWallet;
  final VoidCallback onLogout;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
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
            OutlinedButton(
              onPressed: () {},
              child: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: _Stat(value: '12', label: 'Orders')),
            SizedBox(width: 8),
            Expanded(child: _Stat(value: 'Rs 480', label: 'Saved')),
            SizedBox(width: 8),
            Expanded(child: _Stat(value: '3', label: 'Vouchers')),
          ],
        ),
        const SizedBox(height: 16),
        _MenuBox(
          children: [
            _MenuRow(
              icon: GhIcons.user,
              title: 'Personal info',
              onTap: () {},
            ),
            _MenuRow(
              icon: GhIcons.gear,
              title: 'Settings',
              subtitle: 'Notifications, language, spice level',
              onTap: onOpenSettings,
            ),
            _MenuRow(
              icon: GhIcons.mapPin,
              title: 'Saved addresses',
              subtitle: 'Home, Office',
              onTap: () {},
            ),
            _MenuRow(
              icon: GhIcons.wallet,
              title: 'Wallet and payments',
              onTap: onOpenWallet,
            ),
            _MenuRow(
              icon: GhIcons.tag,
              title: 'Vouchers and offers',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.tint,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refer and earn Rs 100',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Invite a friend. You both get Rs 100 off.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Invite friends'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _MenuBox(
          children: [
            _MenuRow(
              icon: GhIcons.chatCircle,
              title: 'Chat on WhatsApp',
              subtitle: 'Help in minutes',
              onTap: () {},
            ),
            _MenuRow(
              icon: GhIcons.fileText,
              title: 'Terms and privacy',
              onTap: () {},
            ),
            _MenuRow(
              icon: GhIcons.signOut,
              title: 'Log out',
              onTap: onLogout,
              showChevron: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Bhook Lagi v1.0',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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

class _MenuBox extends StatelessWidget {
  const new({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: dark ? AppColors.darkLine : AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(children: children),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: showChevron
          ? const Icon(GhIcons.caretRight, size: 18)
          : null,
    );
  }
}
