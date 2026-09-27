import 'dart:ui';

import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Warm route drawing so tracking reads clearly before a Maps key is set.
class CustomerRouteSketch extends StatelessWidget {
  /// Creates the sketch.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _Painter(dark: dark),
      child: const SizedBox.expand(),
    );
  }
}

class _Painter extends CustomPainter {
  const new({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paper = dark ? AppColors.darkBackground : const Color(0xFFF6F1EB);
    canvas.drawRect(Offset.zero & size, Paint()..color = paper);
    final street = Paint()
      ..color = dark ? AppColors.darkLine : const Color(0xFFE7DDD4)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), street);
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), street);
    }
    final route = Path()
      ..moveTo(size.width * 0.3, size.height * 0.62)
      ..lineTo(size.width * 0.3, size.height * 0.38)
      ..lineTo(size.width * 0.62, size.height * 0.38);
    final paint = Paint()
      ..color = dark ? AppColors.darkPrimary : AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (final metric in route.computeMetrics()) {
      _dash(canvas, metric, paint);
    }
    _pin(canvas, Offset(size.width * 0.3, size.height * 0.62), true);
    _pin(canvas, Offset(size.width * 0.62, size.height * 0.38), false);
  }

  void _dash(Canvas canvas, PathMetric metric, Paint paint) {
    var distance = 0.0;
    while (distance < metric.length) {
      final next = distance + 8;
      canvas.drawPath(metric.extractPath(distance, next), paint);
      distance = next + 6;
    }
  }

  void _pin(Canvas canvas, Offset at, bool rider) {
    final color = rider ? AppColors.primary : AppColors.text;
    canvas
      ..drawCircle(at, 16, Paint()..color = AppColors.surface)
      ..drawCircle(at, 10, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_Painter oldDelegate) => oldDelegate.dark != dark;
}
