// lib/screens/voice_input.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:kelime_kralligi/screens/letter_shuffle.dart';
import 'package:kelime_kralligi/screens/levels_screen.dart';
import 'package:kelime_kralligi/game_state.dart';

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

class _VoiceInputState extends State<VoiceInput> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedWord = '';
  String _lastSpokenCorrectWord = '';
  Color _themeColor = Colors.white;
  bool _isTextDark = true;
  bool _showNotebook = false;
  late AnimationController _notebookController;
  late Animation<Offset> _slideAnimation;

  Set<String> _validWordsInLevel = {};
  Map<String, Color> _wordColors = {};
  String _levelTitle = '';
  String _spokenWordsKey = '';

  List<String> introMessages = [];
  int currentMessageIndex = 0;
  bool showIntroMessages = false;
  bool allowVoiceInput = false;
  String playerName = 'Arkadaşım';
  String selectedCharacter = 'Ferhat';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _notebookController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _notebookController,
      curve: Curves.easeOut,
    ));
    _initializeLevelData();
    _loadPrefsAndSetup();
  }

  @override
  void dispose() {
    _notebookController.dispose();
    super.dispose();
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
        _levelTitle = 'Bir Renk Söyleyin';
        _spokenWordsKey = 'spokenColorsWords';
        introMessages = [
          "Merhaba $playerName! Ben $selectedCharacter. Kelime Krallığına hoş geldin! 🎨",
          "Şimdi sana renkleri öğreteceğim. Hazır mısın? 🌈",
          "Bana bir renk adı söylemeni istiyorum. Mesela 'kırmızı' gibi. 🎤",
          "Doğru söylersen, o rengi kullanarak harfleri karıştırıp bir bulmaca oluşturacağım! 🧩",
          "Haydi, mikrofona dokun ve ilk rengi söyle!",
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
          'kedi': Colors.amber.shade400,
          'köpek': Colors.amber.shade400,
          'aslan': Colors.amber.shade600,
          'kaplan': Colors.orange.shade700,
          'fil': Colors.grey.shade600,
          'zürafa': Colors.amber.shade200,
          'tavşan': Colors.grey.shade300,
          'ayı': Colors.brown.shade700,
          'penguen': Colors.grey.shade800,
          'kuş': Colors.blue.shade400,
          'maymun': Colors.brown.shade400,
          'timsah': Colors.green.shade900,
          'yılan': Colors.green.shade600,
          'balık': Colors.lightBlue.shade400,
          'at': Colors.brown.shade600,
          'koyun': Colors.grey.shade200,
          'inek': Colors.brown.shade400,
          'fare': Colors.blueGrey.shade200,
          'tilki': Colors.orange.shade500,
          'kartal': Colors.grey.shade700,
        };
        _levelTitle = 'Bir Hayvan Söyleyin';
        _spokenWordsKey = 'spokenAnimalsWords';
        introMessages = [
          "Harika $playerName! Yeni bir seviyedesin! 🦁",
          "Şimdi senden bir hayvan ismi söylemeni istiyorum. 🎤",
          "Mesela 'kedi' veya 'köpek' gibi. 🐶",
          "Unutma, doğru söylersen harfleri karıştıracağız! 🧩",
          "Hazırsan mikrofona dokunabilirsin!",
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
          'masa': Colors.brown.shade500,
          'sandalye': Colors.orange.shade400,
          'kitap': Colors.indigo.shade600,
          'kalem': Colors.green.shade600,
          'çanta': Colors.teal.shade400,
          'ayna': Colors.blueGrey.shade300,
          'telefon': Colors.blue.shade600,
          'lamba': Colors.yellow.shade600,
          'bardak': Colors.cyan.shade400,
          'saat': Colors.red.shade400,
          'bilgisayar': Colors.grey.shade600,
          'televizyon': Colors.blueGrey.shade700,
          'dolap': Colors.brown.shade700,
          'halı': Colors.deepOrange.shade200,
          'perde': Colors.pink.shade200,
          'yatak': Colors.lightBlue.shade200,
          'yastık': Colors.lightGreen.shade200,
          'battaniye': Colors.purple.shade200,
          'kapı': Colors.brown.shade700,
          'pencere': Colors.blue.shade200,
        };
        _levelTitle = 'Bir Eşya Söyleyin';
        _spokenWordsKey = 'spokenObjectsWords';
        introMessages = [
          "Vay canına $playerName! Sıradaki seviyemiz eşyalar! 📦",
          "Şimdi etrafındaki eşyaların isimlerini söyleyebilir misin? 🎤",
          "Mesela 'masa' ya da 'kitap' gibi. 📚",
          "Doğru söylersen harflerini karıştırıp sana yeni bir bulmaca vereceğiz! 🧩",
          "Hazırsan mikrofona dokunabilirsin!",
        ];
        break;
      default:
        _validWordsInLevel = {};
        _levelTitle = 'Bilinmeyen Seviye';
        _spokenWordsKey = 'unknownWords';
        introMessages = ["Hata: Bilinmeyen seviye."];
        break;
    }
  }

  void _setThemeForNextWord(String word) {
    if (mounted) {
      setState(() {
        _themeColor = _wordColors[word.toLowerCase()] ?? Colors.white;
        _isTextDark = _themeColor.computeLuminance() > 0.5;
        _recognizedWord = '';
        _lastSpokenCorrectWord = '';
      });
    }
  }

  Future<void> _loadPrefsAndSetup() async {
    final prefs = await SharedPreferences.getInstance();
    selectedCharacter = prefs.getString('selectedCharacter') ?? 'Ferhat';
    playerName = prefs.getString('playerName') ?? 'Arkadaşım';
    final hasSeenIntro = prefs.getBool('${_spokenWordsKey}IntroShown') ?? false;

    if (!hasSeenIntro) {
      setState(() {
        showIntroMessages = true;
        allowVoiceInput = false;
      });
    } else {
      setState(() => allowVoiceInput = true);
      _setThemeForNextWord(_validWordsInLevel.isNotEmpty ? _validWordsInLevel.first : 'white');
    }
  }

  void _nextIntroMessage() async {
    if (currentMessageIndex < introMessages.length - 1) {
      setState(() => currentMessageIndex++);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_spokenWordsKey}IntroShown', true);
      if (mounted) {
        setState(() {
          showIntroMessages = false;
          allowVoiceInput = true;
        });
      }
      _setThemeForNextWord(_validWordsInLevel.isNotEmpty ? _validWordsInLevel.first : 'white');
    }
  }

    void _listen() async {
    if (!allowVoiceInput || _isListening) return;

    bool available = await _speech.initialize();
    if (available) {
      if (mounted) setState(() => _isListening = true);

      await _speech.listen(
  onResult: (val) {
    if (val.finalResult) {
      final word = val.recognizedWords.toLowerCase().trim();
      final completedWords =
          GameState.instance.getCompletedWords(widget.levelIndex);

      if (_validWordsInLevel.contains(word)) {
        if (!completedWords.contains(word)) {
          if (mounted) {
            setState(() {
              _recognizedWord = word;
              _lastSpokenCorrectWord = word;
              _themeColor =
                  _wordColors[word] ?? Colors.green.shade400;
              _isTextDark =
                  _themeColor.computeLuminance() > 0.5;
            });
          }

          GameState.instance.addScore(20);
          GameState.instance.addCurrentLevelScore(20);
        } else {
          GameState.instance.loseLife();

          if (mounted) {
            _showAlreadySpokenDialog(word);
            _resetTheme();
          }
        }
      } else if (word.isNotEmpty) {
        GameState.instance.loseLife();

        if (mounted) {
          _resetTheme();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Yanlış kelime: "${word.toUpperCase()}" veya algılanamadı. Bir can kaybettin.',
              ),
            ),
          );
        }
      }

      if (mounted) {
        setState(() => _isListening = false);
      }
    }
  },
  listenFor: const Duration(seconds: 5),
  pauseFor: const Duration(seconds: 3),
  localeId: 'tr_TR',
);
      
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mikrofon kullanılamıyor veya izin verilmedi.')),
      );
    }
  }

  void _resetTheme() {
    if (mounted) {
      setState(() {
        _recognizedWord = '';
        _themeColor = _wordColors[_validWordsInLevel.isNotEmpty ? _validWordsInLevel.first : 'white'] ?? Colors.white;
        _isTextDark = _themeColor.computeLuminance() > 0.5;
      });
    }
  }

  void _showAlreadySpokenDialog(String word) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Bu kelime zaten tamamlandı!"),
        content: Text("“${word.toUpperCase()}” kelimesi zaten başarıyla öğrenildi. Lütfen başka bir kelime deneyin."),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) {
                Navigator.pop(context);
                _resetTheme();
              }
            },
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  void _wordSuccessfullyCompleted(String word) {
    GameState.instance.addCompletedWord(widget.levelIndex, word);
    _checkLevelCompletion();
    _setThemeForNextWord(_validWordsInLevel.isNotEmpty ? _validWordsInLevel.first : 'white');
  }

  void _goToShuffleLetters() async {
    if (_lastSpokenCorrectWord.isNotEmpty) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LetterShuffle(
            word: _lastSpokenCorrectWord,
            colorName: widget.levelIndex == 0 ? _lastSpokenCorrectWord : '',
            levelIndex: widget.levelIndex,
          ),
        ),
      );
      if (mounted) {
        if (result != null && result is bool && result == true) {
          _wordSuccessfullyCompleted(_lastSpokenCorrectWord);
          _lastSpokenCorrectWord = '';
        } else {
          _resetTheme();
          _lastSpokenCorrectWord = '';
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce doğru kelimeyi söyleyin.')),
      );
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

  void _showLevelCompletedDialog(bool levelUp) {
    if (!mounted) return;
    String title;
    String content;
    List<Widget> actions;

    final totalWords = _validWordsInLevel.length;
    final completedWords = GameState.instance.getCompletedWordsCount(widget.levelIndex);

    if (levelUp) {
      title = "Seviye Tamamlandı!";
      content =
          "Tebrikler! ${_levelTitle.replaceFirst('Bir ', '').replaceFirst(' Söyleyin', '')} seviyesini başarıyla tamamladın! Bir sonraki seviye artık açık.";
      actions = [
        TextButton(
          onPressed: () {
            if (mounted) {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LevelsScreen()),
                (route) => false,
              );
            }
          },
          child: const Text("Devam Et (Seviyeler)"),
        ),
      ];
    } else {
      title = "Harika Başlangıç!";
      content =
          "Harika gidiyorsun! ${_levelTitle.replaceFirst('Bir ', '').replaceFirst(' Söyleyin', '')} seviyesinde $completedWords / $totalWords kelimeyi tamamladın. Devam et, öğrenmeye devam!";
      actions = [
        TextButton(
          onPressed: () {
            if (mounted) {
              Navigator.pop(context);
              _resetTheme();
            }
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

  Widget _buildLifeIndicator() {
    int lives = GameState.instance.lives;
    int maxLives = GameState.instance.maxLives;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (index) {
        return Icon(
          index < lives ? Icons.favorite : Icons.favorite_border,
          color: Colors.red.shade600,
        );
      }),
    );
  }

  Widget _buildScoreIndicator() {
    return Text(
      'Skor: ${GameState.instance.currentLevelScore}',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _isTextDark ? Colors.black87 : Colors.white;
    final bubbleColor = _isTextDark ? Colors.grey.shade100 : Colors.black54;
    final bubbleBorder = Border.all(color: textColor.withValues(alpha: 0.1), width: 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(_levelTitle),
        centerTitle: true,
        backgroundColor: _themeColor,
        foregroundColor: textColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GameState.instance.resetCurrentLevelScore();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LevelsScreen() ),
              (route) => false,
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _buildScoreIndicator(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _buildLifeIndicator(),
          ),
          IconButton(
            iconSize: 40,
            icon: Icon(_showNotebook ? Icons.book_outlined : Icons.menu_book),
            color: textColor,
            onPressed: () {
              setState(() {
                _showNotebook = !_showNotebook;
                if (_showNotebook) {
                  _notebookController.forward();
                } else {
                  _notebookController.reverse();
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: _themeColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showIntroMessages)
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 40),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(24),
                        border: bubbleBorder,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        introMessages[currentMessageIndex],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else ...[
                    IconButton(
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      iconSize: 80,
                      color: allowVoiceInput ? textColor : Colors.grey.shade500,
                      onPressed: allowVoiceInput ? _listen : null,
                      tooltip: 'Mikrofonu Aç/Kapat',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isListening ? 'Şu an dinliyorum...' : 'Söylemek için mikrofona dokunun',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      _recognizedWord.isEmpty ? '...' : _recognizedWord.toUpperCase(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: (_recognizedWord.isNotEmpty &&
                              _validWordsInLevel.contains(_recognizedWord) &&
                              allowVoiceInput)
                          ? _goToShuffleLetters
                          : null,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Harfleri Karıştır'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _themeColor.withValues(alpha: 0.85),
                        foregroundColor: textColor,
                        side: BorderSide(color: textColor, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                        shadowColor: Colors.black45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.45,
                margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(30),
                  border: bubbleBorder,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: _validWordsInLevel.map((word) {
                      bool isCompleted = GameState.instance.isWordCompleted(widget.levelIndex, word);
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.grey.shade300 : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCompleted ? Colors.grey.shade500 : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted ? Colors.green.shade400 : Colors.grey.shade400,
                              ),
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              word.toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                color: isCompleted ? Colors.grey.shade600 : Colors.black87,
                                decorationThickness: 2,
                                fontWeight: isCompleted ? FontWeight.w400 : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          if (showIntroMessages)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _themeColor.withValues(alpha: 0.95),
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    shadowColor: Colors.black38,
                  ),
                  onPressed: _nextIntroMessage,
                  child: const Text(
                    'Devam Et',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}