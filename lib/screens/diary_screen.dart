// lib/screens/diary_screen.dart
import 'package:flutter/material.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük'),
        centerTitle: true,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Günlük ekranı buraya gelecek.',
          style: TextStyle(fontSize: 22, color: Colors.grey),
        ),
      ),
    );
  }
}