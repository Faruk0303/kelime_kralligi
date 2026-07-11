import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_menu.dart'; // Seçimden sonra buraya yönlendireceğiz

class GenderSelection extends StatefulWidget {
  const GenderSelection({super.key});

  @override
  State<GenderSelection> createState() => _GenderSelectionState();
}

class _GenderSelectionState extends State<GenderSelection> {
  String? _selectedCharacter;

  Future<void> _saveCharacterAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedCharacter != null) {
      await prefs.setString('selectedCharacter', _selectedCharacter!);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainMenu()),
        );
      }
    }
  }

  Widget _buildCharacterCard(String name, String imagePath) {
    final isSelected = _selectedCharacter == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCharacter = name;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.transparent,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imagePath,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karakter Seçimi'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Bir karakter seç:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCharacterCard('Ferhat', 'assets/images/ferhat.png'),
                _buildCharacterCard('Hazal', 'assets/images/hazal.png'),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _selectedCharacter != null ? _saveCharacterAndContinue : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Devam Et'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
