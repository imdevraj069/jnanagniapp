import 'package:flutter/material.dart';
import '../../core/api_service.dart';
import '../dashboard/main_layout.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    final api = ApiService();
    final isValid = await api.isSessionValid();
    
    // Artificial delay for branding
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (isValid) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            const Text("SYSTEM INITIALIZING...", style: TextStyle(letterSpacing: 2, fontSize: 16)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Color(0xFF06B6D4)),
          ],
        ),
      ),
    );
  }
}