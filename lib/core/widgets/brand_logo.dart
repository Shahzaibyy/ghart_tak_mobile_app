import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Wordmark used on the sign-in screen. The dark plate is the brand lockup.
class BrandLogo extends StatelessWidget {
  /// Creates the Bhook Lagi wordmark.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SvgPicture.asset(
        'assets/branding/logo_dark.svg',
        height: 64,
        semanticsLabel: 'Bhook Lagi',
      ),
    );
  }
}
