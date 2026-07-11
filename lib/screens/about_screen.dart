// lib/screens/about_screen.dart
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkında'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kelime Krallığı Uygulaması',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Bu uygulama, kelime öğrenmeyi eğlenceli hale getirmek için tasarlanmıştır.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Versiyon: 1.0.0',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                'Geliştirici: AI Asistanı',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}