// lib/screens/manual_write.dart
import 'package:flutter/material.dart';
import 'package:kelime_kralligi/screens/voice_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kelime_kralligi/widgets/life_indicator.dart';
import 'package:kelime_kralligi/widgets/score_indicator.dart';
import 'package:kelime_kralligi/providers/game_state.dart';
import 'dart:async';
import 'package:kelime_kralligi/screens/levels_screen.dart';
import 'dart:math';

class ManualWrite extends StatefulWidget {
  final int levelIndex;
  final String word;
  final String colorName;

  const ManualWrite({
    super.key,
    required this.levelIndex,
    required this.word,
    required this.colorName,
  });

  @override
  State<ManualWrite> createState() => _ManualWriteState();
}

class _ManualWriteState extends State<ManualWrite> {
  final TextEditingController _controller = TextEditingController();
  String _recognizedWord = '';
  Color _themeColor = Colors.white;
  bool _isTextDark = true;

  Set<String> _validWordsInLevel = {};
  Map<String, Color> _wordColors = {};
  String _levelTitle = '';
  String _writtenWordsKey = '';

  List<String> introMessages = [];
  int currentMessageIndex = 0;
  bool showIntroMessages = false;
  bool allowManualInput = false;
  String playerName = 'Arkadaşım';
  String selectedCharacter = 'Ferhat';

  int _consecutiveCorrectAnswers = 0;
  DateTime? _startTime;
  Timer? _timer;
  int _elapsedSeconds = 0;

  static const int _maxManualWriteTimeBonus = 100;
  static const int _manualWriteTimeLimitSeconds = 15;

