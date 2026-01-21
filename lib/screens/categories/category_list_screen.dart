import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final ApiService _api = ApiService();
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.get('/events/categories');
      setState(() => categories = res['data']);
    } catch(e) { print(e); }
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: CyberColors.bgCard,
        title: const Text("New Category", style: TextStyle(color: CyberColors.neonCyan)),
        content: TextField(
          controller: nameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: "Name", labelStyle: TextStyle(color: Colors.grey)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            child: const Text("Create", style: TextStyle(color: CyberColors.neonGreen)),
            onPressed: () async {
              await _api.post('/admin/categories', {'name': nameCtrl.text});
              Navigator.pop(context);
              _load();
            },
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPrimary,
      floatingActionButton: FloatingActionButton(
        backgroundColor: CyberColors.neonCyan,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          return Card(
            color: CyberColors.bgCard,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(cat['name'], style: const TextStyle(color: Colors.white)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: CyberColors.neonPink),
                onPressed: () async {
                  await _api.delete('/admin/categories/${cat['_id']}');
                  _load();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}