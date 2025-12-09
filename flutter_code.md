# lib/core/api_service.dart
```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, Local IP for Real Device
  static const String baseUrl = 'https://node.imdevraj.com/api/v1'; 
  
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  final _storage = const FlutterSecureStorage();

  ApiService() {
    // Add interceptor to inject token automatically
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // --- AUTH ---
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['data']['token'];
        // Save Token
        await _storage.write(key: 'jwt_token', value: token);
        // Save Login Time for 6-hour check
        await _storage.write(key: 'login_time', value: DateTime.now().toIso8601String());
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if session is valid (< 6 hours)
  Future<bool> isSessionValid() async {
    final token = await _storage.read(key: 'jwt_token');
    final timeStr = await _storage.read(key: 'login_time');
    
    if (token == null || timeStr == null) return false;

    final loginTime = DateTime.parse(timeStr);
    final difference = DateTime.now().difference(loginTime);

    if (difference.inHours >= 6) {
      await logout(); // Expired
      return false;
    }
    return true;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // --- DATA ---
  Future<Map<String, dynamic>?> scanUser(String userId) async {
    try {
      // Endpoint updated as requested
      final response = await _dio.get('/users/scan/$userId');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
```
---

# lib/core/constants.dart
```dart
import 'package:flutter/material.dart';

class AppConstants {
  // Networking
  // Use 10.0.2.2 for Android Emulator, your PC IP for real devices
  static const String baseUrl = 'https://node.imdevraj.com/api/v1'; 
  
  // Colors (Cyberpunk Palette)
  static const Color bgBlack = Color(0xFF0B0E14);   // Deep Space
  static const Color cardGrey = Color(0xFF1E293B);  // Slate
  static const Color primaryViolet = Color(0xFF7C3AED); // Neon Violet
  static const Color accentCyan = Color(0xFF06B6D4);    // Electric Cyan
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
}
```
---

# lib/core/theme.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get electronicTheme {
    final base = ThemeData.dark();
    
    return base.copyWith(
      scaffoldBackgroundColor: AppConstants.bgBlack,
      primaryColor: AppConstants.primaryViolet,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.primaryViolet,
        secondary: AppConstants.accentCyan,
        surface: AppConstants.cardGrey,
        error: AppConstants.errorRed,
      ),

      // Typography (Orbitron for headers, Roboto for body)
      textTheme: GoogleFonts.orbitronTextTheme(base.textTheme).copyWith(
        bodyMedium: GoogleFonts.roboto(color: Colors.white70),
        bodyLarge: GoogleFonts.roboto(color: Colors.white),
      ),

      // Input Fields (Glowing Borders)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.cardGrey,
        hintStyle: const TextStyle(color: Colors.white30),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.accentCyan, width: 2),
        ),
      ),
      
      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Orbitron', 
          fontSize: 20, 
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: Colors.white
        ),
      ),
    );
  }
}
```
---

# lib/features/auth/login_screen.dart
```dart
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
```
---

# lib/features/auth/splash_screen.dart
```dart
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
```
---

# lib/features/dashboard/home_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          FadeInDown(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("WELCOME BACK", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 5),
                    Text("COMMANDER", style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryViolet.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppConstants.primaryViolet),
                  ),
                  child: const Text("ONLINE", style: TextStyle(color: AppConstants.primaryViolet, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Stats Grid
          const Text("LIVE TELEMETRY", style: TextStyle(color: AppConstants.accentCyan, letterSpacing: 1.5)),
          const SizedBox(height: 15),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard("ATTENDEES", "1,240", Icons.people, Colors.blue),
              _buildStatCard("REVENUE", "\$45K", Icons.attach_money, Colors.green),
              _buildStatCard("VOLUNTEERS", "85", Icons.handshake, Colors.orange),
              _buildStatCard("EVENTS", "12", Icons.event, Colors.purple),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Recent Activity Placeholder
          const Text("SYSTEM LOGS", style: TextStyle(color: AppConstants.accentCyan, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.cardGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                _LogItem(text: "User #8921 Verified Payment", time: "2 min ago"),
                Divider(color: Colors.white10),
                _LogItem(text: "Volunteer A. updated Event B", time: "15 min ago"),
                Divider(color: Colors.white10),
                _LogItem(text: "New Registration: Jane Doe", time: "1 hr ago"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.cardGrey,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final String text;
  final String time;
  const _LogItem({required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
```
---

# lib/features/dashboard/main_layout.dart
```dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../notifications/notification_screen.dart';
import '../scanner/scanner_screen.dart';
import '../../core/api_service.dart';
import '../auth/login_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomeScreen(), // 0
    const SizedBox(),   // 1 (Placeholder for Scanner)
    const NotificationScreen(), // 2
  ];

  void _onTabTapped(int index) {
    if (index == 1) {
      // If scanner clicked, open it as a modal or new screen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar changes based on page
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? "COMMAND CENTER" : "ALERTS"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
            onPressed: _logout,
          )
        ],
      ),
      body: _pages[_currentIndex],
      
      // THE BIG BUTTON
      floatingActionButton: SizedBox(
        height: 70, 
        width: 70,
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerScreen())),
          backgroundColor: const Color(0xFF06B6D4), // Cyan
          elevation: 10,
          shape: const CircleBorder(),
          child: const Icon(Icons.qr_code_2, size: 35, color: Colors.black),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // THE NAV BAR
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: const Color(0xFF1E293B),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.dashboard_rounded, 
                  color: _currentIndex == 0 ? const Color(0xFF7C3AED) : Colors.grey),
                onPressed: () => _onTabTapped(0),
              ),
              const SizedBox(width: 40), // Space for FAB
              IconButton(
                icon: Icon(Icons.notifications_active, 
                  color: _currentIndex == 2 ? const Color(0xFF7C3AED) : Colors.grey),
                onPressed: () => _onTabTapped(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
---

# lib/features/notifications/notification_screen.dart
```dart
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: index == 0 ? Colors.red : const Color(0xFF06B6D4), width: 4))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                index == 0 ? "URGENT: Main Stage Wiring" : "New Registration",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 5),
              const Text("Just now", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}
