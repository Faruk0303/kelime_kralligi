// lib/main.dart
import 'package:flutter/material.dart';
import 'package:kelime_kralligi/screens/splash/splash_screen.dart';
import 'package:kelime_kralligi/providers/game_state.dart';
import 'package:provider/provider.dart'; // <<< EKLENDİ

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameState.instance.loadGameData();
  runApp(
    ChangeNotifierProvider(
      // <<< EKLENDİ: GameState'i sarmalıyoruz
      create: (context) => GameState.instance,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelime Krallığı',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white, // AppBar icons and text color
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
