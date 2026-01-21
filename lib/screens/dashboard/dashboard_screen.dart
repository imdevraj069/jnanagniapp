import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/api_constants.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? stats;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final res = await _api.get(ApiConstants.stats);
      if (mounted) setState(() { stats = res['data']; loading = false; });
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      backgroundColor: CyberColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Profile & Search)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Jnanagni ADMIN", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(user?['name'] ?? "Commander", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: CyberColors.neonCyan,
                    child: Text(user?['name']?[0] ?? "A", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 20),
              
              // 2. SEARCH BAR (Visual only per sketch)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                height: 50,
                decoration: BoxDecoration(
                  color: CyberColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CyberColors.borderColor)
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 10),
                    Text("Search users, events...", style: TextStyle(color: Colors.grey))
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // 3. STATS OVERVIEW (From Sketch)
              const Text("Fest Overview", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CyberColors.bgCard,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: CyberColors.borderColor)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(stats?['totalRegistrations']?.toString() ?? "0", "Total\nRegister"),
                    _buildVerticalDivider(),
                    _buildStatItem(stats?['totalUsers']?.toString() ?? "0", "Total\nUsers"), // Replaced Checked-in
                    _buildVerticalDivider(),
                    _buildStatItem(stats?['totalEvents']?.toString() ?? "0", "Live\nEvents"),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // 4. QUICK ACTIONS
              const Text("Quick Actions", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildActionCard(Icons.qr_code_scanner, "Scan Status", CyberColors.neonCyan)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildActionCard(Icons.check_circle_outline, "Mark Attend.", CyberColors.neonGreen)),
                ],
              ),
              const SizedBox(height: 25),

              // 5. MANAGEMENT CONSOLE (Grid)
              const Text("Management Console", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                childAspectRatio: 0.8,
                children: [
                  _buildConsoleIcon(Icons.app_registration, "Regis.", () {}),
                  _buildConsoleIcon(Icons.sports_esports, "Rounds", () {}),
                  _buildConsoleIcon(Icons.handshake, "Volun.", () {}),
                  _buildConsoleIcon(Icons.analytics, "Result", () {}),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildVerticalDivider() => Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.3));

  Widget _buildActionCard(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CyberColors.bgCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3))
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }

  Widget _buildConsoleIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CyberColors.bgSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CyberColors.borderColor)
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10))
        ],
      ),
    );
  }
}