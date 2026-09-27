import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Large seconds ring for an incoming offer.
class CountdownRing extends StatelessWidget {
  /// Creates a ring for [seconds].
  const new({required this.seconds, super.key});

  /// Seconds remaining.
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = dark ? AppColors.darkPrimary : AppColors.primary;
    final progress = (seconds / 30).clamp(0.0, 1.0);
    return SizedBox(
      width: 148,
      height: 148,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 148,
            height: 148,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: color.withValues(alpha: 0.12),
              color: seconds == 0 ? AppColors.textMuted : color,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$seconds',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text('SECONDS', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
