// lib/widgets/score_indicator.dart
import 'package:flutter/material.dart';
import 'package:kelime_kralligi/game_state.dart';
import 'package:provider/provider.dart'; // <<< EKLENDİ

class ScoreIndicator extends StatelessWidget {
  const ScoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // GameState'deki 'score' değerini dinliyoruz
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        final int score = gameState.score; // Nullable problem çözüldü
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), // Subtle background
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber, // Gold color for score
                size: 24,
              ),
              const SizedBox(width: 5),
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}