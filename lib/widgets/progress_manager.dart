import 'package:shared_preferences/shared_preferences.dart';


class ProgressManager {
  static final ProgressManager instance = ProgressManager._internal();
  ProgressManager._internal();

  int completedLevelIndex = 0;

  Future<void> saveProgress() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('completedLevelIndex', completedLevelIndex);
  }

  Future<void> loadProgress() async {
   final prefs = await SharedPreferences.getInstance();
   completedLevelIndex = prefs.getInt('completedLevelIndex') ?? 0;
  }

  void completeLevel(int levelIndex) {
   if (levelIndex > completedLevelIndex) {
    completedLevelIndex = levelIndex;
     saveProgress(); // Cihaza kaydet
    }
  }
}