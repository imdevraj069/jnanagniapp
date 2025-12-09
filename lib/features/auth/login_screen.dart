import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/api_service.dart';
import '../../core/constants.dart';
import '../dashboard/main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _api = ApiService();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    // Call the API
    final success = await _api.login(_emailController.text, _passController.text);
    setState(() => _isLoading = false);

    if (success && mounted) {
      // Navigate to Main Dashboard
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Access Denied: Invalid Credentials'),
          backgroundColor: AppConstants.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                child: const Icon(Icons.hub, size: 80, color: AppConstants.accentCyan),
              ),
              const SizedBox(height: 20),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  "SYSTEM ACCESS",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    shadows: [
                      const Shadow(color: AppConstants.primaryViolet, blurRadius: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              
              // Inputs
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: Colors.grey),
                    hintText: "Operator ID",
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: TextField(
                  controller: _passController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.fingerprint, color: Colors.grey),
                    hintText: "Security Key",
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Login Button
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryViolet,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 10,
                      shadowColor: AppConstants.primaryViolet.withOpacity(0.5),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("INITIATE UPLINK", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}