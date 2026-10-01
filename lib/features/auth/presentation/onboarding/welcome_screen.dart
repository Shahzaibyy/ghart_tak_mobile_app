import 'dart:async';

import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/brand_mark.dart';
import 'package:attock_xpress/features/auth/presentation/providers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _Slide {
  const new({
    required this.mark,
    required this.title,
    required this.body,
    required this.sticker,
  });

  final BrandMarkKind mark;
  final String title;
  final String body;
  final String sticker;
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
  ),
];

const _slideHold = Duration(seconds: 1);
const _slideFade = Duration(milliseconds: 380);
const _ink = Color(0xFFF5F1EB);
const _muted = Color(0xFFA39A8E);
const _stage = Color(0xFF0F0D0B);

/// Animated Gen Z welcome. One Get started button.
class WelcomeScreen extends ConsumerStatefulWidget {
  /// Creates the welcome screen.
  const new({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  var _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_slideHold, (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % _slides.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];

    return Scaffold(
      backgroundColor: _stage,
      body: Stack(
        children: [
          const Positioned.fill(child: _RingBackdrop()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _WelcomeHeader(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: _slideFade,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final offset = Tween<Offset>(
                          begin: const Offset(0, 0.06),
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
                  _Dots(index: _index),
                  const SizedBox(height: 16),
                  const _WelcomeButton(),
                  const SizedBox(height: 8),
                  Center(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () {
                            unawaited(
                              ref
                                  .read(
                                    onboardingControllerProvider.notifier,
                                  )
                                  .skipToHome(
                                    role: OnboardingRole.customer,
                                  ),
                            );
                          },
                          child: const Text(
                            'Skip to customer',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            unawaited(
                              ref
                                  .read(
                                    onboardingControllerProvider.notifier,
                                  )
                                  .skipToHome(role: OnboardingRole.rider),
                            );
                          },
                          child: const Text(
                            'Skip to rider',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

class _RingBackdrop extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _RingsPainter());
  }
}

class _RingsPainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = AppColors.primary.withValues(alpha: 0.18);
    final center = Offset(size.width * 0.92, size.height * 0.52);
    for (final radius in [90.0, 150.0, 210.0, 270.0]) {
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
          BrandMark(kind: slide.mark, size: 72),
          const SizedBox(height: 22),
          Text(
            slide.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: _ink,
              height: 1.08,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              fontSize: 34,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _muted,
              height: 1.4,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 18),
          Transform.rotate(
            angle: -0.06,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: _ink, width: 1.4),
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

class _Dots extends StatelessWidget {
  const new({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_slides.length, (i) {
        final on = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.only(right: 6),
          height: 6,
          width: on ? 22 : 6,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: on ? 1 : 0.28),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
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
