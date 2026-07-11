// lib/utils/theme_manager.dart

import 'package:flutter/material.dart';

class CharacterTheme {
  final Color primaryColor;
  final Color backgroundColor;
  final Color buttonColor;
  final Color textColor;

  CharacterTheme({
    required this.primaryColor,
    required this.backgroundColor,
    required this.buttonColor,
    required this.textColor,
  });
}

CharacterTheme getThemeForCharacter(String character) {
  if (character == 'Hazal') {
    return CharacterTheme(
      primaryColor: Colors.pink.shade400,
      backgroundColor: Colors.pink.shade50,
      buttonColor: Colors.pink.shade300,
      textColor: Colors.white,
    );
  } else {
    return CharacterTheme(
      primaryColor: Colors.blue.shade600,
      backgroundColor: Colors.blue.shade50,
      buttonColor: Colors.blue.shade400,
      textColor: Colors.white,
    );
  }
}
