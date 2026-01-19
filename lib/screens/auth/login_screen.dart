import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cyber_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  void _handleLogin() async {
    final success = await context.read<AuthProvider>().login(_emailCtrl.text, _passCtrl.text);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Failed'), backgroundColor: CyberColors.neonPink));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPrimary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              FadeInDown(
                child: const Text("JNANAGNI", style: TextStyle(fontFamily: 'Orbitron', fontSize: 40, fontWeight: FontWeight.bold, color: CyberColors.neonCyan, shadows: [Shadow(color: CyberColors.neonCyan, blurRadius: 20)])),
              ),
              const SizedBox(height: 10),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: const Text("ADMIN PORTAL", style: TextStyle(color: CyberColors.textSecondary, letterSpacing: 4)),
              ),
              const SizedBox(height: 50),
              FadeInUp(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: CyberColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CyberColors.borderColor),
                  ),
                  child: Column(
                    children: [
                      CyberInput(label: "Email", controller: _emailCtrl),
                      const SizedBox(height: 20),
                      CyberInput(label: "Password", controller: _passCtrl, isPassword: true),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CyberColors.neonCyan,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: context.watch<AuthProvider>().isLoading 
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text("ACCESS TERMINAL", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
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