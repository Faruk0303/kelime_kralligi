// lib/screens/voice_input.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelime_kralligi/providers/game_state.dart';
import 'package:kelime_kralligi/screens/letter_shuffle.dart';
import 'package:kelime_kralligi/screens/levels_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInput extends StatefulWidget {
  final int levelIndex;

  const VoiceInput({
    super.key,
    required this.levelIndex,
    required String colorName,
    required String word,
  });

  @override
  State<VoiceInput> createState() => _VoiceInputState();
}

class _VoiceInputState extends State<VoiceInput> with TickerProviderStateMixin {
  late final stt.SpeechToText _speech;
  late final AnimationController _entranceController;
  late final AnimationController _micPulseController;

  Timer? _mascotTimer;
  Timer? _mascotHideTimer;
  bool _mascotVisible = false;
  bool _mascotFromRight = false;

  late final Animation<double> _entranceOpacity;
  late final Animation<Offset> _entranceSlide;
  late final Animation<double> _micPulse;

  bool _isListening = false;
  String _recognizedWord = '';
  String _lastSpokenCorrectWord = '';

  Set<String> _validWordsInLevel = <String>{};
  Map<String, Color> _wordColors = <String, Color>{};

  String _levelTitle = '';
  String _spokenWordsKey = '';
  String _categoryName = '';
  IconData _categoryIcon = Icons.auto_stories_rounded;
  Color _primaryColor = const Color(0xFF1E64F0);
  Color _secondaryColor = const Color(0xFF74A8FF);

  List<String> introMessages = <String>[];
  int currentMessageIndex = 0;
  bool showIntroMessages = false;
  bool allowVoiceInput = false;
  String playerName = 'Arkadaşım';
  String selectedCharacter = 'Ferhat';

  @override
  void initState() {
    super.initState();

    _speech = stt.SpeechToText();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _entranceOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    _entranceSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _micPulse = Tween<double>(begin: 0.96, end: 1.08).animate(
      CurvedAnimation(parent: _micPulseController, curve: Curves.easeInOut),
    );

    _initializeLevelData();
    _loadPrefsAndSetup();
    _entranceController.forward();
    _startMascotPeeking();
  }

  @override
  void dispose() {
    _mascotTimer?.cancel();
    _mascotHideTimer?.cancel();
    _speech.stop();
    _entranceController.dispose();
    _micPulseController.dispose();
    super.dispose();
  }

