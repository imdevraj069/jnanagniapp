import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../users/user_detail_screen.dart';

class PaymentPendingScreen extends StatefulWidget {
  const PaymentPendingScreen({super.key});

  @override
  State<PaymentPendingScreen> createState() => _PaymentPendingScreenState();
}

class _PaymentPendingScreenState extends State<PaymentPendingScreen> {
  final ApiService _api = ApiService();
  List<dynamic> payments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    try {
      final res = await _api.get('/users/payments/pending');
      setState(() {
        payments = res['data'] is List ? res['data'] : [];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPrimary,
      body: loading 
        ? const Center(child: CircularProgressIndicator()) 
        : payments.isEmpty 
          ? const Center(child: Text("No Pending Payments", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: payments.length,
              itemBuilder: (ctx, i) {
                final u = payments[i];
                return Card(
                  color: CyberColors.bgCard,
                  child: ListTile(
                    title: Text(u['name'], style: const TextStyle(color: Colors.white)),
                    subtitle: Text("ID: ${u['jnanagniId']}", style: const TextStyle(color: CyberColors.neonCyan)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: CyberColors.neonGreen),
                      child: const Text("Verify", style: TextStyle(color: Colors.black)),
                      onPressed: () async {
                         await Navigator.push(context, MaterialPageRoute(builder: (_) => UserDetailScreen(userId: u['_id'])));
                         _fetchPayments(); // Refresh on return
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}