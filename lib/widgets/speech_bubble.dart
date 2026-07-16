import 'package:flutter/material.dart';
import 'package:kelime_kralligi/core/theme/app_colors.dart';
import 'package:kelime_kralligi/core/theme/app_text_styles.dart';

class SpeechBubble extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool arrowOnRight;
  final Widget? leading;
  final EdgeInsetsGeometry padding;

  const SpeechBubble({
    super.key,
    required this.message,
    this.backgroundColor,
    this.borderColor,
    this.arrowOnRight = false,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = backgroundColor ?? AppColors.cloudWhite;
    final outlineColor =
        borderColor ?? AppColors.lightGold.withValues(alpha: 0.9);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: outlineColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(child: Text(message, style: AppTextStyles.mascotSpeech)),
            ],
          ),
        ),
        Positioned(
          bottom: -13,
          left: arrowOnRight ? null : 34,
          right: arrowOnRight ? 34 : null,
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: bubbleColor,
                border: Border(
                  right: BorderSide(color: outlineColor, width: 2),
                  bottom: BorderSide(color: outlineColor, width: 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
