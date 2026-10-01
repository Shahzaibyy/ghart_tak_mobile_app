import 'dart:async';

import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/features/auth/presentation/providers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _Slide {
  const new({
    required this.art,
    required this.title,
    required this.body,
    required this.sticker,
  });

  final String art;
  final String title;
  final String body;
  final String sticker;
}

const _slides = [
  _Slide(
    art: 'assets/branding/onboarding/slide_fridge.svg',
    title: 'Fridge khola? Khaali. Order karo.',
    body: 'Fateh Jang ke desi khaane, seedha ghar.',
    sticker: 'Mummy ko mat batana',
  ),
  _Slide(
    art: 'assets/branding/onboarding/slide_diet.svg',
    title: 'Diet kal se. Order aaj se.',
    body: 'Grocery bhi, gaon tak bhi. Kuch bhi, kahin bhi.',
    sticker: 'Diet? Kaun si diet',
  ),
  _Slide(
    art: 'assets/branding/onboarding/slide_lunch.svg',
    title: 'Lunch ghar bhool aaye?',
    body: 'File, document, jo bhi. Dasti book karo, hum utha laate hain.',
    sticker: 'Sab ke saath hota hai',
  ),
  _Slide(
    art: 'assets/branding/onboarding/slide_bike.svg',
    title: 'Bike hai? Boss khud ban.',
    body: 'Order uthao, paisay kamao. Apna time, apni marzi.',
    sticker: 'Boss bhi tum',
  ),
];

const _slideHold = Duration(milliseconds: 2800);
const _slideFade = Duration(milliseconds: 300);
const _ink = Color(0xFFF5F1EB);
const _muted = Color(0xFFA39A8E);
const _stage = Color(0xFF0F0D0B);

/// Animated Gen Z welcome from onboarding v3.
class WelcomeScreen extends ConsumerStatefulWidget {
  /// Creates the welcome screen.
  const new({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  var _index = 0;
  late final AnimationController _bar;
  DateTime? _holdStarted;
  var _holding = false;

  @override
  void initState() {
    super.initState();
    _bar = AnimationController(vsync: this, duration: _slideHold)
      ..addStatusListener(_onBarStatus)
      ..forward();
  }

  @override
  void dispose() {
    _bar
      ..removeStatusListener(_onBarStatus)
      ..dispose();
    super.dispose();
  }

  void _onBarStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (_holding) return;
    _go((_index + 1) % _slides.length);
  }

  void _go(int next) {
    setState(() => _index = next);
    _bar
      ..duration = _slideHold
      ..forward(from: 0);
  }

  void _step({required bool next}) {
    final length = _slides.length;
    final target = next
        ? (_index + 1) % length
        : (_index - 1 + length) % length;
    _go(target);
  }

  void _onTapSide({required bool next}) {
    if (_holding) return;
    _step(next: next);
  }

  void _onPointerDown() {
    _holdStarted = DateTime.now();
  }

  void _onPointerMove() {
    final started = _holdStarted;
    if (started == null || _holding) return;
    final held = DateTime.now().difference(started);
    if (held < const Duration(milliseconds: 250)) return;
    setState(() => _holding = true);
    _bar.stop();
  }

  void _onPointerUp({required bool nextZone, required double dx}) {
    final wasHolding = _holding;
    _holdStarted = null;
    if (_holding) {
      setState(() => _holding = false);
      _bar.forward();
      return;
    }
    if (wasHolding) return;
    if (dx.abs() > 40) {
      _step(next: dx < 0);
      return;
    }
    _onTapSide(next: nextZone);
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];

    return Scaffold(
      backgroundColor: _stage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
              child: _ProgressBars(
                index: _index,
                total: _slides.length,
                progress: _bar,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 14, 22, 0),
              child: _WelcomeHeader(),
            ),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: AnimatedSwitcher(
                      duration: _slideFade,
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        final offset = Tween<Offset>(
                          begin: const Offset(0.06, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offset,
                            child: child,
                          ),
                        );
                      },
                      child: _HeroCopy(
                        key: ValueKey(_index),
                        slide: slide,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _TapZone(
                          onDown: _onPointerDown,
                          onMove: _onPointerMove,
                          onUp: (dx) => _onPointerUp(
                            nextZone: false,
                            dx: dx,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _TapZone(
                          onDown: _onPointerDown,
                          onMove: _onPointerMove,
                          onUp: (dx) => _onPointerUp(
                            nextZone: true,
                            dx: dx,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
              child: Column(
                children: [
                  const _WelcomeButton(),
                  const SizedBox(height: 4),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () {
                          unawaited(
                            ref
                                .read(onboardingControllerProvider.notifier)
                                .skipToHome(
                                  role: OnboardingRole.customer,
                                ),
                          );
                        },
                        child: const Text(
                          'Skip to customer',
                          style: TextStyle(color: _muted, fontSize: 13),
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
                        child: const Text(
                          'Skip to rider',
                          style: TextStyle(color: _muted, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TapZone extends StatefulWidget {
  const new({
    required this.onDown,
    required this.onMove,
    required this.onUp,
  });

  final VoidCallback onDown;
  final VoidCallback onMove;
  final ValueChanged<double> onUp;

  @override
  State<_TapZone> createState() => _TapZoneState();
}

class _TapZoneState extends State<_TapZone> {
  double _x0 = 0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        _x0 = e.position.dx;
        widget.onDown();
      },
      onPointerMove: (_) => widget.onMove(),
      onPointerUp: (e) => widget.onUp(e.position.dx - _x0),
      onPointerCancel: (_) => widget.onUp(0),
      child: const SizedBox.expand(),
    );
  }
}

class _ProgressBars extends StatelessWidget {
  const new({
    required this.index,
    required this.total,
    required this.progress,
  });

  final int index;
  final int total;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 4,
                child: ColoredBox(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  child: i < index
                      ? const ColoredBox(color: AppColors.primary)
                      : i == index
                      ? AnimatedBuilder(
                          animation: progress,
                          builder: (context, _) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress.value.clamp(0, 1),
                              child: const ColoredBox(
                                color: AppColors.primary,
                              ),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/branding/mark_b.svg',
          height: 28,
          semanticsLabel: 'Bhook Lagi',
        ),
        const SizedBox(width: 10),
        Text(
          'Bhook Lagi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _ink,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const new({required this.slide, super.key});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 130,
            width: double.infinity,
            child: SvgPicture.asset(slide.art),
          ),
          const SizedBox(height: 14),
          Text(
            slide.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: _ink,
              height: 1.1,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            slide.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _muted,
              height: 1.4,
              fontSize: 16,
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
                border: Border.all(color: _ink, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                slide.sticker,
                style: const TextStyle(
                  color: _ink,
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

class _WelcomeButton extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          ref.read(onboardingControllerProvider.notifier).start();
        },
        borderRadius: BorderRadius.circular(14),
        child: const SizedBox(
          height: 52,
          width: double.infinity,
          child: Center(
            child: Text(
              'Get started',
              style: TextStyle(
                color: _ink,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
