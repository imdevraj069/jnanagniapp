import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final res = await _api.get('/users/${widget.userId}');
      setState(() {
        user = res['data'];
        loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _verifyPayment() async {
    try {
      await _api.put('/users/payments/verify/${widget.userId}', {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Verified!"), backgroundColor: CyberColors.neonGreen));
      _fetchDetails(); // Refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to verify"), backgroundColor: CyberColors.neonPink));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (user == null) return const Scaffold(body: Center(child: Text("User not found")));

    return Scaffold(
      backgroundColor: CyberColors.bgPrimary,
      appBar: AppBar(title: Text(user!['name'] ?? "User Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ID Card Style
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [CyberColors.bgSecondary, CyberColors.bgCard]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CyberColors.neonCyan),
                boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 10)]
              ),
              child: Column(
                children: [
                  const Icon(Icons.account_circle, size: 80, color: CyberColors.textSecondary),
                  const SizedBox(height: 10),
                  Text(user!['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(user!['jnanagniId'] ?? 'NO ID', style: const TextStyle(fontSize: 16, fontFamily: 'Monospace', color: CyberColors.neonCyan)),
                  const Divider(color: CyberColors.borderColor, height: 30),
                  _infoRow("Email", user!['email']),
                  _infoRow("College", user!['college']),
                  _infoRow("Phone", user!['contactNo']),
                  _infoRow("Role", user!['role']),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statusBadge("Email", user!['isVerified'] == true),
                      _statusBadge("Payment", user!['paymentStatus'] == 'verified'),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (user!['paymentStatus'] != 'verified')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.verified, color: Colors.black),
                  label: const Text("VERIFY PAYMENT MANUALLY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: CyberColors.neonGreen, padding: const EdgeInsets.all(15)),
                  onPressed: _verifyPayment,
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value ?? '-', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? CyberColors.neonGreen.withOpacity(0.2) : CyberColors.neonPink.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? CyberColors.neonGreen : CyberColors.neonPink)
      ),
      child: Text("$label: ${active ? 'OK' : 'PENDING'}", style: TextStyle(color: active ? CyberColors.neonGreen : CyberColors.neonPink, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}