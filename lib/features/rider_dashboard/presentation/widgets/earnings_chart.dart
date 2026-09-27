import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_earnings.dart';
import 'package:flutter/material.dart';

/// Rounded bars for a week or a day.
class EarningsChart extends StatelessWidget {
  /// Creates a chart for [bars].
  const new({required this.bars, super.key});

  /// Values to draw.
  final List<EarningBar> bars;

  @override
  Widget build(BuildContext context) {
    final peak = bars.fold<int>(0, (max, bar) {
      return bar.amount > max ? bar.amount : max;
    });
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final bar in bars)
            Expanded(
              child: _Bar(bar: bar, peak: peak == 0 ? 1 : peak),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const new({required this.bar, required this.peak});

  final EarningBar bar;
  final int peak;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tallest = bar.amount == peak;
    final color = tallest
        ? (dark ? AppColors.darkPrimary : AppColors.primary)
        : (dark ? AppColors.darkPeach : AppColors.peach);
    final height = 16 + (88 * bar.amount / peak);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Text(bar.label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
