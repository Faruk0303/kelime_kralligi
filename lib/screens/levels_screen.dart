import 'package:flutter/material.dart';
import 'package:kelime_kralligi/game_state.dart';
import 'package:kelime_kralligi/screens/main_menu.dart';
import 'package:kelime_kralligi/screens/voice_input.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> with SingleTickerProviderStateMixin {
  final List<String> _levelTitles = [
    'Renkler',
    'Hayvanlar',
    'Eşyalar',
    'Yiyecekler',
    'Meslekler',
    'Taşıtlar',
    'Doğa',
    'Sporlar',
    'Meyveler',
    'Gezegenler',
  ];

  static const int premiumStartIndex = 3; // 4. seviyeden itibaren premium

  @override
  void initState() {
    super.initState();
    GameState.instance.loadGameData().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedLevelIndex = GameState.instance.completedLevelIndex;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainMenu()),
            );
          },
        ),
        title: const Text(
          'Seviyeler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.purpleAccent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Stack(
        children: [
          // Arka plan renkli baloncuklar ile
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFCE5F4), Color(0xFFFFF0F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ..._buildBubbles(),

          // Seviye listesi
          ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _levelTitles.length,
            itemBuilder: (context, index) {
              final bool isPremium = index >= premiumStartIndex;
              final bool isUnlocked = index == 0 ||
                  (!isPremium &&
                  GameState.instance.isLevelCompleted(index-1));
              final int currentScore = GameState.instance.getCompletedWordsCount(index);
              final int totalWords = _getTotalWordsForLevel(index);
              final double progress = (totalWords > 0) ? currentScore / totalWords : 0;

              Color cardColor;
              Color titleColor;
              List<BoxShadow> shadows = [];

              if (isPremium) {
                cardColor = isUnlocked ? Colors.orangeAccent.shade100 : Colors.orange.shade200.withOpacity(0.7);
                titleColor = Colors.deepOrange.shade900;
                shadows = [
                  BoxShadow(
                    color: Colors.orangeAccent.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 3,
                    offset: const Offset(0, 4),
                  )
                ];
              } else {
                cardColor = isUnlocked ? Colors.white : Colors.grey.shade300;
                titleColor = isUnlocked ? Colors.deepPurple : Colors.grey.shade700;
                if (isUnlocked) {
                  shadows = [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.4),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ];
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: shadows,
                    border: Border.all(
                      color: isPremium ? Colors.deepOrange.shade700 : Colors.blue.shade700,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    onTap: isUnlocked
                        ? () {
                            GameState.instance.resetCurrentLevelScore();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VoiceInput(levelIndex: index, colorName: '', word: '',),
                              ),
                            ).then((_) {
                              GameState.instance.loadGameData().then((__) {
                                if (mounted) setState(() {});
                              });
                            });
                          }
                        : null,
                    leading: isPremium
                        ? Icon(
                            isUnlocked ? Icons.star : Icons.workspace_premium,
                            size: 42,
                            color: Colors.deepOrange.shade700,
                          )
                        : Text(
                            isUnlocked ? '🌟' : '🚫',
                            style: const TextStyle(fontSize: 38),
                          ),
                    title: Text(
                      isPremium
                          ? 'Premium Paket - Seviye ${index + 1}: ${_levelTitles[index]}'
                          : 'Seviye ${index + 1}: ${_levelTitles[index]}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                        shadows: [
                          Shadow(
                            color: Colors.orangeAccent.withOpacity(0.5),
                            offset: const Offset(2, 2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    subtitle: isUnlocked && !isPremium
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                'Tamamlanan Kelime: $currentScore / $totalWords',
                                style: TextStyle(color: Colors.deepPurple.shade300),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 14,
                                  backgroundColor: Colors.deepPurple.shade50,
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                            ],
                          )
                        : isPremium
                            ? const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text(
                                  'Bu seviye sadece Premium Paket içindir!',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text(
                                  '🚫 Kilitli',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                    trailing: isUnlocked
                        ? Icon(
                            Icons.arrow_forward_ios,
                            color: isPremium ? Colors.deepOrange.shade700 : Colors.purpleAccent,
                            size: 30,
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Arka plandaki baloncukları oluşturur
  List<Widget> _buildBubbles() {
    List<Widget> bubbles = [];
    final colors = [
      Colors.pinkAccent.shade100.withOpacity(0.4),
      Colors.orangeAccent.shade100.withOpacity(0.4),
      Colors.purpleAccent.shade100.withOpacity(0.3),
      Colors.yellowAccent.shade100.withOpacity(0.3),
    ];

    final sizes = [80.0, 120.0, 60.0, 100.0];
    final positions = [
      const Offset(30, 80),
      const Offset(250, 120),
      const Offset(150, 300),
      const Offset(300, 400),
    ];

    for (int i = 0; i < 4; i++) {
      bubbles.add(Positioned(
        left: positions[i].dx,
        top: positions[i].dy,
        child: Container(
          width: sizes[i],
          height: sizes[i],
          decoration: BoxDecoration(
            color: colors[i],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors[i].withOpacity(0.6),
                blurRadius: 15,
                spreadRadius: 5,
              )
            ],
          ),
        ),
      ));
    }
    return bubbles;
  }

  int _getTotalWordsForLevel(int index) {
    if (index < 3) return 20;
    return 10;
  }
}
