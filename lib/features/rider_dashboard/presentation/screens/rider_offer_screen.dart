import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_task.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/widgets/countdown_ring.dart';
import 'package:flutter/material.dart';

/// Incoming request. [secondsLeft] is null once the offer has expired.
class RiderOfferScreen extends StatelessWidget {
  /// Creates the offer.
  const new({
    required this.task,
    required this.secondsLeft,
    required this.onDecline,
    required this.onAccept,
    super.key,
  });

  /// Task being offered.
  final RiderTask task;

  /// Seconds left, or null when expired.
  final int? secondsLeft;

  /// Declines and keeps looking.
  final VoidCallback onDecline;

  /// Accepts the trip.
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final expired = secondsLeft == null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Row(
          children: [
            const Icon(GhIcons.circle, size: 10, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'INCOMING REQUEST',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Text('Fateh Jang', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 20),
        Center(child: CountdownRing(seconds: secondsLeft ?? 0)),
        const SizedBox(height: 16),
        const Center(child: _KindChip()),
        const SizedBox(height: 20),
        _Payout(task: task),
        const SizedBox(height: 16),
        _Stop(
          icon: GhIcons.storefront,
          title: task.pickup,
          detail: task.pickupDetail,
          note: 'Order ready for pickup',
          trailing: '${task.pickupKm} km away',
        ),
        const SizedBox(height: 8),
        _Stop(
          icon: GhIcons.mapPin,
          title: task.dropoff,
          detail: task.dropoffDetail,
          note: 'Customer: ${task.customerName}',
          trailing: '${task.distanceKm} km trip',
        ),
        const SizedBox(height: 8),
        Text(
          task.prepaid ? 'Prepaid' : task.paymentLabel,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        _Facts(task: task),
        const SizedBox(height: 16),
        Text(
          expired
              ? 'Task offer expired. Looking for new rides...'
              : 'Respond before the ring closes.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: expired ? AppColors.primary : null,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GhButton(
                label: 'Decline',
                secondary: true,
                onPressed: onDecline,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GhButton(
                label: expired ? 'Expired' : 'Accept',
                onPressed: expired ? null : onAccept,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KindChip extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          'Food delivery',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.primaryPressed,
          ),
        ),
      ),
    );
  }
}

class _Payout extends StatelessWidget {
  const new({required this.task});

  final RiderTask task;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GUARANTEED PAYOUT',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  rupees(task.payoutRupees),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.success,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      GhIcons.lightning,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '+ ${rupees(task.bonusRupees)} peak bonus',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${task.distanceKm} km',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('Total trip', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stop extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.detail,
    required this.note,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String note;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                Text(detail, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(note, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(trailing, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  const new({required this.task});

  final RiderTask task;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Fact(icon: GhIcons.clock, label: 'Est. ${task.etaMinutes} mins'),
        _Fact(icon: GhIcons.shoppingBag, label: task.bag),
        _Fact(icon: GhIcons.wallet, label: task.paymentLabel),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const new({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
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
