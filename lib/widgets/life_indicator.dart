// lib/widgets/life_indicator.dart
import 'package:flutter/material.dart';
import 'package:kelime_kralligi/game_state.dart';
import 'package:provider/provider.dart';

class LifeIndicator extends StatelessWidget {
  final Color backgroundColor;

  const LifeIndicator({super.key, this.backgroundColor = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        final int lives = gameState.lives;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite,
                color: (lives > 0) ? Colors.red : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 5),
              Text(
                '$lives',
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