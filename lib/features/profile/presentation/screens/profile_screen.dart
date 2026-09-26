import 'package:attock_xpress/core/widgets/async_value_view.dart';
import 'package:attock_xpress/features/profile/domain/entities/user_profile.dart';
import 'package:attock_xpress/features/profile/presentation/providers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Profile, wallet entry, and logout. Logout is owned by the caller.
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
    required this.onOpenWallet,
    required this.onLogout,
  });

  final UserProfile profile;
  final VoidCallback onOpenWallet;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(profile.displayName),
          subtitle: Text(profile.phone),
        ),
        ListTile(
          title: const Text('Wallet and payments'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onOpenWallet,
        ),
        ListTile(title: const Text('Log out'), onTap: onLogout),
      ],
    );
  }
}
