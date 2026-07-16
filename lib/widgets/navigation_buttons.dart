import 'package:flutter/material.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final Color color;
  final bool showBack;
  final bool showNext;
  final String nextLabel;

  const NavigationButtons({
    super.key,
    this.onBack,
    this.onNext,
    required this.color,
    this.showBack = true,
    this.showNext = true,
    this.nextLabel = "İleri",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            ElevatedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text("Geri"),
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.9),
                foregroundColor: Colors.white,
              ),
            )
          else
            const SizedBox(width: 100),

          if (showNext)
            ElevatedButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward),
              label: Text(nextLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.9),
                foregroundColor: Colors.white,
              ),
            )
          else
            const SizedBox(width: 100),
        ],
      ),
    );
  }
}