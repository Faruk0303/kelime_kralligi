import 'package:flutter/material.dart';
import 'package:kelime_kralligi/core/theme/app_colors.dart';
import 'package:kelime_kralligi/core/theme/app_text_styles.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: scale,
      child: GestureDetector(
        onTapDown: (_) => setState(() => scale = .96),
        onTapUp: (_) => setState(() => scale = 1),
        onTapCancel: () => setState(() => scale = 1),
        onTap: widget.onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: widget.color ?? AppColors.gold,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .18),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: AppColors.navy),
                const SizedBox(width: 10),
              ],
              Text(
                widget.text,
                style: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
