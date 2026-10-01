import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Customer or rider mark from the brand kit.
enum BrandMarkKind {
  /// Terracotta customer disc.
  customer,

  /// Dark rider disc with play mark.
  rider,
}

/// Circular role mark used on onboarding screens.
class BrandMark extends StatelessWidget {
  /// Creates a customer or rider mark.
  const new({required this.kind, this.size = 52, super.key});

  /// Which mark to render.
  final BrandMarkKind kind;

  /// Width and height.
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = switch (kind) {
      BrandMarkKind.customer => 'assets/branding/customer_mark.svg',
      BrandMarkKind.rider => 'assets/branding/rider_mark.svg',
    };
    final label = switch (kind) {
      BrandMarkKind.customer => 'Customer',
      BrandMarkKind.rider => 'Rider',
    };
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      semanticsLabel: label,
    );
  }
}
