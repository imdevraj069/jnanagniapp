import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class RegistrationListScreen extends StatelessWidget {
  final String eventId;
  const RegistrationListScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPrimary,
      appBar: AppBar(
        title: const Text("Registrations"),
        backgroundColor: CyberColors.bgSecondary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 60, color: CyberColors.neonGreen),
            const SizedBox(height: 20),
            Text("Registrations for Event ID:", style: TextStyle(color: Colors.white70)),
            Text(eventId, style: const TextStyle(color: CyberColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}