import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/gh_avatar.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_earnings.dart';
import 'package:attock_xpress/features/rider_dashboard/presentation/widgets/earnings_chart.dart';
import 'package:flutter/material.dart';

/// Earnings ranges, a breakdown, and a JazzCash cash-out preview.
class RiderEarningsScreen extends StatefulWidget {
  /// Creates the earnings tab.
  const new({required this.displayName, super.key});

  /// Rider name.
  final String displayName;

  @override
  State<RiderEarningsScreen> createState() => _RiderEarningsScreenState();
}

class _RiderEarningsScreenState extends State<RiderEarningsScreen> {
  EarningsPeriod _period = const WeekEarnings();
  var _sent = false;

  @override
  Widget build(BuildContext context) {
    final report = earningsReport(_period);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        _Header(name: widget.displayName),
        const SizedBox(height: 16),
        _Periods(
          period: _period,
          onSelect: (period) => setState(() => _period = period),
        ),
        const SizedBox(height: 20),
        Text(report.eyebrow, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              rupees(report.total),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(width: 8),
            _Change(label: report.change),
          ],
        ),
        Text(report.summary, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 20),
        _ChartCard(report: report),
        const SizedBox(height: 12),
        _Cashout(
          total: report.total,
          sent: _sent,
          onWithdraw: () => setState(() => _sent = true),
        ),
        const SizedBox(height: 24),
        Text('Recent tasks', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final trip in report.trips) _TripRow(trip: trip),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const new({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Earnings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        GhAvatar(name: name, online: true),
      ],
    );
  }
}

class _Periods extends StatelessWidget {
  const new({required this.period, required this.onSelect});

  final EarningsPeriod period;
  final ValueChanged<EarningsPeriod> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(
          label: 'Today',
          selected: period is TodayEarnings,
          onTap: () => onSelect(const TodayEarnings()),
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'This week',
          selected: period is WeekEarnings,
          onTap: () => onSelect(const WeekEarnings()),
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'This month',
          selected: period is MonthEarnings,
          onTap: () => onSelect(const MonthEarnings()),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
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
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

class _Change extends StatelessWidget {
  const new({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.success,
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const new({required this.report});

  final EarningsReport report;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(GhIcons.circle, size: 8, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(child: Text('Daily breakdown')),
              Text(
                report.peakLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          EarningsChart(bars: report.bars),
        ],
      ),
    );
  }
}

class _Cashout extends StatelessWidget {
  const new({
    required this.total,
    required this.sent,
    required this.onWithdraw,
  });

  final int total;
  final bool sent;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available for instant cashout',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(rupees(total), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GhButton(
            label: sent ? 'Requested' : 'Withdraw to JazzCash',
            secondary: sent,
            onPressed: sent ? null : onWithdraw,
          ),
        ],
      ),
    );
  }
}

class _TripRow extends StatelessWidget {
  const new({required this.trip});

  final PastTrip trip;

  @override
  Widget build(BuildContext context) {
    final icon = trip.food ? GhIcons.storefront : GhIcons.package;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _Panel(
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.title),
                  Text(
                    trip.detail,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              rupees(trip.payoutRupees),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
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
