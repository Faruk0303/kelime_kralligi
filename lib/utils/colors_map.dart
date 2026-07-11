import 'package:flutter/material.dart';

class ColorsMap {
  static Color getColorByName(String name) {
    switch (name.toLowerCase()) {
      case 'kırmızı': return Colors.red;
      case 'mavi': return Colors.blue;
      case 'yeşil': return Colors.green;
      case 'sarı': return Colors.yellow;
      case 'mor': return Colors.purple;
      case 'turuncu': return Colors.orange;
      case 'pembe': return Colors.pink;
      case 'siyah': return Colors.black;
      case 'beyaz': return Colors.white;
      case 'kahverengi': return Colors.brown;
      case 'gri': return Colors.grey;
      default: return Colors.deepPurple;
    }
  }
}