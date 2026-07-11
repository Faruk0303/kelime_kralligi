import 'package:shared_preferences/shared_preferences.dart';

class CharacterGuideManager {
  static const _introCompletedKey = 'hasCompletedIntro';
  static const _introStepKey = 'introStep';

  // Giriş tanıtımı yapıldı mı?
  static Future<bool> isIntroCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_introCompletedKey) ?? false;
  }

  static Future<void> setIntroCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introCompletedKey, completed);
  }

  // Hangi adımdasın? (Oyna, Seviyeler vb.)
  static Future<int> getIntroStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_introStepKey) ?? 0;
  }

  static Future<void> setIntroStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_introStepKey, step);
  }

  static Future<void> resetIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_introCompletedKey);
    await prefs.remove(_introStepKey);
  }
}
