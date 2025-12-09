import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart'; // Ensure you have this file from the previous step!
import '../chat/chat_screen.dart';
import '../notifications/notification_screen.dart';
import '../scanner/scanner_screen.dart';
import '../../core/api_service.dart';
import '../auth/login_screen.dart';
import '../../core/constants.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  
  // Define the 5 pages
  // Index 0: Home (Command Center)
  // Index 1: Dashboard (Real User Profile)
  // Index 2: Scanner (Placeholder for the list, actual navigation is via FAB)
  // Index 3: Chat (New)
  // Index 4: Notifications (Alerts)
  final List<Widget> _pages = [
    const HomeScreen(),        
    const DashboardScreen(),   
    const SizedBox(),          
    const ChatScreen(),        
    const NotificationScreen() 
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // If middle scanner icon/space is somehow tapped
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _logout() async {
    await ApiService().logout();
    if(mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  // Dynamic Title based on selection
  String _getTitle(int index) {
    switch (index) {
      case 0: return "COMMAND CENTER";
      case 1: return "MY DASHBOARD";
      case 3: return "COMMS";
      case 4: return "ALERTS";
      default: return "JNANAGNI";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: AppConstants.errorRed),
            onPressed: _logout,
          )
        ],
      ),
      // Use IndexedStack to keep state alive (so Dashboard doesn't reload every time)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      // --- SCANNER BUTTON (Middle) ---
      floatingActionButton: SizedBox(
        height: 65, 
        width: 65,
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
          backgroundColor: AppConstants.accentCyan,
          elevation: 10,
          shape: const CircleBorder(),
          child: const Icon(Icons.qr_code_2, size: 32, color: Colors.black),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // --- 5-BUTTON NAVIGATION ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: AppConstants.cardGrey,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Side
              _buildNavIcon(Icons.grid_view_rounded, 0),    // Home
              _buildNavIcon(Icons.person_outline, 1),       // Dashboard
              
              const SizedBox(width: 40), // Spacer for FAB
              
              // Right Side
              _buildNavIcon(Icons.chat_bubble_outline, 3),  // Chat
              _buildNavIcon(Icons.notifications_none, 4),   // Notifications
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return IconButton(
      icon: Icon(
        icon, 
        color: isSelected ? AppConstants.primaryViolet : Colors.grey,
        size: isSelected ? 28 : 24,
      ),
      onPressed: () => _onTabTapped(index),
    );
  }
}