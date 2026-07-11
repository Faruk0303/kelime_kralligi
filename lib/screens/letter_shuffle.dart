import 'package:flutter/material.dart';
import 'dart:math';
import 'package:kelime_kralligi/widgets/life_indicator.dart';
import 'package:kelime_kralligi/widgets/score_indicator.dart';
import 'package:kelime_kralligi/game_state.dart';
import 'package:kelime_kralligi/screens/manual_write.dart';
import 'package:kelime_kralligi/screens/levels_screen.dart';


class LetterShuffle extends StatefulWidget {
  final String word;
  final String colorName;
  final int levelIndex;

  const LetterShuffle({
    super.key,
    required this.word,
    required this.colorName,
    required this.levelIndex,
  });

  @override
  State<LetterShuffle> createState() => _LetterShuffleState();
}

class _LetterShuffleState extends State<LetterShuffle> {
  List<String> _shuffledLetters = [];
  late List<String> _originalLetters;
  late Color _themeColor;
  late bool _isTextDark;

  @override
  void initState() {
    super.initState();
    _originalLetters = widget.word.toUpperCase().split('');
    _shuffledLetters = List<String>.from(_originalLetters);
    _shuffledLetters.shuffle(Random());
    _setThemeColor();
  }

  void _setThemeColor() {
    final colorName = widget.colorName.toLowerCase();
    switch (colorName) {
      case 'kırmızı':
        _themeColor = Colors.red.shade200;
        break;
      case 'mavi':
        _themeColor = Colors.blue.shade200;
        break;
      case 'yeşil':
        _themeColor = Colors.green.shade200;
        break;
      case 'sarı':
        _themeColor = Colors.yellow.shade200;
        break;
      case 'mor':
        _themeColor = Colors.purple.shade200;
        break;
      case 'pembe':
        _themeColor = Colors.pink.shade100;
        break;
      default:
        _themeColor = Colors.grey.shade300;
    }

    _isTextDark = _themeColor.computeLuminance() > 0.5;
  }

  void _swapLetters(int i, int j) {
    setState(() {
      final temp = _shuffledLetters[i];
      _shuffledLetters[i] = _shuffledLetters[j];
      _shuffledLetters[j] = temp;
    });
  }

  void _checkAndProceed() {
    final currentWord = _shuffledLetters.join().toLowerCase();
    final targetWord = _originalLetters.join().toLowerCase();

    if (currentWord == targetWord) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ManualWrite(
            word: widget.word,
            colorName: widget.colorName,
            levelIndex: widget.levelIndex,
          ),
        ),
      );
    } else {
      GameState.instance.loseLife();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kelime yanlış sıralandı. Bir can kaybettin!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _isTextDark ? Colors.black : Colors.white;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBoxWidth = screenWidth * 0.8;
    final letterCount = widget.word.length;
    final boxSize = min(maxBoxWidth / letterCount - 8, 70.0);

    return WillPopScope(
  onWillPop: () async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LevelsScreen()),
      (Route<dynamic> route) => false,
    );
    return false;
  },
  child: Scaffold(
    backgroundColor: _themeColor,
    appBar: AppBar(
      title: const Text('Harfleri Sırala'),
      backgroundColor: _themeColor,
      foregroundColor: textColor,
      centerTitle: true,
      elevation: 0,
      actions: const [
        ScoreIndicator(),
        SizedBox(width: 12),
        LifeIndicator(),
        SizedBox(width: 12),
      ],
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_shuffledLetters.length, (index) {
              return Draggable<int>(
                data: index,
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildLetterBox(_shuffledLetters[index], boxSize, textColor),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _buildLetterBox(_shuffledLetters[index], boxSize, textColor),
                ),
                child: DragTarget<int>(
                  onWillAccept: (fromIndex) => fromIndex != index,
                  onAccept: (fromIndex) => _swapLetters(fromIndex, index),
                  builder: (context, candidateData, rejectedData) {
                    return _buildLetterBox(_shuffledLetters[index], boxSize, textColor);
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _checkAndProceed,
            icon: const Icon(Icons.check),
            label: const Text("Kelimeyi Yaz"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _themeColor,
              foregroundColor: textColor,
              side: BorderSide(color: textColor, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            ),
          ),
        ],
      ),
    ),
  ),
);

  }

  Widget _buildLetterBox(String letter, double size, Color textColor) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _themeColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          fontSize: size * 0.6,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
