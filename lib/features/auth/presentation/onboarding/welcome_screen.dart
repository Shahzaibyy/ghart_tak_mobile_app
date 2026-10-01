import 'dart:async';

import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/brand_mark.dart';
import 'package:attock_xpress/features/auth/presentation/providers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _Slide {
  const new({
    required this.mark,
    required this.title,
    required this.body,
    required this.sticker,
    this.invert = false,
  });

  final BrandMarkKind mark;
  final String title;
  final String body;
  final String sticker;
  final bool invert;
}

const _slides = [
  _Slide(
    mark: BrandMarkKind.customer,
    title: 'Fridge khola? Khaali. Order karo.',
    body: 'Fateh Jang ke desi khaane, seedha ghar.',
    sticker: 'Mummy ko mat batana',
  ),
  _Slide(
    mark: BrandMarkKind.customer,
    title: 'Diet kal se. Order aaj se.',
    body: 'Grocery bhi, gaon tak bhi. Kuch bhi, kahin bhi.',
    sticker: 'Diet? Kaun si diet',
  ),
  _Slide(
    mark: BrandMarkKind.customer,
    title: 'Lunch ghar bhool aaye?',
    body: 'File, document, jo bhi. Dasti book karo.',
    sticker: 'Sab ke saath hota hai',
  ),
  _Slide(
    mark: BrandMarkKind.rider,
    title: 'Bike hai? Boss khud ban.',
    body: 'Order uthao, paisay kamao. Apna time, apni marzi.',
    sticker: 'Boss bhi tum',
    invert: true,
  ),
];

const _slideHold = Duration(seconds: 3);
const _slideFade = Duration(milliseconds: 380);

/// Animated Gen Z welcome. One Get started button.
class WelcomeScreen extends ConsumerStatefulWidget {
  /// Creates the welcome screen.
  const new({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  var _index = 0;
  var _touching = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncAutoplay();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _reducedMotion {
    return MediaQuery.disableAnimationsOf(context);
  }

  void _syncAutoplay() {
    _timer?.cancel();
    if (_reducedMotion || _touching) return;
    _timer = Timer.periodic(_slideHold, (_) {
      if (!mounted || _touching) return;
      _goTo((_index + 1) % _slides.length);
    });
  }

  void _goTo(int index) {
    if (_index == index) return;
    setState(() => _index = index);
  }

  void _next() => _goTo((_index + 1) % _slides.length);

  void _previous() {
    _goTo((_index - 1 + _slides.length) % _slides.length);
  }

  void _onTouchStart() {
    if (_reducedMotion) return;
    setState(() => _touching = true);
    _timer?.cancel();
  }

  void _onTouchEnd() {
    if (_reducedMotion) return;
    setState(() => _touching = false);
    _syncAutoplay();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    final invert = slide.invert;
    final bg = invert ? AppColors.primary : AppColors.background;
    final ink = invert ? AppColors.background : AppColors.text;
    final muted = invert
        ? AppColors.background.withValues(alpha: 0.72)
        : AppColors.textMuted;
    final btnFill = invert ? AppColors.background : AppColors.primary;
    final btnInk = invert ? AppColors.error : AppColors.surface;

    return AnimatedContainer(
      duration: _reducedMotion ? Duration.zero : _slideFade,
      color: bg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: _reducedMotion ? Duration.zero : _slideFade,
                  style:
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w600,
                      ) ??
                      TextStyle(color: ink),
                  child: const Text('Bhook Lagi'),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) => _onTouchStart(),
                    onTapUp: (_) {
                      _next();
                      _onTouchEnd();
                    },
                    onTapCancel: _onTouchEnd,
                    onHorizontalDragStart: (_) => _onTouchStart(),
                    onHorizontalDragEnd: (details) {
                      final dx = details.primaryVelocity ?? 0;
                      if (dx < -200) {
                        _next();
                      } else if (dx > 200) {
                        _previous();
                      }
                      _onTouchEnd();
                    },
                    child: AnimatedSwitcher(
                      duration: _reducedMotion
                          ? Duration.zero
                          : _slideFade,
                      child: _HeroCopy(
                        key: ValueKey(_index),
                        slide: slide,
                        ink: ink,
                        muted: muted,
                      ),
                    ),
                  ),
                ),
                _Dots(index: _index, invert: invert),
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: _reducedMotion ? Duration.zero : _slideFade,
                  child: _WelcomeButton(
                    fill: btnFill,
                    ink: btnInk,
                    onPressed: () {
                      ref
                          .read(onboardingControllerProvider.notifier)
                          .start();
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    unawaited(
                      ref
                          .read(onboardingControllerProvider.notifier)
                          .skipToHome(role: OnboardingRole.customer),
                    );
                  },
                  child: Text(
                    'Skip to customer home',
                    style: TextStyle(
                      color: invert ? ink : AppColors.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    unawaited(
                      ref
                          .read(onboardingControllerProvider.notifier)
                          .skipToHome(role: OnboardingRole.rider),
                    );
                  },
                  child: Text(
                    'Skip to rider home',
                    style: TextStyle(
                      color: invert ? ink : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const new({
    required this.slide,
    required this.ink,
    required this.muted,
    super.key,
  });

  final _Slide slide;
  final Color ink;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrandMark(kind: slide.mark, size: 60),
          const SizedBox(height: 16),
          Text(
            slide.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: ink,
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            slide.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: muted,
            ),
          ),
          const SizedBox(height: 14),
          Transform.rotate(
            angle: -0.05,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: ink, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                slide.sticker,
                style: TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const new({required this.index, required this.invert});

  final int index;
  final bool invert;

  @override
  Widget build(BuildContext context) {
    final color = invert ? AppColors.background : AppColors.primary;
    return Row(
      children: List.generate(_slides.length, (i) {
        final on = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.only(right: 6),
          height: 6,
          width: on ? 22 : 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: on ? 1 : 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  const new({
    required this.fill,
    required this.ink,
    required this.onPressed,
  });

  final Color fill;
  final Color ink;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: Center(
            child: Text(
              'Get started',
              style: TextStyle(
                color: ink,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
