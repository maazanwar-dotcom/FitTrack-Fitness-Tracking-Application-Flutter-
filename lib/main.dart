import 'package:fittrack/screens/auth/onboarding_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FitTrackApp());
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 235, 234, 234),
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          elevation: 4,
          centerTitle: true,
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
