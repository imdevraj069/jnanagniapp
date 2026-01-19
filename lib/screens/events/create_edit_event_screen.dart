import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/api_service.dart';
import '../../widgets/cyber_input.dart';

class CreateEditEventScreen extends StatefulWidget {
  final Map<String, dynamic>? eventData;
  const CreateEditEventScreen({super.key, this.eventData});

  @override
  State<CreateEditEventScreen> createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  
  // Dynamic Fields
  List<Map<String, dynamic>> registrationFields = [];

  @override
  void initState() {
    super.initState();
    if (widget.eventData != null) {
      _nameCtrl.text = widget.eventData!['name'];
      _descCtrl.text = widget.eventData!['description'];
      _venueCtrl.text = widget.eventData!['venue'];
      
      // Load dynamic fields
      if (widget.eventData!['registrationFields'] != null) {
        registrationFields = List<Map<String, dynamic>>.from(widget.eventData!['registrationFields']);
      }
    }
  }

  void _addCustomField() {
    setState(() {
      registrationFields.add({
        'fieldLabel': '',
        'fieldType': 'text',
        'required': false
      });
    });
  }

  Future<void> _submit() async {
    // Collect data and call API
    // Note: Use MultipartRequest in ApiService for file uploads if needed
    final data = {
      'name': _nameCtrl.text,
      'description': _descCtrl.text,
      'venue': _venueCtrl.text,
      'registrationFields': registrationFields, // Send as JSON array
      // Add other fields...
    };
    
    // Call ApiService.post or put based on edit/create
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPrimary,
      appBar: AppBar(title: Text(widget.eventData == null ? "Create Event" : "Edit Event"), backgroundColor: CyberColors.bgSecondary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CyberInput(label: "Event Name", controller: _nameCtrl),
            const SizedBox(height: 16),
            CyberInput(label: "Description", controller: _descCtrl),
            const SizedBox(height: 16),
            CyberInput(label: "Venue", controller: _venueCtrl),
            const SizedBox(height: 24),
            
            // Dynamic Fields Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Registration Fields", style: TextStyle(color: CyberColors.neonCyan, fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.add_circle, color: CyberColors.neonGreen), onPressed: _addCustomField)
              ],
            ),
            ...registrationFields.asMap().entries.map((entry) {
              int idx = entry.key;
              Map<String, dynamic> field = entry.value;
              return Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: CyberColors.borderColor),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: "Field Label (e.g. Github ID)", labelStyle: TextStyle(color: Colors.grey)),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => field['fieldLabel'] = val,
                      controller: TextEditingController(text: field['fieldLabel']),
                    ),
                    Row(
                      children: [
                        const Text("Required?", style: TextStyle(color: Colors.white)),
                        Checkbox(
                          value: field['required'], 
                          activeColor: CyberColors.neonCyan,
                          onChanged: (val) => setState(() => field['required'] = val)
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete, color: CyberColors.neonPink), 
                          onPressed: () => setState(() => registrationFields.removeAt(idx))
                        )
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: CyberColors.neonCyan),
                child: const Text("SAVE EVENT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}