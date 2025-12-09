import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/api_service.dart';
import '../../core/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userData = await _api.getProfile();
    if (mounted) {
      setState(() {
        _user = userData;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppConstants.primaryViolet));
    }

    if (_user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Failed to load profile", style: TextStyle(color: Colors.white)),
            TextButton(onPressed: _fetchUserData, child: const Text("Retry"))
          ],
        ),
      );
    }

    // Extracting Real Data
    final String name = _user?['name'] ?? 'Cadet';
    final String role = _user?['role']?.toString().toUpperCase() ?? 'UNKNOWN';
    final String jnanagniId = _user?['jnanagniId'] ?? 'PENDING';
    final List events = _user?['events'] ?? [];

    return Scaffold(
      backgroundColor: AppConstants.bgBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER PROFILE
              FadeInDown(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("WELCOME BACK", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, letterSpacing: 2)),
                        const SizedBox(height: 5),
                        Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Orbitron')),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryViolet.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppConstants.primaryViolet),
                      ),
                      child: Text(role, style: const TextStyle(color: AppConstants.primaryViolet, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2. ID CARD
              FadeInUp(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppConstants.cardGrey, AppConstants.cardGrey.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [BoxShadow(color: AppConstants.primaryViolet.withOpacity(0.1), blurRadius: 20, spreadRadius: 0)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.qr_code_2, color: Colors.white, size: 40),
                          Text("JNANAGNI 2025", style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(jnanagniId, style: const TextStyle(color: AppConstants.accentCyan, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Orbitron')),
                      const SizedBox(height: 5),
                      Text("OFFICIAL ID", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 3. REGISTRATIONS LIST
              const Text("MISSION LOG (EVENTS)", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Orbitron')),
              const SizedBox(height: 15),

              events.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppConstants.cardGrey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("No events registered yet.", style: TextStyle(color: Colors.white54)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppConstants.cardGrey,
                            borderRadius: BorderRadius.circular(12),
                            border: Border(left: BorderSide(color: AppConstants.successGreen, width: 4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(event['eventName'] ?? "Unknown Event", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const Icon(Icons.check_circle, color: AppConstants.successGreen, size: 18)
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}