  final List<String> _congratulationMessages = [
    "Harika iş çıkardın! Mükemmel! 🎉",
    "Tebrikler! Bir kelimeyi daha öğrendin. 🌟",
    "İnanılmazsın! Doğru bildin! ✨",
    "Bravo! Kelime bilgini geliştiriyorsun. 🚀",
    "Süpersin! Kelime Krallığı'na bir adım daha yaklaştın. 👑",
    "Muhteşem! Başarı seninle! 🌈",
    "Helal olsun! Tam isabet! 🎯",
    "Çok iyi! Öğrenmeye devam! 📚"
  ];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeLevelData();
    _loadPrefsAndSetup();
    _setThemeColors(widget.colorName);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _startTime = DateTime.now();
    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
        });
      }
    });
  }

  void _initializeLevelData() {
    switch (widget.levelIndex) {
      case 0:
        _validWordsInLevel = {
          'kırmızı', 'mavi', 'sarı', 'yeşil', 'turuncu',
          'mor', 'pembe', 'kahverengi', 'siyah', 'beyaz',
          'gri', 'bej', 'turkuaz', 'bordo', 'lacivert',
          'açık mavi', 'koyu yeşil', 'morötesi', 'kızıl', 'gül kurusu',
        };
        _wordColors = {
          'kırmızı': Colors.red.shade200, 'mavi': Colors.blue.shade200,
          'sarı': Colors.yellow.shade200, 'yeşil': Colors.green.shade200,
          'turuncu': Colors.orange.shade200, 'mor': Colors.purple.shade200,
          'pembe': Colors.pink.shade200, 'kahverengi': Colors.brown.shade200,
          'siyah': Colors.grey.shade800, 'beyaz': Colors.white,
          'gri': Colors.grey.shade400, 'bej': Colors.amber.shade50,
          'turkuaz': Colors.teal.shade200, 'bordo': Colors.red.shade900,
          'lacivert': Colors.indigo.shade800, 'açık mavi': Colors.lightBlue.shade200,
          'koyu yeşil': Colors.green.shade800, 'morötesi': Colors.deepPurple.shade200,
          'kızıl': Colors.deepOrange.shade900, 'gül kurusu': Colors.pink.shade100,
        };
        _levelTitle = 'Bir Renk Yazın';
        _writtenWordsKey = 'writtenColorsWords';
        introMessages = [
          "Harfleri sıraladın, çok iyi! 👍 Şimdi kelimeyi yazarak onaylama zamanı. ✍️",
          "Kelimeni aşağıdaki kutucuğa doğru bir şekilde yaz ve kontrol et düğmesine bas. 🚀"
        ];
        break;
      case 1:
        _validWordsInLevel = {
          'kedi', 'köpek', 'aslan', 'kaplan', 'fil',
          'zürafa', 'tavşan', 'ayı', 'penguen', 'kuş',
          'maymun', 'timsah', 'yılan', 'balık', 'at',
          'koyun', 'inek', 'fare', 'tilki', 'kartal',
        };
        _wordColors = {
          'kedi': Colors.amber.shade200, 'köpek': Colors.amber.shade200,
          'aslan': Colors.amber.shade200, 'kaplan': Colors.amber.shade200,
          'fil': Colors.amber.shade200, 'zürafa': Colors.amber.shade200,
          'tavşan': Colors.amber.shade200, 'ayı': Colors.amber.shade200,
          'penguen': Colors.amber.shade200, 'kuş': Colors.amber.shade200,
          'maymun': Colors.brown.shade200, 'timsah': Colors.green.shade700,
          'yılan': Colors.lightGreen.shade200, 'balık': Colors.lightBlue.shade200,
          'at': Colors.brown.shade600, 'koyun': Colors.grey.shade200,
          'inek': Colors.brown.shade400, 'fare': Colors.blueGrey.shade100,
          'tilki': Colors.orange.shade400, 'kartal': Colors.grey.shade700,
        };
        _levelTitle = 'Bir Hayvan Yazın';
        _writtenWordsKey = 'writtenAnimalsWords';
        introMessages = [
          "Harfleri sıraladın, çok iyi! 👍 Şimdi kelimeyi yazarak onaylama zamanı. ✍️",
          "Kelimeni aşağıdaki kutucuğa doğru bir şekilde yaz ve kontrol et düğmesine bas. 🚀"
        ];
        break;
      case 2:
        _validWordsInLevel = {
          'masa', 'sandalye', 'kitap', 'kalem', 'çanta', 'ayna', 'telefon',
          'lamba', 'bardak', 'saat', 'bilgisayar', 'televizyon',
          'dolap', 'halı', 'perde', 'yatak', 'yastık',
          'battaniye', 'kapı', 'pencere',
        };
        _wordColors = {
          'masa': Colors.brown.shade200, 'sandalye': Colors.orange.shade200,
          'kitap': Colors.indigo.shade200, 'kalem': Colors.green.shade200,
          'çanta': Colors.teal.shade200, 'ayna': Colors.blueGrey.shade200,
          'telefon': Colors.blue.shade200, 'lamba': Colors.yellow.shade200,
          'bardak': Colors.cyan.shade200, 'saat': Colors.red.shade200,
          'bilgisayar': Colors.grey.shade600, 'televizyon': Colors.blueGrey.shade800,
          'dolap': Colors.brown.shade400, 'halı': Colors.deepOrange.shade100,
          'perde': Colors.pink.shade50, 'yatak': Colors.lightBlue.shade50,
          'yastık': Colors.lightGreen.shade50, 'battaniye': Colors.purple.shade50,
          'kapı': Colors.brown.shade500, 'pencere': Colors.blue.shade50,
        };
        _levelTitle = 'Bir Eşya Yazın';
        _writtenWordsKey = 'writtenObjectsWords';
        introMessages = [
          "Harfleri sıraladın, çok iyi! 👍 Şimdi kelimeyi yazarak onaylama zamanı. ✍️",
          "Kelimeni aşağıdaki kutucuğa doğru bir şekilde yaz ve kontrol et düğmesine bas. 🚀"
        ];
        break;
      default:
        _validWordsInLevel = {};
        _levelTitle = 'Bilinmeyen Seviye';
        _writtenWordsKey = 'unknownWords';
        introMessages = ["Hata: Bilinmeyen seviye."];
        break;
    }
  }

  void _setThemeColors(String colorName) {
    if (mounted) {
      setState(() {
        if (widget.levelIndex == 0 && _wordColors.containsKey(colorName.toLowerCase())) {
          _themeColor = _wordColors[colorName.toLowerCase()]!;
          _isTextDark = _themeColor.computeLuminance() > 0.5;
        } else {
          switch (widget.levelIndex) {
            case 0:
              _themeColor = Colors.grey.shade200;
              _isTextDark = true;
              break;
            case 1:
              _themeColor = Colors.lightGreen.shade200;
              _isTextDark = true;
              break;
            case 2:
              _themeColor = Colors.blueGrey.shade100;
              _isTextDark = true;
              break;
            default:
              _themeColor = Colors.grey.shade300;
              _isTextDark = true;
              break;
          }
        }
      });
    }
  }

  Future<void> _loadPrefsAndSetup() async {
    final prefs = await SharedPreferences.getInstance();
    selectedCharacter = prefs.getString('selectedCharacter') ?? 'Ferhat';
    playerName = prefs.getString('playerName') ?? 'Arkadaşım';
    final hasSeenIntro = prefs.getBool('${_writtenWordsKey}IntroShownManual') ?? false;

    if (mounted) {
      if (!hasSeenIntro) {
        setState(() {
          showIntroMessages = true;
          allowManualInput = false;
        });
      } else {
        setState(() => allowManualInput = true);
      }
    }
  }

  void _nextIntroMessage() async {
    if (currentMessageIndex < introMessages.length - 1) {
      if (mounted) {
        setState(() => currentMessageIndex++);
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_writtenWordsKey}IntroShownManual', true);
      if (mounted) {
        setState(() {
          showIntroMessages = false;
          allowManualInput = true;
        });
      }
    }
  }

  int _calculateTimeBonus(Duration elapsedTime, int maxBonus, int timeLimitSeconds) {
    double elapsedSeconds = elapsedTime.inMilliseconds / 1000.0;
    if (elapsedSeconds >= timeLimitSeconds) {
      return 0;
    }
    double bonus = maxBonus * (1 - (elapsedSeconds / timeLimitSeconds));
    return bonus.round();
  }

  void _checkWord() {
    if (!allowManualInput) return;
    _timer?.cancel();

    final enteredWord = _controller.text.toLowerCase().trim();
    final targetWord = widget.word.toLowerCase().trim();

    if (enteredWord == targetWord) {
      if (mounted) {
        setState(() {
          _recognizedWord = enteredWord;
        });
      }
      _handleCorrectAnswer();
    } else {
      GameState.instance.loseLife();
      if (mounted) {
        _resetTheme();
        _consecutiveCorrectAnswers = 0;
        _showIncorrectDialog("Yanlış kelimeyi yazdın. Bir can kaybettin.");
      }
      _startTimer();
    }
    _controller.clear();
  }

  void _handleCorrectAnswer() {
    _consecutiveCorrectAnswers++;
    int pointsEarned = 0;
    if (_consecutiveCorrectAnswers == 1) {
      pointsEarned = 50;
    } else if (_consecutiveCorrectAnswers == 2) {
      pointsEarned = 75;
    } else if (_consecutiveCorrectAnswers >= 3) {
      pointsEarned = 100;
    }

    final Duration elapsedTime = DateTime.now().difference(_startTime!);
    final int timeBonus = _calculateTimeBonus(elapsedTime, _maxManualWriteTimeBonus, _manualWriteTimeLimitSeconds);

    GameState.instance.addScore(pointsEarned + timeBonus);
    GameState.instance.addCurrentLevelScore(pointsEarned + timeBonus);
    GameState.instance.addCompletedWord(widget.levelIndex, widget.word);

    _checkLevelCompletion();
  }

  void _showIncorrectDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Yanlış Tahmin!"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  void _resetTheme() {
    if (mounted) {
      setState(() {
        _recognizedWord = '';
        _setThemeColors(widget.colorName);
      });
    }
  }

  void _checkLevelCompletion() {
    final currentLevelTargetScore = _getLevelTargetScore(widget.levelIndex);
    final totalWordsInLevel = _validWordsInLevel.length;
    final completedWordsCount = GameState.instance.getCompletedWordsCount(widget.levelIndex);
    final completionPercentage = (completedWordsCount / totalWordsInLevel) * 100;

    if (GameState.instance.currentLevelScore >= currentLevelTargetScore && completionPercentage >= 80) {
      GameState.instance.completeLevel(widget.levelIndex);
      if (mounted) _showLevelCompletedDialog(true);
    } else {
      if (completedWordsCount == totalWordsInLevel) {
        GameState.instance.completeLevel(widget.levelIndex);
        if (mounted) _showLevelCompletedDialog(true);
      } else {
        if (mounted) _showLevelCompletedDialog(false);
      }
    }
  }

  int _getLevelTargetScore(int levelIndex) {
    switch (levelIndex) {
      case 0: return 150;
      case 1: return 200;
      case 2: return 250;
      default: return 99999;
    }
  }

  void _showLevelCompletedDialog(bool levelUp) {
    if (!mounted) return;
    String title;
    String content;
    List<Widget> actions;

    if (levelUp) {
      title = "Seviye Tamamlandı!";
      content = "Tebrikler! ${_levelTitle.replaceFirst('Bir ', '').replaceFirst(' Yazın', '')} seviyesini başarıyla tamamladın! Bir sonraki seviye artık açık.";
      actions = [
        TextButton(
          onPressed: () {
            if (mounted) {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LevelsScreen()),
                (Route<dynamic> route) => false,
              );
            }
          },
          child: const Text("Devam Et (Seviyeler)"),
        ),
      ];
    } else {
      final String randomCongratulation = _congratulationMessages[_random.nextInt(_congratulationMessages.length)];
      title = "Tebrikler!";
      content = "$randomCongratulation “${widget.word.toUpperCase()}” kelimesini başarıyla tamamladın!";
      actions = [
        TextButton(
          onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => VoiceInput(
                    levelIndex:widget.levelIndex,
                    word: widget.word,
                    colorName: widget.colorName,
                  ),
                )
              );
          },
          child: const Text("Devam Et"),
        ),
      ];
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _isTextDark ? Colors.black : Colors.white;
    final bubbleColor = selectedCharacter == 'Hazal'
        ? Colors.pink.shade50.withValues(alpha: 0.98)
        : Colors.blue.shade50.withValues(alpha: 0.98);
    final bubbleBorder = Border.all(
      color: selectedCharacter == 'Hazal' ? Colors.pink : Colors.blue,
      width: 2,
    );

    return Scaffold(
      backgroundColor: _themeColor,
      appBar: AppBar(
        title: Text(_levelTitle),
        centerTitle: true,
        backgroundColor: _themeColor,
        foregroundColor: textColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _timer?.cancel();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LevelsScreen()),
              (route) => false,
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ScoreIndicator(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: LifeIndicator(backgroundColor: _themeColor),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: Text(
                'Süre: $_elapsedSeconds sn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (showIntroMessages)
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: _nextIntroMessage,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.circular(15),
                          border: bubbleBorder,
                        ),
                        child: Text(
                          introMessages[currentMessageIndex],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: selectedCharacter == 'Hazal' ? Colors.pink.shade700 : Colors.blue.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Kelimeni Yaz",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _controller,
                          maxLength: widget.word.length,
                          textCapitalization: TextCapitalization.none,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: textColor, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: textColor, width: 3),
                            ),
                            filled: true,
                            fillColor: _isTextDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.1),
                          ),
                          onSubmitted: (_) => _checkWord(),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _checkWord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTextDark ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Kontrol Et",
                            style: TextStyle(
                              color: _isTextDark ? Colors.white : Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_recognizedWord.isNotEmpty)
                          Text(
                            "Doğru: $_recognizedWord",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}