  void _startMascotPeeking() {
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _showMascotPeek();
    });

    _mascotTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted || showIntroMessages) return;
      _mascotFromRight = !_mascotFromRight;
      _showMascotPeek();
    });
  }

  void _showMascotPeek({bool? fromRight}) {
    if (!mounted) return;

    _mascotHideTimer?.cancel();

    setState(() {
      if (fromRight != null) {
        _mascotFromRight = fromRight;
      }
      _mascotVisible = true;
    });

    _mascotHideTimer = Timer(const Duration(milliseconds: 2100), () {
      if (!mounted) return;
      setState(() {
        _mascotVisible = false;
      });
    });
  }

  void _initializeLevelData() {
    switch (widget.levelIndex) {
      case 0:
        _categoryName = 'Renkler';
        _levelTitle = 'Bir Renk Söyle';
        _spokenWordsKey = 'spokenColorsWords';
        _categoryIcon = Icons.palette_rounded;
        _primaryColor = const Color(0xFFFF5F8F);
        _secondaryColor = const Color(0xFFFFA7C2);

        _validWordsInLevel = <String>{
          'kırmızı',
          'mavi',
          'sarı',
          'yeşil',
          'turuncu',
          'mor',
          'pembe',
          'kahverengi',
          'siyah',
          'beyaz',
          'gri',
          'bej',
          'turkuaz',
          'bordo',
          'lacivert',
          'açık mavi',
          'koyu yeşil',
          'morötesi',
          'kızıl',
          'gül kurusu',
        };

        _wordColors = <String, Color>{
          'kırmızı': Colors.red.shade600,
          'mavi': Colors.blue.shade600,
          'sarı': Colors.yellow.shade600,
          'yeşil': Colors.green.shade600,
          'turuncu': Colors.orange.shade600,
          'mor': Colors.purple.shade600,
          'pembe': Colors.pink.shade400,
          'kahverengi': Colors.brown.shade600,
          'siyah': Colors.black87,
          'beyaz': Colors.grey.shade200,
          'gri': Colors.grey.shade500,
          'bej': Colors.amber.shade200,
          'turkuaz': Colors.teal.shade400,
          'bordo': Colors.red.shade900,
          'lacivert': Colors.indigo.shade900,
          'açık mavi': Colors.lightBlue.shade400,
          'koyu yeşil': Colors.green.shade900,
          'morötesi': Colors.deepPurple.shade400,
          'kızıl': Colors.deepOrange.shade900,
          'gül kurusu': Colors.pink.shade200,
        };

        introMessages = <String>[
          "Merhaba $playerName! Ben $selectedCharacter. Renkler ülkesine hoş geldin! 🎨",
          "Bu bölümde birbirinden güzel renkleri öğreneceğiz. 🌈",
          "Mikrofona dokun ve bir renk söyle. Mesela “kırmızı”. 🎤",
          "Doğru söylersen kelimenin harflerini karıştırıp bulmaca oluşturacağız. 🧩",
          "Hazırsan başlayalım!",
        ];
        break;

      case 1:
        _categoryName = 'Hayvanlar';
        _levelTitle = 'Bir Hayvan Söyle';
        _spokenWordsKey = 'spokenAnimalsWords';
        _categoryIcon = Icons.pets_rounded;
        _primaryColor = const Color(0xFFFFA726);
        _secondaryColor = const Color(0xFFFFD180);

        _validWordsInLevel = <String>{
          'kedi',
          'köpek',
          'aslan',
          'kaplan',
          'fil',
          'zürafa',
          'tavşan',
          'ayı',
          'penguen',
          'kuş',
          'maymun',
          'timsah',
          'yılan',
          'balık',
          'at',
          'koyun',
          'inek',
          'fare',
          'tilki',
          'kartal',
        };

        _wordColors = <String, Color>{
          for (final word in _validWordsInLevel) word: const Color(0xFFFFA726),
        };

        introMessages = <String>[
          "Harika $playerName! Hayvanlar ülkesindesin! 🦁",
          "Şimdi senden bir hayvan adı söylemeni istiyorum. 🎤",
          "Mesela “kedi” veya “köpek” diyebilirsin. 🐶",
          "Doğru kelimeden sonra harf bulmacası başlayacak. 🧩",
          "Hazırsan mikrofona dokun!",
        ];
        break;

      case 2:
        _categoryName = 'Eşyalar';
        _levelTitle = 'Bir Eşya Söyle';
        _spokenWordsKey = 'spokenObjectsWords';
        _categoryIcon = Icons.chair_alt_rounded;
        _primaryColor = const Color(0xFF26A69A);
        _secondaryColor = const Color(0xFF80CBC4);

        _validWordsInLevel = <String>{
          'masa',
          'sandalye',
          'kitap',
          'kalem',
          'çanta',
          'ayna',
          'telefon',
          'lamba',
          'bardak',
          'saat',
          'bilgisayar',
          'televizyon',
          'dolap',
          'halı',
          'perde',
          'yatak',
          'yastık',
          'battaniye',
          'kapı',
          'pencere',
        };

        _wordColors = <String, Color>{
          for (final word in _validWordsInLevel) word: const Color(0xFF26A69A),
        };

        introMessages = <String>[
          "Vay canına $playerName! Eşyalar ülkesindesin! 📦",
          "Etrafında gördüğün bir eşyanın adını söyleyebilirsin. 🎤",
          "Mesela “masa” veya “kitap”. 📚",
          "Doğru kelimeyi bulunca harf bulmacası açılacak. 🧩",
          "Hazırsan başlayalım!",
        ];
        break;

      default:
        _categoryName = 'Bilinmeyen Bölüm';
        _levelTitle = 'Bir Kelime Söyle';
        _spokenWordsKey = 'unknownWords';
        introMessages = <String>['Bu bölüm henüz hazır değil.'];
        break;
    }
  }

  Future<void> _loadPrefsAndSetup() async {
    final prefs = await SharedPreferences.getInstance();

    selectedCharacter = prefs.getString('selectedCharacter') ?? 'Ferhat';
    playerName = prefs.getString('playerName') ?? 'Arkadaşım';

    _initializeLevelData();

    final hasSeenIntro = prefs.getBool('${_spokenWordsKey}IntroShown') ?? false;

    if (!mounted) return;

    setState(() {
      showIntroMessages = !hasSeenIntro;
      allowVoiceInput = hasSeenIntro;
    });
  }

  Future<void> _nextIntroMessage() async {
    if (currentMessageIndex < introMessages.length - 1) {
      setState(() {
        currentMessageIndex++;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_spokenWordsKey}IntroShown', true);

    if (!mounted) return;

    setState(() {
      showIntroMessages = false;
      allowVoiceInput = true;
      currentMessageIndex = 0;
    });
  }

  Future<void> _listen() async {
    if (!allowVoiceInput || _isListening) return;

    final available = await _speech.initialize();

    if (!available) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(
          message: 'Mikrofon kullanılamıyor veya izin verilmedi.',
          icon: Icons.mic_off_rounded,
          backgroundColor: const Color(0xFF183153),
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isListening = true;
      _recognizedWord = '';
    });

    _micPulseController.repeat(reverse: true);

    await _speech.listen(
      onResult: (result) {
        if (!result.finalResult) return;

        final word = result.recognizedWords.toLowerCase().trim();
        _finishListening();

        if (word.isEmpty) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            _buildSnackBar(
              message: 'Seni anlayamadım. Bir kez daha deneyelim.',
              icon: Icons.hearing_disabled_rounded,
              backgroundColor: const Color(0xFF183153),
            ),
          );
          return;
        }

        _handleRecognizedWord(word);
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 3),
      localeId: 'tr_TR',
    );
  }

  void _finishListening() {
    _micPulseController
      ..stop()
      ..reset();

    if (!mounted) return;

    setState(() {
      _isListening = false;
    });
  }

  void _handleRecognizedWord(String word) {
    final completedWords = GameState.instance.getCompletedWords(
      widget.levelIndex,
    );

    if (_validWordsInLevel.contains(word)) {
      if (completedWords.contains(word)) {
        GameState.instance.loseLife();
        _showAlreadySpokenDialog(word);
        return;
      }

      setState(() {
        _recognizedWord = word;
        _lastSpokenCorrectWord = word;
      });

      GameState.instance.addScore(20);
      GameState.instance.addCurrentLevelScore(20);

      _showMascotPeek(fromRight: true);

      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(
          message: 'Harika! ${word.toUpperCase()} doğru bir kelime.',
          icon: Icons.check_circle_rounded,
          backgroundColor: const Color(0xFF2EAD62),
        ),
      );
      return;
    }

    GameState.instance.loseLife();
    _showMascotPeek(fromRight: false);

    setState(() {
      _recognizedWord = word;
      _lastSpokenCorrectWord = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        message: '“${word.toUpperCase()}” bu bölümde yok. Bir can kaybettin.',
        icon: Icons.close_rounded,
        backgroundColor: const Color(0xFFE8505B),
      ),
    );
  }

  SnackBar _buildSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(18),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.fredoka(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAlreadySpokenDialog(String word) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(Icons.info_rounded, color: Color(0xFFFFA726)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bu kelime tamamlandı',
                  style: GoogleFonts.fredoka(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            '“${word.toUpperCase()}” kelimesini daha önce başarıyla tamamladın. Başka bir kelime söylemelisin.',
            style: GoogleFonts.fredoka(fontSize: 16, height: 1.4),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(backgroundColor: _primaryColor),
              child: Text(
                'Tamam',
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    setState(() {
      _recognizedWord = '';
      _lastSpokenCorrectWord = '';
    });
  }

  Future<void> _goToShuffleLetters() async {
    if (_lastSpokenCorrectWord.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(
          message: 'Önce doğru bir kelime söylemelisin.',
          icon: Icons.mic_rounded,
          backgroundColor: const Color(0xFF183153),
        ),
      );
      return;
    }

    final completedWord = _lastSpokenCorrectWord;

    final result = await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => LetterShuffle(
          word: completedWord,
          colorName: widget.levelIndex == 0 ? completedWord : '',
          levelIndex: widget.levelIndex,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      _wordSuccessfullyCompleted(completedWord);
    } else {
      setState(() {
        _recognizedWord = '';
        _lastSpokenCorrectWord = '';
      });
    }
  }

  void _wordSuccessfullyCompleted(String word) {
    GameState.instance.addCompletedWord(widget.levelIndex, word);
    _checkLevelCompletion();

    if (!mounted) return;

    setState(() {
      _recognizedWord = '';
      _lastSpokenCorrectWord = '';
    });
  }

  void _checkLevelCompletion() {
    final currentLevelTargetScore = _getLevelTargetScore(widget.levelIndex);
    final totalWordsInLevel = _validWordsInLevel.length;
    final completedWordsCount = GameState.instance.getCompletedWordsCount(
      widget.levelIndex,
    );

    if (totalWordsInLevel == 0) return;

    final completionPercentage =
        (completedWordsCount / totalWordsInLevel) * 100;

    final completedByTarget =
        GameState.instance.currentLevelScore >= currentLevelTargetScore &&
        completionPercentage >= 80;

    final completedAllWords = completedWordsCount == totalWordsInLevel;

    if (completedByTarget || completedAllWords) {
      GameState.instance.completeLevel(widget.levelIndex);
      _showLevelCompletedDialog();
    }
  }

  int _getLevelTargetScore(int levelIndex) {
    switch (levelIndex) {
      case 0:
        return 150;
      case 1:
        return 200;
      case 2:
        return 250;
      default:
        return 99999;
    }
  }

  Future<void> _showLevelCompletedDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: Column(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFFFC83D),
                size: 60,
              ),
              const SizedBox(height: 8),
              Text(
                'Seviye Tamamlandı!',
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            'Tebrikler! $_categoryName bölümünü başarıyla tamamladın. Bir sonraki seviye artık açık.',
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(fontSize: 16, height: 1.4),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _goBackToLevels();
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E64F0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
              ),
              icon: const Icon(Icons.map_rounded),
              label: Text(
                'Seviyelere Dön',
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _goBackToLevels() {
    GameState.instance.resetCurrentLevelScore();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LevelsScreen()),
      (route) => false,
    );
  }

  void _showNotebook() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final completedWords = GameState.instance.getCompletedWords(
          widget.levelIndex,
        );

        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF9FBFF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _primaryColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kelime Defteri',
                                style: GoogleFonts.fredoka(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF183153),
                                ),
                              ),
                              Text(
                                '${completedWords.length} / ${_validWordsInLevel.length} kelime tamamlandı',
                                style: GoogleFonts.fredoka(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                      itemCount: _validWordsInLevel.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 9),
                      itemBuilder: (context, index) {
                        final word = _validWordsInLevel.elementAt(index);
                        final isCompleted = completedWords.contains(word);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFFEAF8EF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isCompleted
                                  ? const Color(0xFFA8DFB7)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? const Color(0xFF2EAD62)
                                      : const Color(0xFFE8EDF5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCompleted
                                      ? Icons.check_rounded
                                      : Icons.lock_open_rounded,
                                  size: 19,
                                  color: isCompleted
                                      ? Colors.white
                                      : const Color(0xFF7C8796),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  word.toUpperCase(),
                                  style: GoogleFonts.fredoka(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isCompleted
                                        ? const Color(0xFF23844A)
                                        : const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final maxWidth = isTablet ? 650.0 : 500.0;

    return Scaffold(
      body: Stack(
        children: [
          _VoiceBackground(
            primaryColor: _primaryColor,
            secondaryColor: _secondaryColor,
          ),
          _PeekingMascot(
            visible: _mascotVisible && !showIntroMessages,
            fromRight: _mascotFromRight,
            primaryColor: _primaryColor,
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(isTablet),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          isTablet ? 56 : 20,
                          18,
                          isTablet ? 56 : 20,
                          34,
                        ),
                        child: FadeTransition(
                          opacity: _entranceOpacity,
                          child: SlideTransition(
                            position: _entranceSlide,
                            child: showIntroMessages
                                ? _buildIntroCard(isTablet)
                                : _buildGameContent(isTablet),
                          ),
                        ),
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

  Widget _buildTopBar(bool isTablet) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 16,
        10,
        isTablet ? 32 : 16,
        8,
      ),
      child: Row(
        children: [
          _RoundTopButton(
            icon: Icons.arrow_back_rounded,
            onPressed: _goBackToLevels,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _categoryName,
                  style: GoogleFonts.fredoka(
                    fontSize: isTablet ? 29 : 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        offset: const Offset(0, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                Text(
                  'Seviye ${widget.levelIndex + 1}',
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
          _StatusChip(
            icon: Icons.star_rounded,
            color: const Color(0xFFFFD54F),
            text: '${GameState.instance.currentLevelScore}',
          ),
          const SizedBox(width: 8),
          _StatusChip(
            icon: Icons.favorite_rounded,
            color: const Color(0xFFFF5C77),
            text: '${GameState.instance.lives}',
          ),
          const SizedBox(width: 8),
          _RoundTopButton(
            icon: Icons.menu_book_rounded,
            onPressed: _showNotebook,
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(bool isTablet) {
    return Column(
      children: [
        const SizedBox(height: 26),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 26 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                introMessages[currentMessageIndex],
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: isTablet ? 23 : 19,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: const Color(0xFF183153),
                ),
              ),
              const SizedBox(height: 22),
              LinearProgressIndicator(
                value: (currentMessageIndex + 1) / introMessages.length,
                minHeight: 7,
                borderRadius: BorderRadius.circular(10),
                backgroundColor: const Color(0xFFE8EDF5),
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _nextIntroMessage,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: Icon(
                    currentMessageIndex == introMessages.length - 1
                        ? Icons.play_arrow_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    currentMessageIndex == introMessages.length - 1
                        ? 'Başlayalım'
                        : 'Devam Et',
                    style: GoogleFonts.fredoka(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameContent(bool isTablet) {
    final completedCount = GameState.instance.getCompletedWordsCount(
      widget.levelIndex,
    );
    final totalCount = _validWordsInLevel.length;
    final progress = totalCount == 0
        ? 0.0
        : (completedCount / totalCount).clamp(0.0, 1.0);

    return Column(
      children: [
        _buildProgressCard(
          completedCount: completedCount,
          totalCount: totalCount,
          progress: progress,
        ),
        SizedBox(height: isTablet ? 24 : 18),
        _buildPromptCard(isTablet),
        SizedBox(height: isTablet ? 28 : 22),
        _buildMicrophoneButton(isTablet),
        const SizedBox(height: 15),
        Text(
          _isListening ? 'Seni dinliyorum...' : 'Konuşmak için mikrofona dokun',
          textAlign: TextAlign.center,
          style: GoogleFonts.fredoka(
            fontSize: isTablet ? 19 : 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.18),
                offset: const Offset(0, 2),
                blurRadius: 5,
              ),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 28 : 22),
        _buildRecognizedWordCard(isTablet),
        const SizedBox(height: 18),
        _buildShuffleButton(),
      ],
    );
  }

  Widget _buildProgressCard({
    required int completedCount,
    required int totalCount,
    required double progress,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(_categoryIcon, color: _primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bölüm İlerlemesi',
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF183153),
                        ),
                      ),
                    ),
                    Text(
                      '$completedCount / $totalCount',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE8EDF5),
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 25 : 20,
        vertical: isTablet ? 21 : 17,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(25),
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
          Icon(
            Icons.chat_bubble_rounded,
            color: _primaryColor,
            size: isTablet ? 32 : 27,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              _levelTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: isTablet ? 26 : 21,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF183153),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Icon(_categoryIcon, color: _primaryColor, size: isTablet ? 32 : 27),
        ],
      ),
    );
  }

  Widget _buildMicrophoneButton(bool isTablet) {
    final size = isTablet ? 154.0 : 126.0;

    return ScaleTransition(
      scale: _isListening ? _micPulse : const AlwaysStoppedAnimation<double>(1),
      child: GestureDetector(
        onTap: allowVoiceInput ? _listen : null,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isListening
                  ? const [Color(0xFFFF6B6B), Color(0xFFE53935)]
                  : [_secondaryColor, _primaryColor],
            ),
            border: Border.all(color: Colors.white, width: 5),
            boxShadow: [
              BoxShadow(
                color: (_isListening ? const Color(0xFFE53935) : _primaryColor)
                    .withValues(alpha: 0.42),
                blurRadius: _isListening ? 35 : 24,
                spreadRadius: _isListening ? 8 : 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
            color: Colors.white,
            size: size * 0.46,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 4),
                blurRadius: 7,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecognizedWordCard(bool isTablet) {
    final hasWord = _recognizedWord.isNotEmpty;
    final isCorrect = _validWordsInLevel.contains(_recognizedWord);

    final displayColor = !hasWord
        ? const Color(0xFF718096)
        : isCorrect
        ? const Color(0xFF2EAD62)
        : const Color(0xFFE8505B);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isTablet ? 24 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: hasWord ? displayColor.withValues(alpha: 0.45) : Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 17,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            hasWord ? 'ALGILANAN KELİME' : 'KELİMEN BURADA GÖRÜNECEK',
            style: GoogleFonts.fredoka(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Text(
              hasWord ? _recognizedWord.toUpperCase() : '...',
              key: ValueKey<String>(_recognizedWord),
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: isTablet ? 39 : 31,
                fontWeight: FontWeight.w700,
                color: displayColor,
              ),
            ),
          ),
          if (hasWord) ...[
            const SizedBox(height: 7),
            Icon(
              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: displayColor,
              size: 26,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShuffleButton() {
    final enabled = _lastSpokenCorrectWord.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: enabled ? _goToShuffleLetters : null,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFFC83D),
          foregroundColor: const Color(0xFF6D3E00),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.55),
          disabledForegroundColor: const Color(0xFF7C8796),
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: enabled ? 7 : 0,
          shadowColor: const Color(0xFFB66A00),
        ),
        icon: const Icon(Icons.extension_rounded, size: 27),
        label: Text(
          'HARFLERİ KARIŞTIR',
          style: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _VoiceBackground extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;

  const _VoiceBackground({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, secondaryColor, const Color(0xFFBFE2FF)],
            ),
          ),
        ),
        Positioned(
          top: 95,
          left: -35,
          child: Icon(
            Icons.cloud_rounded,
            size: 150,
            color: Colors.white.withValues(alpha: 0.28),
          ),
        ),
        Positioned(
          top: 200,
          right: -45,
          child: Icon(
            Icons.cloud_rounded,
            size: 175,
            color: Colors.white.withValues(alpha: 0.22),
          ),
        ),
        const Positioned(
          top: 145,
          right: 60,
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 24,
            color: Color(0x99FFFFFF),
          ),
        ),
        const Positioned(
          bottom: 130,
          left: 44,
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: Color(0x80FFFFFF),
          ),
        ),
      ],
    );
  }
}

class _PeekingMascot extends StatelessWidget {
  final bool visible;
  final bool fromRight;
  final Color primaryColor;

  const _PeekingMascot({
    required this.visible,
    required this.fromRight,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final mascotSize = MediaQuery.of(context).size.shortestSide >= 600
        ? 150.0
        : 112.0;
    final hiddenOffset = mascotSize * 0.72;
    final visibleOffset = mascotSize * 0.36;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 620),
      curve: visible ? Curves.easeOutBack : Curves.easeInCubic,
      top: screenHeight * 0.34,
      left: fromRight ? null : (visible ? -visibleOffset : -hiddenOffset),
      right: fromRight ? (visible ? -visibleOffset : -hiddenOffset) : null,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: visible ? 1 : 0.72,
          child: Transform.rotate(
            angle: fromRight ? -0.08 : 0.08,
            child: Container(
              width: mascotSize,
              height: mascotSize,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
                border: Border.all(color: const Color(0xFFFFE69A), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
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
                          Icons.sentiment_very_satisfied_rounded,
                          size: 58,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundTopButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundTopButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 23),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _StatusChip({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.fredoka(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
