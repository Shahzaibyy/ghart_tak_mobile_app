import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/widgets/gh_avatar.dart';
import 'package:flutter/material.dart';

/// Rider identity and logout.
class RiderAccountScreen extends StatelessWidget {
  /// Creates the account tab.
  const new({required this.displayName, required this.onLogout, super.key});

  /// Rider's name.
  final String displayName;

  /// Ends the session.
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
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
                    'Rider · Attock',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(GhIcons.signOut, color: muted),
          title: const Text('Log out'),
          onTap: onLogout,
        ),
      ],
    );
  }
}
