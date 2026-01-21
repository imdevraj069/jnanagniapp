import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../constants/api_constants.dart';
import 'create_edit_event_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final ApiService _api = ApiService();
  List<dynamic> events = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      // FIX: Use ApiConstants.myEvents defined in step 1
      // This hits /admin/my-events, which returns the array directly based on your Node code
      final res = await _api.get(ApiConstants.myEvents);
      
      setState(() {
        // Node backend returns array directly for /my-events, OR {data: []} check both
        if (res is List) {
          events = res;
        } else if (res['data'] != null && res['data'] is List) {
           events = res['data'];
        } else {
           events = [];
        }
        loading = false;
      });
    } catch (e) {
      print("Event Load Error: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: CyberColors.bgSecondary,
        title: const Text("Events Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: CyberColors.neonCyan),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEditEventScreen())).then((_) => _fetchEvents()),
          )
        ],
      ),
      body: loading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView.builder(
            itemCount: events.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                color: CyberColors.bgCard,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: CyberColors.borderColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(event['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("${event['venue']} • ${event['date'].toString().substring(0,10)}", style: const TextStyle(color: CyberColors.textSecondary)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: CyberColors.neonCyan, size: 16),
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEditEventScreen(eventData: event)));
                  },
                ),
              );
            },
          ),
    );
  }
}