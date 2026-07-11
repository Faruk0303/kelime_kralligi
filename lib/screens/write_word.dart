// lib/screens/write_word.dart
import 'package:flutter/material.dart';

class WriteWord extends StatelessWidget {
  const WriteWord({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Yazma'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Kelime yazma ekranı buraya gelecek.',
          style: TextStyle(fontSize: 22, color: Colors.grey),
        ),
      ),
    );
  }
}