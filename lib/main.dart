import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/colors.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/events/event_list_screen.dart';
import 'screens/users/user_list_screen.dart';
import 'screens/scanner/scanner_screen.dart';

// --- 1. THE MISSING MAIN FUNCTION ---
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// --- 2. ROOT APP WIDGET ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jnanagni Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: CyberColors.bgPrimary,
        brightness: Brightness.dark,
        primaryColor: CyberColors.neonCyan,
        appBarTheme: const AppBarTheme(
          backgroundColor: CyberColors.bgSecondary,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white, 
            fontSize: 18, 
            fontWeight: FontWeight.bold
          ),
          iconTheme: IconThemeData(color: CyberColors.neonCyan),
        ),
      ),
      home: const AuthCheck(),
    );
  }
}

// --- 3. AUTH CHECKER ---
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    // Check if token exists on startup
    // We use addPostFrameCallback to ensure context is valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    // While checking token, show a loader
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: CyberColors.neonCyan)),
      );
    }
    
    return auth.isAuthenticated ? const MainShell() : const LoginScreen();
  }
}

// --- 4. MAIN SHELL (Navigation & Scanner) ---
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  // Pages corresponding to bottom nav items (excluding scanner)
  final List<Widget> _screens = [
    const DashboardScreen(), // Index 0: Home
    const EventListScreen(), // Index 1: Events
    const UserListScreen(),  // Index 2: Users
    const Scaffold(
      body: Center(child: Text("Profile Settings (Coming Soon)")),
    ), // Index 3: Profile
  ];

  void _onItemTapped(int index) {
    // If user clicks the placeholder space for Scanner (index 2 in visual row), ignore it
    // because logic maps 5 visual items to 4 actual screens.
    // However, BottomNavigationBar `onTap` index corresponds to the item index.
    
    // We are implementing a custom Row in BottomAppBar, so we update _idx manually.
    setState(() => _idx = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPrimary,
      body: _screens[_idx],
      
      // --- SCANNER BUTTON (Middle) ---
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          backgroundColor: CyberColors.neonCyan,
          elevation: 10,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const ScannerScreen())
            );
          },
          child: const Icon(Icons.qr_code_scanner, size: 35, color: Colors.black),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- BOTTOM NAVIGATION ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: CyberColors.bgSecondary,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(Icons.grid_view_rounded, 0, "Home"),
              _buildNavIcon(Icons.event_note_rounded, 1, "Events"),
              const SizedBox(width: 40), // Spacer for FAB
              _buildNavIcon(Icons.people_alt_rounded, 2, "Users"),
              _buildNavIcon(Icons.person_rounded, 3, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, String label) {
    final isSelected = _idx == index;
    return InkWell(
      onTap: () => setState(() => _idx = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? CyberColors.neonCyan : Colors.grey,
            size: isSelected ? 28 : 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? CyberColors.neonCyan : Colors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )
          )
        ],
      ),
    );
  }
}