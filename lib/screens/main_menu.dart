// lib/screens/main_menu.dart
import 'package:flutter/material.dart';
import 'package:kelime_kralligi/screens/levels_screen.dart';
import 'package:kelime_kralligi/screens/settings_screen.dart';
import 'package:kelime_kralligi/game_state.dart';
import 'package:kelime_kralligi/screens/voice_input.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Arka plan için degrade renk
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5D26C1), Color(0xFF6A82FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Başlık
                const Text(
                  'Kelime Krallığı',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Yeni Oyun Butonu
                _buildMenuButton(
                  context,
                  icon: Icons.play_arrow,
                  label: 'Yeni Oyun',
                  backgroundColor: Colors.green.shade600,
                  onPressed: () {
                    GameState.instance.resetGame();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LevelsScreen()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Devam Et Butonu
                _buildMenuButton(
                  context,
                  icon: Icons.refresh,
                  label: 'Devam Et',
                  backgroundColor: Colors.blue.shade600,
                  onPressed: () {
                    final completedLevelIndex = GameState.instance.completedLevelIndex;
                    int targetLevelIndex = 0;
                    if (completedLevelIndex != -1) {
                      targetLevelIndex = completedLevelIndex;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VoiceInput(levelIndex: targetLevelIndex, colorName: '', word: '',),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Ayarlar Butonu
                _buildMenuButton(
                  context,
                  icon: Icons.settings,
                  label: 'Ayarlar',
                  backgroundColor: Colors.grey.shade600,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(
        label,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(220, 60),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onPressed,
    );
  }
}
