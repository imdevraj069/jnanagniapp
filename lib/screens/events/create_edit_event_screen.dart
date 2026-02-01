import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';
import '../../constants/api_constants.dart';
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
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  // --- PARTICIPATION SECTION STATE ---
  bool _isSoloEvent = true;
  final _maxRegistrationsCtrl = TextEditingController(text: '0');
  // New controllers for team sizes (defaults set based on your image)
  final _minTeamSizeCtrl = TextEditingController(text: '2');
  final _maxTeamSizeCtrl = TextEditingController(text: '5');

  // Dynamic Fields Lists
  List<Map<String, dynamic>> registrationFields = [];
  List<Map<String, dynamic>> volunteerFields = [];
  List<Map<String, dynamic>> memberFields = [];

  final List<String> _fieldTypes = [
    'Text',
    'Number',
    'Long Text',
    'Date',
    'Email',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.eventData != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    _nameCtrl.text = widget.eventData!['name'] ?? '';
    _descCtrl.text = widget.eventData!['description'] ?? '';
    _venueCtrl.text = widget.eventData!['venue'] ?? '';

    if (widget.eventData!['date'] != null) {
      _selectedDate = DateTime.tryParse(widget.eventData!['date']);
    }

    // --- LOAD PARTICIPATION DATA ---
    _isSoloEvent = widget.eventData!['isSolo'] ?? true;
    _maxRegistrationsCtrl.text =
        widget.eventData!['maxRegistrations']?.toString() ?? '0';
    // Load team sizes if they exist, otherwise keep defaults
    if (!_isSoloEvent) {
      _minTeamSizeCtrl.text =
          widget.eventData!['minTeamSize']?.toString() ?? '2';
      _maxTeamSizeCtrl.text =
          widget.eventData!['maxTeamSize']?.toString() ?? '5';
    }

    if (widget.eventData!['registrationFields'] != null) {
      registrationFields = List<Map<String, dynamic>>.from(
        widget.eventData!['registrationFields'],
      );
    }
    if (widget.eventData!['memberFields'] != null) {
      memberFields = List<Map<String, dynamic>>.from(
        widget.eventData!['memberFields'],
      );
    }
    if (widget.eventData!['volunteerFields'] != null) {
      volunteerFields = List<Map<String, dynamic>>.from(
        widget.eventData!['volunteerFields'],
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    _maxRegistrationsCtrl.dispose();
    // Dispose new controllers
    _minTeamSizeCtrl.dispose();
    _maxTeamSizeCtrl.dispose();
    super.dispose();
  }

  void _addField(List<Map<String, dynamic>> list) {
    setState(() {
      list.add({'label': '', 'type': 'Text', 'required': false});
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: CyberColors.neonCyan,
              onPrimary: Colors.black,
              surface: CyberColors.bgCard,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: CyberColors.bgSecondary,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty ||
        _venueCtrl.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name, Venue, and Date are required!"),
          backgroundColor: CyberColors.neonPink,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Parse numeric inputs
    int maxReg = int.tryParse(_maxRegistrationsCtrl.text) ?? 0;
    int minTeam = int.tryParse(_minTeamSizeCtrl.text) ?? 1;
    int maxTeam = int.tryParse(_maxTeamSizeCtrl.text) ?? 1;

    final data = {
      'name': _nameCtrl.text,
      'description': _descCtrl.text,
      'venue': _venueCtrl.text,
      'date': _selectedDate!.toIso8601String(),
      // --- PARTICIPATION DATA ---
      'isSolo': _isSoloEvent,
      'maxRegistrations': maxReg,
      // Only send team sizes if it's a group event
      if (!_isSoloEvent) 'minTeamSize': minTeam,
      if (!_isSoloEvent) 'maxTeamSize': maxTeam,
      'registrationFields': registrationFields,
      'volunteerFields': volunteerFields,
      'memberFields': memberFields,
    };

    try {
      if (widget.eventData == null) {
        await ApiService().post(ApiConstants.myEvents, data);
      } else {
        // await ApiService().put('${ApiConstants.myEvents}/${widget.eventData!['_id']}', data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgPrimary,
      appBar: AppBar(
        title: Text(widget.eventData == null ? "Create Event" : "Edit Event"),
        backgroundColor: CyberColors.bgSecondary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CyberInput(label: "Event Name", controller: _nameCtrl),
            const SizedBox(height: 16),

            const Text(
              "Event Date",
              style: TextStyle(color: CyberColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: CyberColors.borderColor),
                  borderRadius: BorderRadius.circular(8),
                  color: CyberColors.bgCard.withOpacity(0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? "Select Date"
                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                      style: TextStyle(
                        color: _selectedDate == null
                            ? Colors.grey
                            : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: CyberColors.neonCyan,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            CyberInput(label: "Description", controller: _descCtrl),
            const SizedBox(height: 16),
            CyberInput(label: "Venue", controller: _venueCtrl),
            const SizedBox(height: 30),

            // --- PARTICIPATION SECTION ---
            _buildParticipationSection(),
            const SizedBox(height: 30),

            _buildSectionHeader(
              "Registration Fields",
              () => _addField(registrationFields),
            ),
            _buildDynamicFieldList(registrationFields),

            const SizedBox(height: 30),

            _buildSectionHeader(
              "Member Fields",
              () => _addField(memberFields),
              color: CyberColors.neonPink,
            ),
            _buildDynamicFieldList(memberFields),

            const SizedBox(height: 30),

            _buildSectionHeader(
              "Volunteer Fields",
              () => _addField(volunteerFields),
              color: CyberColors.neonPurple,
            ),
            _buildDynamicFieldList(volunteerFields),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberColors.neonCyan,
                  disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "SAVE EVENT",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UPDATED PARTICIPATION SECTION WIDGET ---
  Widget _buildParticipationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberColors.bgCard,
        border: Border.all(color: CyberColors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Participation Type",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Theme(
            data: Theme.of(
              context,
            ).copyWith(unselectedWidgetColor: Colors.grey),
            child: Column(
              children: [
                RadioListTile<bool>(
                  title: const Text(
                    "Solo Event",
                    style: TextStyle(color: Colors.white),
                  ),
                  value: true,
                  groupValue: _isSoloEvent,
                  activeColor: CyberColors.neonCyan,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setState(() {
                      _isSoloEvent = val!;
                      // REQUIREMENT: If Solo, set Max Reg to 0 automatically
                      if (_isSoloEvent) {
                        _maxRegistrationsCtrl.text = '0';
                      }
                    });
                  },
                ),
                RadioListTile<bool>(
                  title: const Text(
                    "Group Event (Team Based)",
                    style: TextStyle(color: Colors.white),
                  ),
                  value: false,
                  groupValue: _isSoloEvent,
                  activeColor: CyberColors.neonCyan,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setState(() {
                      _isSoloEvent = val!;
                      // Optional: Reset max reg if switching back to group, or leave as is.
                      // _maxRegistrationsCtrl.text = '0';
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- NEW: TEAM SIZE INPUTS (Only visible if Group Event) ---
          if (!_isSoloEvent) ...[
            Row(
              children: [
                Expanded(
                  child: _buildNumberInput("Min Team Size", _minTeamSizeCtrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberInput("Max Team Size", _maxTeamSizeCtrl),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Max Registrations Input
          // REQUIREMENT: Disabled if Solo Event
          _buildNumberInput(
            "Max Registrations (0 = Unlimited)",
            _maxRegistrationsCtrl,
            enabled: !_isSoloEvent,
          ),
        ],
      ),
    );
  }

  // Helper for consistent number inputs in this section
  Widget _buildNumberInput(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: enabled ? CyberColors.textSecondary : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(color: enabled ? Colors.white : Colors.grey[500]),
          decoration: InputDecoration(
            filled: true,
            // Use a darker color if disabled to visually indicate it's locked
            fillColor: enabled
                ? CyberColors.bgPrimary
                : Colors.black.withOpacity(0.3),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: CyberColors.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: CyberColors.neonCyan),
              borderRadius: BorderRadius.circular(8),
            ),
            // Style the border when disabled
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    VoidCallback onAdd, {
    Color color = CyberColors.neonGreen,
  }) {
    // ... (This function remains unchanged from previous versions)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        InkWell(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.add, color: color, size: 18),
                const SizedBox(width: 4),
                Text(
                  "ADD FIELD",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicFieldList(List<Map<String, dynamic>> fieldList) {
    // ... (This function remains unchanged from previous versions)
    if (fieldList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          "No custom fields added yet.",
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      children: fieldList.asMap().entries.map((entry) {
        int idx = entry.key;
        Map<String, dynamic> field = entry.value;

        return Container(
          margin: const EdgeInsets.only(top: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CyberColors.bgCard,
            border: Border.all(color: CyberColors.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "LABEL",
                          style: TextStyle(
                            color: CyberColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          initialValue: field['label'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: "e.g. Github ID",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) => field['label'] = val,
                        ),
                        Container(height: 1, color: CyberColors.borderColor),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "TYPE",
                          style: TextStyle(
                            color: CyberColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _fieldTypes.contains(field['type'])
                              ? field['type']
                              : 'Text',
                          dropdownColor: CyberColors.bgSecondary,
                          isExpanded: true,
                          underline: Container(
                            height: 1,
                            color: CyberColors.borderColor,
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: CyberColors.neonCyan,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          items: _fieldTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => field['type'] = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: field['required'],
                          activeColor: CyberColors.neonCyan,
                          checkColor: Colors.black,
                          side: const BorderSide(color: Colors.grey),
                          onChanged: (val) =>
                              setState(() => field['required'] = val),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Required",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => setState(() => fieldList.removeAt(idx)),
                    child: const Icon(
                      Icons.delete_outline,
                      color: CyberColors.neonPink,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
