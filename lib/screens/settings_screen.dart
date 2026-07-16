import 'package:flutter/material.dart';
import 'package:kelime_kralligi/providers/game_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSoundOn = true;
  bool _isMusicOn = true;
  bool _notificationsOn = true;
  bool _isDarkTheme = false;
  bool _isEnglish = false;

  Future<void> _resetGameData() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oyunu Sıfırla'),
        content: const Text('Tüm ilerlemeniz ve skorlar sıfırlanacak. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await GameState.instance.resetGame();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oyun verileri sıfırlandı!')),
        );
      }
    }
  }

  void _toggleSound() => setState(() => _isSoundOn = !_isSoundOn);
  void _toggleMusic() => setState(() => _isMusicOn = !_isMusicOn);
  void _toggleNotifications() => setState(() => _notificationsOn = !_notificationsOn);
  void _toggleTheme() => setState(() => _isDarkTheme = !_isDarkTheme);
  void _toggleLanguage() => setState(() => _isEnglish = !_isEnglish);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkTheme ? Colors.grey.shade900 : const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text(_isEnglish ? 'Settings' : 'Ayarlar'),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildSettingCard(
              icon: Icons.volume_up,
              label: _isEnglish ? 'Sound' : 'Ses',
              isActive: _isSoundOn,
              onTap: _toggleSound,
              isDark: _isDarkTheme,
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              icon: Icons.music_note,
              label: _isEnglish ? 'Music' : 'Müzik',
              isActive: _isMusicOn,
              onTap: _toggleMusic,
              isDark: _isDarkTheme,
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              icon: Icons.notifications,
              label: _isEnglish ? 'Notifications' : 'Bildirimler',
              isActive: _notificationsOn,
              onTap: _toggleNotifications,
              isDark: _isDarkTheme,
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              icon: Icons.brightness_6,
              label: _isEnglish ? 'Dark Theme' : 'Karanlık Tema',
              isActive: _isDarkTheme,
              onTap: _toggleTheme,
              isDark: _isDarkTheme,
            ),
            const SizedBox(height: 16),
            _buildSettingCard(
              icon: Icons.language,
              label: _isEnglish ? 'English' : 'Türkçe',
              isActive: _isEnglish,
              onTap: _toggleLanguage,
              isDark: _isDarkTheme,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever, size: 30),
              label: Text(
                _isEnglish ? 'Reset Game Data' : 'Oyun Verilerini Sıfırla',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 8,
              ),
              onPressed: _resetGameData,
            ),
            const Spacer(),
            Text(
              'Kelime Krallığı',
              style: TextStyle(
                color: Colors.deepOrange.shade300,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.deepOrange.shade100 : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? Colors.deepOrange.shade300.withValues(alpha: 0.6)
                  : Colors.grey.shade400.withValues(alpha: 0.8),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 36,
              color: isActive ? Colors.deepOrange : (isDark ? Colors.white : Colors.grey.shade700),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.deepOrange.shade900 : (isDark ? Colors.white70 : Colors.grey.shade700),
              ),
            ),
            const Spacer(),
            Icon(
              isActive ? Icons.toggle_on : Icons.toggle_off,
              size: 48,
              color: isActive ? Colors.deepOrange : Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }
}