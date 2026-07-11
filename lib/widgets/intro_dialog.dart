import 'package:flutter/material.dart';

class IntroDialog extends StatelessWidget {
  final String message;
  final VoidCallback onNext;

  const IntroDialog({
    super.key,
    required this.message,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(Icons.chat_bubble_outline, color: Colors.black54),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onNext,
              child: const Text('Devam'),
            )
          ],
        ),
      ),
    );
  }
}
