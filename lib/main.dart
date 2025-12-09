import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/auth/splash_screen.dart';

void main() {
  runApp(const FestManagerApp());
}

class FestManagerApp extends StatelessWidget {
  const FestManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fest Manager',
      
      // Apply the electronic theme
      theme: AppTheme.electronicTheme,
      
      // Start at Splash to check logic
      home: const SplashScreen(),
    );
  }
}