```
---

# lib/features/scanner/scan_result_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/api_service.dart';

class ScanResultScreen extends StatefulWidget {
  final String userId;
  const ScanResultScreen({super.key, required this.userId});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await _api.scanUser(widget.userId);
    setState(() {
      _userData = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PARTICIPANT DATA"), backgroundColor: Colors.transparent),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
          : _userData == null
              ? _buildErrorState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 1. Profile Header
                      FadeInDown(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF7C3AED),
                          child: Text(_userData!['name'][0].toUpperCase(), style: const TextStyle(fontSize: 30, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(_userData!['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(_userData!['email'], style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 30),

                      // 2. Payment Status Card (CRITICAL)
                      FadeInUp(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: _userData!['isPaymentVerified'] == true ? Colors.green : Colors.red,
                              width: 2
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _userData!['isPaymentVerified'] == true ? Icons.check_circle : Icons.cancel,
                                color: _userData!['isPaymentVerified'] == true ? Colors.green : Colors.red,
                                size: 40,
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("PAYMENT STATUS", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text(
                                    _userData!['isPaymentVerified'] == true ? "VERIFIED" : "PENDING / FAILED",
                                    style: TextStyle(
                                      color: _userData!['isPaymentVerified'] == true ? Colors.green : Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // 3. Events List
                      const Align(alignment: Alignment.centerLeft, child: Text("REGISTERED EVENTS", style: TextStyle(color: Color(0xFF06B6D4), letterSpacing: 1.5))),
                      const SizedBox(height: 10),
                      
                      // Check if 'events' array exists and is not empty
                      (_userData!['events'] != null && (_userData!['events'] as List).isNotEmpty)
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (_userData!['events'] as List).length,
                            itemBuilder: (ctx, index) {
                              final event = _userData!['events'][index];
                              return Card(
                                color: const Color(0xFF0B0E14),
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.white.withOpacity(0.1))),
                                child: ListTile(
                                  leading: const Icon(Icons.event_note, color: Colors.purpleAccent),
                                  title: Text(event['name'] ?? 'Event Name', style: const TextStyle(color: Colors.white)),
                                  subtitle: Text(event['date'] ?? 'TBA', style: const TextStyle(color: Colors.grey)),
                                ),
                              );
                            },
                          )
                        : const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("No events registered", style: TextStyle(color: Colors.grey)),
                          ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 10),
          const Text("User Not Found", style: TextStyle(color: Colors.red, fontSize: 18)),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Go Back"))
        ],
      ),
    );
  }
}
```
---

# lib/features/scanner/scanner_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants.dart';
import 'scan_result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isNavigating = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isNavigating) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isNavigating = true);
        
        final String userId = barcode.rawValue!;
        controller.stop(); // Pause Camera

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(userId: userId),
          ),
        ).then((_) {
          // Resume when coming back
          setState(() => _isNavigating = false);
          controller.start();
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("OPTICAL SCANNER"),
        backgroundColor: Colors.black54,
        iconTheme: const IconThemeData(color: AppConstants.accentCyan),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: SizedBox.expand(),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "ALIGN QR DATA MATRIX",
                style: TextStyle(
                  color: AppConstants.accentCyan.withOpacity(0.8),
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Re-using the Painter from before
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.8)..style = PaintingStyle.fill;
    const double scanSize = 280;
    final double left = (size.width - scanSize) / 2;
    final double top = (size.height - scanSize) / 2;
    final rect = Rect.fromLTWH(left, top, scanSize, scanSize);
    
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height))..addRect(rect);
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    final borderPaint = Paint()..color = AppConstants.accentCyan..style = PaintingStyle.stroke..strokeWidth = 3;
    final double len = 30;
    
    // Draw corners (Simplified for brevity)
    canvas.drawLine(Offset(left, top), Offset(left + len, top), borderPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + len), borderPaint);
    canvas.drawLine(Offset(left + scanSize, top), Offset(left + scanSize - len, top), borderPaint);
    canvas.drawLine(Offset(left + scanSize, top), Offset(left + scanSize, top + len), borderPaint);
    // Add bottom corners similarly...
    canvas.drawLine(Offset(left, top + scanSize), Offset(left + len, top + scanSize), borderPaint);
    canvas.drawLine(Offset(left, top + scanSize), Offset(left, top + scanSize - len), borderPaint);
    canvas.drawLine(Offset(left + scanSize, top + scanSize), Offset(left + scanSize - len, top + scanSize), borderPaint);
    canvas.drawLine(Offset(left + scanSize, top + scanSize), Offset(left + scanSize, top + scanSize - len), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```
---

# lib/main.dart
```dart
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
```
---