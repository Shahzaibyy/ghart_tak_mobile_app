import 'package:flutter/widgets.dart';

/// Phosphor outline icons. Gold and duotone marks are separate glyphs.
abstract final class GhIcons {
  static const house = IconData(0xE2C2, fontFamily: 'PhosphorRegular');
  static const receipt = IconData(0xE3EC, fontFamily: 'PhosphorRegular');
  static const user = IconData(0xE4C2, fontFamily: 'PhosphorRegular');
  static const moped = IconData(0xE824, fontFamily: 'PhosphorRegular');
  static const wallet = IconData(0xE68A, fontFamily: 'PhosphorRegular');
  static const signOut = IconData(0xE42A, fontFamily: 'PhosphorRegular');
  static const caretRight = IconData(0xE13A, fontFamily: 'PhosphorRegular');
  static const magnifyingGlass = IconData(
    0xE30C,
    fontFamily: 'PhosphorRegular',
  );
  static const forkKnife = IconData(0xE262, fontFamily: 'PhosphorRegular');
  static const shoppingBag = IconData(0xE416, fontFamily: 'PhosphorRegular');
  static const firstAid = IconData(0xE56E, fontFamily: 'PhosphorRegular');
  static const package = IconData(0xE390, fontFamily: 'PhosphorRegular');
  static const bicycle = IconData(0xE0D6, fontFamily: 'PhosphorRegular');
  static const plus = IconData(0xE3D4, fontFamily: 'PhosphorRegular');
  static const check = IconData(0xE182, fontFamily: 'PhosphorRegular');
  static const circle = IconData(0xE18A, fontFamily: 'PhosphorRegular');
  static const image = IconData(0xE2CA, fontFamily: 'PhosphorRegular');
  static const list = IconData(0xE2F0, fontFamily: 'PhosphorRegular');
  static const phone = IconData(0xE3B8, fontFamily: 'PhosphorRegular');
  static const mapPin = IconData(0xE316, fontFamily: 'PhosphorRegular');
  static const storefront = IconData(0xE470, fontFamily: 'PhosphorRegular');
  static const lightning = IconData(0xE2DE, fontFamily: 'PhosphorRegular');
  static const navigationArrow = IconData(
    0xEADE,
    fontFamily: 'PhosphorRegular',
  );
  static const shieldCheck = IconData(0xE40C, fontFamily: 'PhosphorRegular');
  static const siren = IconData(0xE9B8, fontFamily: 'PhosphorRegular');
  static const clock = IconData(0xE19A, fontFamily: 'PhosphorRegular');
  static const caretLeft = IconData(0xE138, fontFamily: 'PhosphorRegular');
  static const x = IconData(0xE4F6, fontFamily: 'PhosphorRegular');
  static const broadcast = IconData(0xE0F2, fontFamily: 'PhosphorRegular');
  static const bell = IconData(0xE0CE, fontFamily: 'PhosphorRegular');
  static const heart = IconData(0xE2A8, fontFamily: 'PhosphorRegular');
  static const heartFill = IconData(0xE2A8, fontFamily: 'PhosphorFill');
  static const truck = IconData(0xE4B4, fontFamily: 'PhosphorRegular');
  static const microphone = IconData(0xE326, fontFamily: 'PhosphorRegular');
  static const camera = IconData(0xE10E, fontFamily: 'PhosphorRegular');
  static const tag = IconData(0xE478, fontFamily: 'PhosphorRegular');
  static const chatCircle = IconData(0xE168, fontFamily: 'PhosphorRegular');
  static const starFill = IconData(0xE46A, fontFamily: 'PhosphorFill');
  static const checkFill = IconData(0xE182, fontFamily: 'PhosphorFill');
  static const bowlFood = IconData(0xE0E6, fontFamily: 'PhosphorRegular');
  static const pill = IconData(0xE3C0, fontFamily: 'PhosphorRegular');
  static const gear = IconData(0xE278, fontFamily: 'PhosphorRegular');
  static const gift = IconData(0xE27C, fontFamily: 'PhosphorRegular');
  static const moon = IconData(0xE33E, fontFamily: 'PhosphorRegular');
  static const fingerprint = IconData(0xE24A, fontFamily: 'PhosphorRegular');
  static const trash = IconData(0xE4AA, fontFamily: 'PhosphorRegular');
  static const speakerHigh = IconData(0xE44A, fontFamily: 'PhosphorRegular');
  static const batteryCharging = IconData(0xE0C6, fontFamily: 'PhosphorRegular');
  static const funnel = IconData(0xE26E, fontFamily: 'PhosphorRegular');
  static const minus = IconData(0xE32A, fontFamily: 'PhosphorRegular');
  static const fileText = IconData(0xE23C, fontFamily: 'PhosphorRegular');
  static const headset = IconData(0xE2A4, fontFamily: 'PhosphorRegular');
  static const chartBar = IconData(0xE160, fontFamily: 'PhosphorRegular');
  static const translate = IconData(0xE4A8, fontFamily: 'PhosphorRegular');
  static const packageFront = IconData(0xE391, fontFamily: 'PhosphorDuotone');
  static const packageBack = IconData(0xE390, fontFamily: 'PhosphorDuotone');
  static const checkCircleFront = IconData(
    0xE185,
    fontFamily: 'PhosphorDuotone',
  );
  static const checkCircleBack = IconData(
    0xE184,
    fontFamily: 'PhosphorDuotone',
  );
}

/// Two-layer Phosphor duotone mark, used only for empty and success moments.
class GhDuotone extends StatelessWidget {
  /// Creates a duotone icon.
  const new({
    required this.front,
    required this.back,
    this.size = 24,
    this.color,
    super.key,
  });

  /// Foreground glyph.
  final IconData front;

  /// Soft background glyph.
  final IconData back;

  /// Icon size.
  final double size;

  /// Tint.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.28,
            child: Icon(back, size: size, color: color),
          ),
          Icon(front, size: size, color: color),
        ],
      ),
    );
  }
}
