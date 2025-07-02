import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_snackbar.dart';

class ScheduledRefillsScreen extends StatefulWidget {
  const ScheduledRefillsScreen({super.key});

  @override
  State<ScheduledRefillsScreen> createState() => _ScheduledRefillsScreenState();
}

class _ScheduledRefillsScreenState extends State<ScheduledRefillsScreen> {
  String waterType = 'Tanker';
  String frequency = 'Weekly';
  TimeOfDay? selectedTime;
  final TextEditingController _addressController = TextEditingController();

  void _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  void _submitSchedule() {
    if (_addressController.text.isEmpty || selectedTime == null) {
      AppSnackbar.show(context, "Please fill all fields.");
      return;
    }

    String summary = '''
Water Type: $waterType
Frequency: $frequency
Time: ${selectedTime!.format(context)}
Address: ${_addressController.text}
    ''';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Refill Schedule"),
        content: Text(summary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppSnackbar.show(context, "Scheduled successfully!");
              Navigator.pop(context);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Schedule Refill")),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFe0f7fa), Color(0xFF80deea)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Choose Water Type"),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Tanker',
                        groupValue: waterType,
                        onChanged: (value) => setState(() => waterType = value!),
                      ),
                      const Text("Tanker"),
                      Radio<String>(
                        value: 'Bottled',
                        groupValue: waterType,
                        onChanged: (value) => setState(() => waterType = value!),
                      ),
                      const Text("Bottled"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text("Select Frequency"),
                  DropdownButton<String>(
                    value: frequency,
                    isExpanded: true,
                    items: ['Daily', 'Weekly', 'Bi-weekly']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (value) => setState(() => frequency = value!),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: Text(
                      selectedTime == null
                          ? "Pick Refill Time"
                          : selectedTime!.format(context),
                    ),
                    onPressed: _pickTime,
                  ),
                  const SizedBox(height: 20),

                  AppInputField(
                    controller: _addressController,
                    labelText: "Enter Delivery Address",
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 30),

                  AppButton(text: "Schedule Refill", onPressed: _submitSchedule),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
