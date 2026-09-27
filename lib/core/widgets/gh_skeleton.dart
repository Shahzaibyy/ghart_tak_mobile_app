import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Shimmering placeholder matching the layout that will replace it.
class GhSkeleton extends StatefulWidget {
  /// Creates a skeleton block.
  const new({this.height = 16, this.radius = 8, super.key});

  /// Block height.
  final double height;

  /// Corner radius.
  final double radius;

  @override
  State<GhSkeleton> createState() => _GhSkeletonState();
}

class _GhSkeletonState extends State<GhSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final base = dark ? AppColors.darkSurface : AppColors.surface;
    final wash = dark ? AppColors.darkLine : AppColors.line;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              colors: [base, wash, base],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(-1 + (_controller.value * 2), 0),
              end: Alignment(1 + (_controller.value * 2), 0),
            ),
          ),
          child: SizedBox(height: widget.height, width: double.infinity),
        );
      },
    );
  }
}

/// A few stacked bars used as the default loading state.
class GhSkeletonList extends StatelessWidget {
  /// Creates the list skeleton.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          GhSkeleton(height: 28),
          SizedBox(height: 16),
          GhSkeleton(height: 180, radius: 16),
          SizedBox(height: 12),
          GhSkeleton(height: 180, radius: 16),
        ],
      ),
    );
  }
}
