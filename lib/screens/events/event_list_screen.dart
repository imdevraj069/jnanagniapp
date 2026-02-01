import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'create_edit_event_screen.dart';
import 'registration_list_screen.dart'; // Ensure this file exists

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  // 1. HARDCODED MOCK DATA
  // I used the exact names from your screenshot
  final List<Map<String, dynamic>> _mockEvents = [
    {
      '_id': '101',
      'name': 'Free Fire: The Championship Series',
      'venue': 'Online',
      'date': '2026-02-12T10:00:00Z',
      'description': 'Battle Royale qualifiers.'
    },
    {
      '_id': '102',
      'name': 'ROBO WAR / ROBO RACE',
      'venue': 'Main Ground',
      'date': '2026-02-27T09:00:00Z',
      'description': 'Robot combat and racing event.'
    },
    {
      '_id': '103',
      'name': 'TECH QUIZ',
      'venue': 'Auditorium',
      'date': '2026-02-26T11:00:00Z',
      'description': 'Test your technical knowledge.'
    },
    {
      '_id': '104',
      'name': 'CODE DEBUGGING',
      'venue': 'Lab 3',
      'date': '2026-02-27T14:00:00Z',
      'description': 'Find the bugs in the given code snippets.'
    },
  ];

  List<Map<String, dynamic>> events = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadMockEvents();
  }

  // 2. MOCK FETCH FUNCTION
  Future<void> _loadMockEvents() async {
    // Simulate a network delay of 1 second
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        events = List.from(_mockEvents); // Load the hardcoded list
        loading = false;
      });
    }
  }

  // 3. POP-UP MENU (Bottom Sheet)
  void _showEventOptions(Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: CyberColors.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: CyberColors.neonCyan, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 5,
              margin: const EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)),
            ),
            
            // Manage Button
            _buildOptionTile(
              icon: Icons.edit,
              title: "Manage Event",
              color: CyberColors.neonCyan,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEditEventScreen(eventData: event)));
              },
            ),

            // Registration Button
            _buildOptionTile(
              icon: Icons.people_alt_outlined,
              title: "View Registrations",
              color: CyberColors.neonGreen,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationListScreen(eventId: event['_id'])));
              },
            ),

            const Divider(color: Colors.grey),

            // Delete Button
            _buildOptionTile(
              icon: Icons.delete_outline,
              title: "Delete Event",
              color: CyberColors.neonPink,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(event);
              },
            ),
            const SizedBox(height: 25,)
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  // 4. MOCK DELETE FUNCTION
  void _confirmDelete(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CyberColors.bgSecondary,
        title: const Text("Delete Event?", style: TextStyle(color: CyberColors.neonPink)),
        content: Text("Are you sure you want to delete '${event['name']}'?", 
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                // Remove the item locally from the list
                events.removeWhere((element) => element['_id'] == event['_id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Event deleted (Mock Mode)"), backgroundColor: CyberColors.neonPink)
              );
            },
            child: const Text("Delete", style: TextStyle(color: CyberColors.neonPink)),
          ),
        ],
      ),
    );
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
            onPressed: () {
               // Navigation to create screen
               Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEditEventScreen()));
            },
          )
        ],
      ),
      body: loading 
        ? const Center(child: CircularProgressIndicator(color: CyberColors.neonCyan)) 
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
                  subtitle: Text("${event['venue']} • ${event['date'].substring(0,10)}", 
                      style: const TextStyle(color: CyberColors.textSecondary)),
                  trailing: const Icon(Icons.more_vert, color: Colors.grey), 
                  // Trigger the pop-up on tap
                  onTap: () => _showEventOptions(event),
                ),
              );
            },
          ),
    );
  }
}