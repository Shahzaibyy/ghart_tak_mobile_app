import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A quiet route drawing for the showcase, used until a Maps key is set.
class RouteSketch extends StatelessWidget {
  /// Creates the sketch. [toDropoff] draws the second leg.
  const new({required this.toDropoff, super.key});

  /// Whether the rider is already heading to the customer.
  final bool toDropoff;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _MapPainter(toDropoff: toDropoff, dark: dark),
      child: const SizedBox.expand(),
    );
  }
}

class _MapPainter extends CustomPainter {
  const new({required this.toDropoff, required this.dark});

  final bool toDropoff;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paper = dark ? AppColors.darkBackground : const Color(0xFFF3EDE6);
    canvas.drawRect(Offset.zero & size, Paint()..color = paper);
    final street = Paint()
      ..color = (dark ? AppColors.darkLine : const Color(0xFFE4D9CE))
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), street);
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), street);
    }
    final route = Path()
      ..moveTo(size.width * 0.28, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.42,
        size.width * 0.62,
        size.height * 0.22,
      );
    canvas.drawPath(
      route,
      Paint()
        ..color = dark ? AppColors.darkPrimary : AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    final rider = toDropoff
        ? Offset(size.width * 0.5, size.height * 0.4)
        : Offset(size.width * 0.32, size.height * 0.7);
    _dot(canvas, rider, dark ? AppColors.darkPrimary : AppColors.primary);
    _dot(canvas, Offset(size.width * 0.62, size.height * 0.22), AppColors.text);
  }

  void _dot(Canvas canvas, Offset at, Color color) {
    canvas
      ..drawCircle(at, 11, Paint()..color = AppColors.surface)
      ..drawCircle(at, 7, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) {
    return oldDelegate.toDropoff != toDropoff || oldDelegate.dark != dark;
  }
}
