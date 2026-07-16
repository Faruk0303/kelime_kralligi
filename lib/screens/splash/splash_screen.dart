import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelime_kralligi/screens/main_menu.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _exitController;

  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoOpacityAnimation;

  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<double> _titleOpacityAnimation;

  late final Animation<Offset> _sloganSlideAnimation;
  late final Animation<double> _sloganOpacityAnimation;

  late final Animation<double> _screenOpacityAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _prepareAnimations();
    _startSplashSequence();
  }

  void _prepareAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.20,
          end: 1.12,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 75,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.12,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_logoController);

    _logoOpacityAnimation = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.55), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.0, 0.70, curve: Curves.easeOutCubic),
          ),
        );

    _titleOpacityAnimation = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
    );

    _sloganSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.65), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.30, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _sloganOpacityAnimation = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeIn),
    );

    _screenOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startSplashSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    HapticFeedback.lightImpact();

    await _logoController.forward();

    if (!mounted) return;

    await _textController.forward();

    if (!mounted) return;

    _navigationTimer = Timer(const Duration(milliseconds: 1300), _goToMainMenu);
  }

  Future<void> _goToMainMenu() async {
    if (!mounted) return;

    await _exitController.forward();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const MainMenu();
        },
        transitionDuration: const Duration(milliseconds: 650),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          return FadeTransition(opacity: fadeAnimation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _logoController.dispose();
    _textController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _screenOpacityAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E64F0), Color(0xFF3F82FF), Color(0xFF74A8FF)],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                const Positioned(
                  top: 60,
                  left: 40,
                  child: _DecorativeStar(size: 22, opacity: 0.50),
                ),
                const Positioned(
                  top: 125,
                  right: 45,
                  child: _DecorativeStar(size: 30, opacity: 0.65),
                ),
                const Positioned(
                  bottom: 150,
                  left: 55,
                  child: _DecorativeStar(size: 18, opacity: 0.45),
                ),
                const Positioned(
                  bottom: 90,
                  right: 55,
                  child: _DecorativeStar(size: 24, opacity: 0.55),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeTransition(
                          opacity: _logoOpacityAnimation,
                          child: ScaleTransition(
                            scale: _logoScaleAnimation,
                            child: Container(
                              width: 205,
                              height: 205,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 28,
                                    offset: const Offset(0, 14),
                                  ),
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFD65C,
                                    ).withValues(alpha: 0.30),
                                    blurRadius: 35,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo/app_icon.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFFFFC83D),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.menu_book_rounded,
                                        size: 90,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 34),
                        FadeTransition(
                          opacity: _titleOpacityAnimation,
                          child: SlideTransition(
                            position: _titleSlideAnimation,
                            child: Text(
                              'Kelime Krallığı',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 41,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeTransition(
                          opacity: _sloganOpacityAnimation,
                          child: SlideTransition(
                            position: _sloganSlideAnimation,
                            child: Text(
                              'Kelimelerle Krallığını Büyüt!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.92),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 22,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _sloganOpacityAnimation,
                    child: Text(
                      'v1.0.1',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
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

class _DecorativeStar extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorativeStar({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome_rounded,
      size: size,
      color: Colors.white.withValues(alpha: opacity),
    );
  }
}
