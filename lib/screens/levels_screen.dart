// lib/screens/levels_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelime_kralligi/providers/game_state.dart';
import 'package:kelime_kralligi/screens/main_menu.dart';
import 'package:kelime_kralligi/screens/voice_input.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen>
    with TickerProviderStateMixin {
  static const int _playableLevelCount = 3;

  late final AnimationController _entranceController;
  late final AnimationController _floatingController;
  late final Animation<double> _floatingAnimation;

  final List<_LevelInfo> _levels = const [
    _LevelInfo(
      title: 'Renkler',
      subtitle: 'Renklerin büyülü dünyasını keşfet',
      icon: Icons.palette_rounded,
      primaryColor: Color(0xFFFF5F8F),
      secondaryColor: Color(0xFFFFA7C2),
    ),
    _LevelInfo(
      title: 'Hayvanlar',
      subtitle: 'Sevimli dostlarımızı öğren',
      icon: Icons.pets_rounded,
      primaryColor: Color(0xFFFFA726),
      secondaryColor: Color(0xFFFFD180),
    ),
    _LevelInfo(
      title: 'Eşyalar',
      subtitle: 'Etrafındaki eşyaları tanı',
      icon: Icons.chair_alt_rounded,
      primaryColor: Color(0xFF26A69A),
      secondaryColor: Color(0xFF80CBC4),
    ),
    _LevelInfo(
      title: 'Yiyecekler',
      subtitle: 'Lezzetli kelimeler yakında',
      icon: Icons.restaurant_rounded,
      primaryColor: Color(0xFFEF5350),
      secondaryColor: Color(0xFFEF9A9A),
    ),
    _LevelInfo(
      title: 'Meslekler',
      subtitle: 'Yeni meslekleri keşfet',
      icon: Icons.work_rounded,
      primaryColor: Color(0xFF7E57C2),
      secondaryColor: Color(0xFFB39DDB),
    ),
    _LevelInfo(
      title: 'Taşıtlar',
      subtitle: 'Yolculuk kelimeleri yakında',
      icon: Icons.directions_car_filled_rounded,
      primaryColor: Color(0xFF42A5F5),
      secondaryColor: Color(0xFF90CAF9),
    ),
    _LevelInfo(
      title: 'Doğa',
      subtitle: 'Doğanın kelimelerini öğren',
      icon: Icons.park_rounded,
      primaryColor: Color(0xFF66BB6A),
      secondaryColor: Color(0xFFA5D6A7),
    ),
    _LevelInfo(
      title: 'Sporlar',
      subtitle: 'Hareketli kelimeler yakında',
      icon: Icons.sports_soccer_rounded,
      primaryColor: Color(0xFFFF7043),
      secondaryColor: Color(0xFFFFAB91),
    ),
    _LevelInfo(
      title: 'Meyveler',
      subtitle: 'Rengârenk meyveleri öğren',
      icon: Icons.eco_rounded,
      primaryColor: Color(0xFFEC407A),
      secondaryColor: Color(0xFFF48FB1),
    ),
    _LevelInfo(
      title: 'Gezegenler',
      subtitle: 'Uzayın kelimeleri yakında',
      icon: Icons.public_rounded,
      primaryColor: Color(0xFF5C6BC0),
      secondaryColor: Color(0xFF9FA8DA),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _floatingAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _loadData();
    _entranceController.forward();
    _floatingController.repeat(reverse: true);
  }

  Future<void> _loadData() async {
    await GameState.instance.loadGameData();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  bool _isLevelCompleted(int index) {
    return GameState.instance.isLevelCompleted(index);
  }

  bool _isLevelUnlocked(int index) {
    if (index >= _playableLevelCount) return false;
    if (index == 0) return true;
    return _isLevelCompleted(index - 1);
  }

  int _completedWords(int index) {
    return GameState.instance.getCompletedWordsCount(index);
  }

  int _totalWords(int index) {
    return index < _playableLevelCount ? 20 : 0;
  }

  Future<void> _openLevel(int index) async {
    if (!_isLevelUnlocked(index)) {
      _showLockedMessage(index);
      return;
    }

    GameState.instance.resetCurrentLevelScore();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VoiceInput(levelIndex: index, colorName: '', word: ''),
      ),
    );

    await _loadData();
  }

  void _showLockedMessage(int index) {
    final isComingSoon = index >= _playableLevelCount;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Row(
          children: [
            Icon(
              isComingSoon ? Icons.auto_awesome_rounded : Icons.lock_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isComingSoon
                    ? '${_levels[index].title} bölümü yakında eklenecek!'
                    : 'Önce bir önceki seviyeyi tamamlamalısın.',
                style: GoogleFonts.fredoka(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF183153),
      ),
    );
  }

  void _goBackToMenu() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainMenu()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.shortestSide >= 600;
    final maxWidth = isTablet ? 700.0 : 500.0;

    return Scaffold(
      body: Stack(
        children: [
          const _MapBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(isTablet),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          isTablet ? 70 : 22,
                          20,
                          isTablet ? 70 : 22,
                          80,
                        ),
                        itemCount: _levels.length,
                        itemBuilder: (context, index) {
                          final animation = CurvedAnimation(
                            parent: _entranceController,
                            curve: Interval(
                              (index * 0.06).clamp(0.0, 0.65),
                              ((index * 0.06) + 0.35).clamp(0.35, 1.0),
                              curve: Curves.easeOutBack,
                            ),
                          );

                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.75,
                                end: 1,
                              ).animate(animation),
                              child: _buildMapItem(index, isTablet),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    final completedPlayableLevels = List<int>.generate(
      _playableLevelCount,
      (index) => index,
    ).where(_isLevelCompleted).length;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 36 : 18,
        10,
        isTablet ? 36 : 18,
        8,
      ),
      child: Row(
        children: [
          _RoundActionButton(
            icon: Icons.arrow_back_rounded,
            onPressed: _goBackToMenu,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelime Haritası',
                  style: GoogleFonts.fredoka(
                    fontSize: isTablet ? 33 : 27,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        offset: const Offset(0, 3),
                        blurRadius: 7,
                      ),
                    ],
                  ),
                ),
                Text(
                  '$completedPlayableLevels / $_playableLevelCount bölüm tamamlandı',
                  style: GoogleFonts.fredoka(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
          _HeaderChip(
            icon: Icons.star_rounded,
            value: '${GameState.instance.score}',
          ),
        ],
      ),
    );
  }

  Widget _buildMapItem(int index, bool isTablet) {
    final info = _levels[index];
    final isUnlocked = _isLevelUnlocked(index);
    final isCompleted = _isLevelCompleted(index);
    final isComingSoon = index >= _playableLevelCount;
    final currentWords = _completedWords(index);
    final totalWords = _totalWords(index);
    final progress = totalWords == 0
        ? 0.0
        : (currentWords / totalWords).clamp(0.0, 1.0);

    final alignRight = index.isOdd;
    final nodeSize = isTablet ? 118.0 : 94.0;

    return Column(
      children: [
        if (index > 0)
          _MapConnector(
            alignRight: alignRight,
            isActive: isUnlocked || isCompleted,
          ),
        Row(
          mainAxisAlignment: alignRight
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: GestureDetector(
                onTap: () => _openLevel(index),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: alignRight
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  children: [
                    AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        final shouldFloat =
                            isUnlocked && !isCompleted && !isComingSoon;

                        return Transform.translate(
                          offset: Offset(
                            0,
                            shouldFloat ? _floatingAnimation.value : 0,
                          ),
                          child: child,
                        );
                      },
                      child: _LevelNode(
                        index: index,
                        size: nodeSize,
                        info: info,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        isComingSoon: isComingSoon,
                      ),
                    ),
                    SizedBox(width: isTablet ? 22 : 14),
                    Flexible(
                      child: _LevelDescriptionCard(
                        index: index,
                        info: info,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        isComingSoon: isComingSoon,
                        currentWords: currentWords,
                        totalWords: totalWords,
                        progress: progress,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LevelInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const _LevelInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

class _LevelNode extends StatelessWidget {
  final int index;
  final double size;
  final _LevelInfo info;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isComingSoon;

  const _LevelNode({
    required this.index,
    required this.size,
    required this.info,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    final active = isUnlocked || isCompleted;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: active
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [info.secondaryColor, info.primaryColor],
                  )
                : const LinearGradient(
                    colors: [Color(0xFFB8C2D1), Color(0xFF7B8798)],
                  ),
            border: Border.all(
              color: active
                  ? const Color(0xFFFFE69A)
                  : Colors.white.withValues(alpha: 0.55),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: active
                    ? info.primaryColor.withValues(alpha: 0.38)
                    : Colors.black.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.34),
                blurRadius: 0,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isCompleted
                  ? Icons.check_rounded
                  : isComingSoon
                  ? Icons.auto_awesome_rounded
                  : isUnlocked
                  ? info.icon
                  : Icons.lock_rounded,
              color: Colors.white,
              size: size * 0.43,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -7,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFFFFC83D)
                  : const Color(0xFF183153),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 7,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '${index + 1}',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isCompleted ? const Color(0xFF6D3E00) : Colors.white,
              ),
            ),
          ),
        ),
        if (isCompleted)
          const Positioned(
            top: -12,
            right: -7,
            child: Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFFFD54F),
              size: 34,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 3),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LevelDescriptionCard extends StatelessWidget {
  final int index;
  final _LevelInfo info;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isComingSoon;
  final int currentWords;
  final int totalWords;
  final double progress;

  const _LevelDescriptionCard({
    required this.index,
    required this.info,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isComingSoon,
    required this.currentWords,
    required this.totalWords,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final active = isUnlocked || isCompleted;

    String statusText;
    if (isCompleted) {
      statusText = 'Tamamlandı';
    } else if (isComingSoon) {
      statusText = 'Yakında';
    } else if (isUnlocked) {
      statusText = 'Oynamaya hazır';
    } else {
      statusText = 'Kilitli';
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 165, maxWidth: 235),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: active ? 0.95 : 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.fredoka(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: active ? const Color(0xFF183153) : const Color(0xFF687587),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            info.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.fredoka(
              fontSize: 12.5,
              height: 1.25,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF69788D),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : isComingSoon
                    ? Icons.schedule_rounded
                    : isUnlocked
                    ? Icons.play_circle_fill_rounded
                    : Icons.lock_rounded,
                size: 18,
                color: isCompleted
                    ? const Color(0xFF4CAF50)
                    : active
                    ? info.primaryColor
                    : const Color(0xFF8B96A5),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  statusText,
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? const Color(0xFF388E3C)
                        : active
                        ? info.primaryColor
                        : const Color(0xFF7C8796),
                  ),
                ),
              ),
            ],
          ),
          if (totalWords > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFE8EDF5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? const Color(0xFF4CAF50) : info.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$currentWords / $totalWords kelime',
              style: GoogleFonts.fredoka(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF718096),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapConnector extends StatelessWidget {
  final bool alignRight;
  final bool isActive;

  const _MapConnector({required this.alignRight, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: CustomPaint(
        painter: _ConnectorPainter(alignRight: alignRight, isActive: isActive),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  final bool alignRight;
  final bool isActive;

  const _ConnectorPainter({required this.alignRight, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive
          ? const Color(0xFFFFD65C)
          : Colors.white.withValues(alpha: 0.52)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final startX = alignRight ? size.width * 0.24 : size.width * 0.76;
    final endX = alignRight ? size.width * 0.76 : size.width * 0.24;

    path.moveTo(startX, 0);
    path.cubicTo(
      size.width * 0.50,
      size.height * 0.18,
      size.width * 0.50,
      size.height * 0.82,
      endX,
      size.height,
    );

    canvas.drawPath(path, paint);

    final glowPaint = Paint()
      ..color = isActive
          ? const Color(0xFFFFD65C).withValues(alpha: 0.25)
          : Colors.transparent
      ..strokeWidth = 13
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter oldDelegate) {
    return oldDelegate.alignRight != alignRight ||
        oldDelegate.isActive != isActive;
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2D75F0), Color(0xFF71AEFF), Color(0xFFBFE2FF)],
              stops: [0, 0.58, 1],
            ),
          ),
        ),
        Positioned(
          top: 85,
          left: -36,
          child: _Cloud(width: 150, opacity: 0.48),
        ),
        Positioned(
          top: 170,
          right: -42,
          child: _Cloud(width: 175, opacity: 0.40),
        ),
        Positioned(
          bottom: -75,
          left: -80,
          child: Container(
            width: 290,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF65C86D),
              borderRadius: BorderRadius.circular(140),
            ),
          ),
        ),
        Positioned(
          bottom: -90,
          right: -95,
          child: Container(
            width: 330,
            height: 205,
            decoration: BoxDecoration(
              color: const Color(0xFF4DBA63),
              borderRadius: BorderRadius.circular(160),
            ),
          ),
        ),
        const Positioned(
          top: 125,
          right: 80,
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 22,
            color: Color(0x99FFFFFF),
          ),
        ),
        const Positioned(
          top: 280,
          left: 48,
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 17,
            color: Color(0x80FFFFFF),
          ),
        ),
      ],
    );
  }
}

class _Cloud extends StatelessWidget {
  final double width;
  final double opacity;

  const _Cloud({required this.width, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.cloud_rounded,
      size: width,
      color: Colors.white.withValues(alpha: opacity),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.19),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, color: Colors.white, size: 25),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String value;

  const _HeaderChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.19),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFFD54F), size: 20),
          const SizedBox(width: 5),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
