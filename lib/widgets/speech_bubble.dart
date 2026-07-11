import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  final String message;
  final bool isLeft; // true = sola yaslı, false = sağa yaslı
  final VoidCallback? onTap;

  const SpeechBubble({
    super.key,
    required this.message,
    this.isLeft = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isLeft ? Alignment.bottomLeft : Alignment.bottomRight,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isLeft ? 0 : 18),
              bottomRight: Radius.circular(isLeft ? 18 : 0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: const Offset(2, 4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
