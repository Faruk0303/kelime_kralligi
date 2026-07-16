// lib/screens/main_menu.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelime_kralligi/providers/game_state.dart';
import 'package:kelime_kralligi/screens/levels_screen.dart';
import 'package:kelime_kralligi/screens/settings_screen.dart';
import 'package:kelime_kralligi/screens/voice_input.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _floatingController;

  late final Animation<double> _logoScale;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.75,
          end: 1.06,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 75,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.06,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_entranceController);

    _contentOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 1.0, curve: Curves.easeIn),
    );

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.16), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _floatingAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _openGame() {
    final completedLevelIndex = GameState.instance.completedLevelIndex;

    if (completedLevelIndex < 0) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const LevelsScreen()));
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VoiceInput(
          levelIndex: completedLevelIndex,
          colorName: '',
          word: '',
        ),
      ),
    );
  }

  Future<void> _startNewGame() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(Icons.refresh_rounded, color: Color(0xFF1E64F0)),
              const SizedBox(width: 10),
              Text(
                'Yeni oyun başlat',
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Text(
            'Mevcut ilerlemen sıfırlanacak. Yeni bir oyun başlatmak istediğine emin misin?',
            style: GoogleFonts.fredoka(fontSize: 16, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Vazgeç',
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E64F0),
              ),
              child: Text(
                'Başlat',
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (shouldReset != true || !mounted) return;

    GameState.instance.resetGame();

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const LevelsScreen()));
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.shortestSide >= 600;
    final horizontalPadding = isTablet ? 72.0 : 22.0;
    final maxContentWidth = isTablet ? 620.0 : 480.0;

    return Scaffold(
      body: Stack(
        children: [
          const _MenuBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    28,
                  ),
                  child: Column(
                    children: [
                      _buildTopBar(),
                      SizedBox(height: isTablet ? 34 : 22),
                      AnimatedBuilder(
                        animation: _floatingAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatingAnimation.value),
                            child: child,
                          );
                        },
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: _buildLogo(isTablet),
                        ),
                      ),
                      const SizedBox(height: 22),
                      FadeTransition(
                        opacity: _contentOpacity,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: Column(
                            children: [
                              Text(
                                'Kelime Krallığı',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  fontSize: isTablet ? 48 : 38,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      offset: const Offset(0, 4),
                                      blurRadius: 9,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                'Kelimeleri öğren, krallığını büyüt!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fredoka(
                                  fontSize: isTablet ? 20 : 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                              ),
                              SizedBox(height: isTablet ? 30 : 24),
                              _buildStatusCard(),
                              SizedBox(height: isTablet ? 28 : 22),
                              _PrimaryPlayButton(onPressed: _openGame),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SecondaryMenuButton(
                                      icon: Icons.refresh_rounded,
                                      label: 'Yeni Oyun',
                                      onPressed: _startNewGame,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _SecondaryMenuButton(
                                      icon: Icons.settings_rounded,
                                      label: 'Ayarlar',
                                      onPressed: _openSettings,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'v1.0.1',
                                style: GoogleFonts.fredoka(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _SmallInfoChip(
          icon: Icons.star_rounded,
          iconColor: const Color(0xFFFFD54F),
          text: '${GameState.instance.score}',
        ),
        const Spacer(),
        _SmallInfoChip(
          icon: Icons.favorite_rounded,
          iconColor: const Color(0xFFFF5C77),
          text: '${GameState.instance.lives}',
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.white.withValues(alpha: 0.18),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _openSettings,
            child: const Padding(
              padding: EdgeInsets.all(11),
              child: Icon(
                Icons.settings_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(bool isTablet) {
    final size = isTablet ? 220.0 : 172.0;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: const Color(0xFFFFD65C), width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 26,
            offset: const Offset(0, 13),
          ),
          BoxShadow(
            color: const Color(0xFFFFD65C).withValues(alpha: 0.25),
            blurRadius: 32,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo/app_icon.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFFFFC83D)),
              child: Center(
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 82,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final completedLevel = GameState.instance.completedLevelIndex;
    final currentLevelText = completedLevel < 0
        ? 'İlk macerana başla!'
        : '${completedLevel + 1}. seviyeye devam et';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF1FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Color(0xFF1E64F0),
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Macera hazır!',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF183153),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  currentLevelText,
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF60708A),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF1E64F0),
            size: 30,
          ),
        ],
      ),
    );
  }
}

class _MenuBackground extends StatelessWidget {
  const _MenuBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1559E8), Color(0xFF367CF4), Color(0xFF74A8FF)],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -65,
          child: _GlowCircle(
            size: 220,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -85,
          child: _GlowCircle(
            size: 270,
            color: const Color(0xFFFFD65C).withValues(alpha: 0.14),
          ),
        ),
        const Positioned(
          top: 145,
          left: 30,
          child: _BackgroundSparkle(size: 22, opacity: 0.42),
        ),
        const Positioned(
          top: 210,
          right: 34,
          child: _BackgroundSparkle(size: 29, opacity: 0.55),
        ),
        const Positioned(
          bottom: 170,
          left: 54,
          child: _BackgroundSparkle(size: 18, opacity: 0.34),
        ),
        const Positioned(
          bottom: 95,
          right: 46,
          child: _BackgroundSparkle(size: 24, opacity: 0.42),
        ),
      ],
    );
  }
}

class _PrimaryPlayButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PrimaryPlayButton({required this.onPressed});

  @override
  State<_PrimaryPlayButton> createState() => _PrimaryPlayButtonState();
}

class _PrimaryPlayButtonState extends State<_PrimaryPlayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD65C), Color(0xFFFFB933)],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFFFEB9A), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB66A00).withValues(alpha: 0.45),
                blurRadius: 0,
                offset: const Offset(0, 7),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 11),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                size: 35,
                color: Color(0xFF6D3E00),
              ),
              const SizedBox(width: 8),
              Text(
                'OYNA',
                style: GoogleFonts.fredoka(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6D3E00),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SecondaryMenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: Colors.white, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: const Color(0xFF1E64F0)),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF183153),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallInfoChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _SmallInfoChip({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _BackgroundSparkle extends StatelessWidget {
  final double size;
  final double opacity;

  const _BackgroundSparkle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome_rounded,
      size: size,
      color: Colors.white.withValues(alpha: opacity),
    );
  }
}
