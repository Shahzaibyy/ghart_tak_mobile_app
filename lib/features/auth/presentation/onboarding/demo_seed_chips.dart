import 'package:attock_xpress/core/config/demo_config.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/features/auth/domain/entities/app_role.dart';
import 'package:flutter/material.dart';

/// One-tap Fateh Jang seeded accounts for demo login (no SMS).
class DemoSeedChips extends StatelessWidget {
  /// Creates the chip row for [role].
  const new({
    required this.role,
    required this.onSelect,
    super.key,
  });

  final AppRole role;
  final ValueChanged<DemoAccount> onSelect;

  @override
  Widget build(BuildContext context) {
    final accounts = DemoConfig.accountsFor(role);
    final title = role is RiderRole
        ? 'Demo riders (tap to sign in)'
        : 'Demo customers (tap to sign in)';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(
          'Fateh Jang seed · no SMS · uses API dev_otp',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final account in accounts)
              ActionChip(
                avatar: CircleAvatar(
                  backgroundColor: AppColors.tint,
                  child: Text(
                    account.name.isEmpty ? '?' : account.name.substring(0, 1),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                label: Text(
                  '${account.name.split(' ').first} · ${account.phone}',
                ),
                onPressed: () => onSelect(account),
              ),
          ],
        ),
      ],
    );
  }
}
