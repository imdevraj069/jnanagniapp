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