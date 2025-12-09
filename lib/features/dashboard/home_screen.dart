import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants.dart';
import '../../core/api_service.dart'; // Import ApiService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  
  // Default values while loading
  String _userName = "COMMANDER";
  String _userRole = "OFFLINE";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final userData = await _api.getProfile();
    
    if (mounted && userData != null) {
      setState(() {
        _userName = userData['name'] ?? "Unknown";
        // Convert 'student' to 'STUDENT'
        _userRole = (userData['role'] ?? "GUEST").toString().toUpperCase(); 
        _isLoading = false;
      });
    }
  }

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
                    
                    // [UPDATED] Shows real name or a loading skeleton
                    _isLoading 
                      ? Container(width: 150, height: 30, color: Colors.white10) // Skeleton
                      : Text(_userName.toUpperCase(), style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryViolet.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppConstants.primaryViolet),
                  ),
                  // [UPDATED] Shows real role (e.g., ADMIN, STUDENT)
                  child: Text(
                    _userRole, 
                    style: const TextStyle(color: AppConstants.primaryViolet, fontSize: 10, fontWeight: FontWeight.bold)
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 30),

          // Stats Grid (Keep existing code)
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
          
          // Recent Activity (Keep existing code)
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

  // Helper widget reused from your code
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