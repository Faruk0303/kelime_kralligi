// lib/game_state.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  static final GameState _instance = GameState._internal();

  factory GameState() {
    return _instance;
  }

  bool isLevelCompleted(int index) {
    return index < _completedLevelIndex;
  }

  GameState._internal();

  static GameState get instance => _instance;

  int _score = 0;
  int _lives = 3;
  int _completedLevelIndex = -1; // Last completed level (-1 = none)
  final Map<int, Set<String>> _completedWords = {}; // Completed words by level
  int _currentLevelScore = 0; // Score in current level

  int get score => _score;
  int get lives => _lives;
  int get completedLevelIndex => _completedLevelIndex;
  int get currentLevelScore => _currentLevelScore;

  int get maxLives => 3; // Sabit maksimum can sayısı

  // Load saved game data from SharedPreferences
  Future<void> loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    _score = prefs.getInt('score') ?? 0;
    _lives = prefs.getInt('lives') ?? 3;
    _completedLevelIndex = prefs.getInt('completedLevelIndex') ?? -1;

    for (int i = 0; i <= _completedLevelIndex + 1; i++) {
      final List<String>? wordsList = prefs.getStringList('completedWords_level_$i');
      if (wordsList != null) {
        _completedWords[i] = wordsList.toSet();
      } else {
        _completedWords[i] = {};
      }
    }
    notifyListeners();
  }

  // Save game data to SharedPreferences
  Future<void> saveGameData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('score', _score);
    await prefs.setInt('lives', _lives);
    await prefs.setInt('completedLevelIndex', _completedLevelIndex);

    for (var entry in _completedWords.entries) {
      await prefs.setStringList('completedWords_level_${entry.key}', entry.value.toList());
    }
  }

  void addScore(int points) {
    _score += points;
    notifyListeners();
    saveGameData();
  }

  void addCurrentLevelScore(int points) {
    _currentLevelScore += points;
    notifyListeners();
  }

  void resetCurrentLevelScore() {
    _currentLevelScore = 0;
    notifyListeners();
  }

  void loseLife() {
    if (_lives > 0) {
      _lives--;
      notifyListeners();
      saveGameData();
    }
  }

  void resetLives() {
    _lives = maxLives;
    notifyListeners();
    saveGameData();
  }

  void addCompletedWord(int levelIndex, String word) {
    final lowerWord = word.toLowerCase();
    _completedWords.putIfAbsent(levelIndex, () => <String>{});
    _completedWords[levelIndex]!.add(lowerWord);
    saveGameData();
    notifyListeners();
  }

  Set<String> getCompletedWords(int levelIndex) {
    return _completedWords[levelIndex] ?? {};
  }

  int getCompletedWordsCount(int levelIndex) {
    return _completedWords[levelIndex]?.length ?? 0;
  }

  bool isWordCompleted(int levelIndex, String word) {
    return _completedWords[levelIndex]?.contains(word.toLowerCase()) ?? false;
  }

  void completeLevel(int levelIndex) {
    if (levelIndex >= _completedLevelIndex) {
      _completedLevelIndex = levelIndex + 1; // Unlock next level
    }
    resetCurrentLevelScore();
    saveGameData();
    notifyListeners();
  }

  Future<void> resetGame() async {
    _score = 0;
    _lives = maxLives;
    _completedLevelIndex = -1;
    _completedWords.clear();
    _currentLevelScore = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
