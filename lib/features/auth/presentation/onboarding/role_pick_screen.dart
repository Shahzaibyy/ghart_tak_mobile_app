import 'dart:async';

import 'package:attock_xpress/core/widgets/brand_mark.dart';
import 'package:attock_xpress/features/auth/presentation/onboarding/onboarding_widgets.dart';
import 'package:attock_xpress/features/auth/presentation/providers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Customer vs rider picker.
class RolePickScreen extends ConsumerStatefulWidget {
  /// Creates the role pick screen.
  const new({super.key});

  @override
  ConsumerState<RolePickScreen> createState() => _RolePickScreenState();
}

class _RolePickScreenState extends ConsumerState<RolePickScreen> {
  OnboardingRole? _role;

  @override
  Widget build(BuildContext context) {
    final flow = ref.read(onboardingControllerProvider.notifier);
    return OnboardingScaffold(
      onBack: flow.back,
      onSkip: () => unawaited(flow.skipToHome()),
      children: [
        Text(
          'Chalo shuru karte hain',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ek choose karo. Baad mein dono bhi kar sakte ho.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        OnboardingTile(
          title: 'Mujhe kuch mangwana hai',
          subtitle: 'Khaana, grocery ya dasti',
          selected: _role == OnboardingRole.customer,
          leading: const BrandMark(kind: BrandMarkKind.customer),
          onTap: () {
            setState(() => _role = OnboardingRole.customer);
            flow.pickRole(OnboardingRole.customer);
          },
        ),
        const SizedBox(height: 12),
        OnboardingTile(
          title: 'Mujhe kamana hai',
          subtitle: 'Rider ban ke paisay kamao',
          selected: _role == OnboardingRole.rider,
          leading: const BrandMark(kind: BrandMarkKind.rider),
          onTap: () {
            setState(() => _role = OnboardingRole.rider);
            flow.pickRole(OnboardingRole.rider);
          },
        ),
        const SizedBox(height: 32),
        OnboardingActions(
          primaryLabel: 'Aage chalo',
          onPrimary: () {
            if (_role == null) {
              flow.pickRole(OnboardingRole.customer);
              setState(() => _role = OnboardingRole.customer);
            }
            flow.confirmRole();
          },
        ),
      ],
    );
  }
}
