import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Quiet ring while the rider waits for a task.
class WaitingPulse extends StatefulWidget {
  /// Creates the pulse.
  const new({super.key});

  @override
  State<WaitingPulse> createState() => _WaitingPulseState();
}

class _WaitingPulseState extends State<WaitingPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = dark ? AppColors.darkPrimary : AppColors.primary;
    return SizedBox(
      width: 92,
      height: 92,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _RingPainter(t: _controller.value, color: color),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const new({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final base = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 28, base);
    final wave = Paint()
      ..color = color.withValues(alpha: 0.18 * (1 - t))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 28 + (18 * t), wave);
    final dot = Paint()..color = color;
    canvas.drawCircle(center, 8, dot);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.t != t;
}
