import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, size: 60, color: AppConstants.primaryViolet),
            const SizedBox(height: 20),
            Text(
              "ENCRYPTED CHAT",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                letterSpacing: 2
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Secure Uplink Offline", 
              style: TextStyle(color: Colors.white54)
            ),
          ],
        ),
      ),
    );
  }
}