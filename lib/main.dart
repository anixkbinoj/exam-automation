import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ExamAutomationApp());
}

class ExamAutomationApp extends StatelessWidget {
  const ExamAutomationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALLOXAM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const SplashScreen(), // 👈 Start from Splash first
    );
  }
}
