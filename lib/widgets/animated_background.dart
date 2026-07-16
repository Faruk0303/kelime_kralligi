import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedCharacterBackground extends StatefulWidget {
  final String character;

  const AnimatedCharacterBackground({super.key, required this.character});

  @override
  State<AnimatedCharacterBackground> createState() => _AnimatedCharacterBackgroundState();
}

class _AnimatedCharacterBackgroundState extends State<AnimatedCharacterBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: widget.character == 'Hazal'
              ? FlowerRainPainter(_controller.value)
              : BubbleStarPainter(_controller.value),
          child: Container(),
        );
      },
    );
  }
}

// 🌸 Hazal için çiçek yağmuru
class FlowerRainPainter extends CustomPainter {
  final double value;
  final List<Color> flowerColors = [
    Colors.pinkAccent,
    Colors.purple,
    Colors.deepOrangeAccent,
    Colors.red,
  ];

  FlowerRainPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < 30; i++) {
      final radius = 6 + 4 * sin((value * 2 * pi) + i);
      final x = (size.width / 30) * i + 10 * sin(value * 6 * pi + i);
      final y = (value * size.height * 1.2 + i * 40) % size.height;
      paint.color = flowerColors[i % flowerColors.length].withValues(alpha: 0.7 + (i % 3) * 0.15);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// ✨ Ferhat için yıldız + baloncuk animasyonu
class BubbleStarPainter extends CustomPainter {
  final double value;
  final List<Color> starColors = [
    Colors.yellow,
    Colors.blueAccent,
    Colors.cyanAccent,
    Colors.orangeAccent,
  ];

  BubbleStarPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Yıldızlar
    for (int i = 0; i < 25; i++) {
      final x = (size.width / 25) * i + 10 * sin(value * 2 * pi + i);
      final y = size.height - (value * size.height * 1.2 + i * 25) % size.height;
      final radius = 3 + 2 * sin((value + i) * 3);
      paint.color = starColors[i % starColors.length].withValues(alpha: 0.8);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Baloncuklar
    for (int i = 0; i < 10; i++) {
      final bubbleX = size.width * _noise(i * 0.5 + value);
      final bubbleY = size.height - (value * size.height * 1.1 + i * 50) % size.height;
      paint.color = Colors.white.withValues(alpha: 0.4 + (i % 3) * 0.15);
      canvas.drawCircle(Offset(bubbleX, bubbleY), 8 + i % 5.0, paint);
    }
  }

  double _noise(double x) {
    return 0.5 + 0.5 * sin(x * 2 * pi);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}