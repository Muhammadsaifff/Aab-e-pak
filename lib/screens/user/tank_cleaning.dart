import 'package:flutter/material.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';
import '../../services/order_service.dart';

class TankCleaningScreen extends StatefulWidget {
  const TankCleaningScreen({super.key});

  @override
  State<TankCleaningScreen> createState() => _TankCleaningScreenState();
}

class _TankCleaningScreenState extends State<TankCleaningScreen> {
  final _addressController = TextEditingController();
  final List<String> tankTypes = ['Underground', 'Overhead', 'Both'];
  String selectedType = 'Underground';
  String deliveryType = 'Immediate';
  DateTime? scheduledDateTime;

  int get price {
    switch (selectedType) {
      case 'Overhead':
        return 5000;
      case 'Both':
        return 7000;
      case 'Underground':
      default:
        return 3000;
    }
  }

  void _submitCleaningRequest() async {
    if (_addressController.text.isEmpty) {
      AppSnackbar.show(context, "Please enter your tank location address.");
      return;
    }

    await OrderService.submitOrder({
      'type': 'Tank Cleaning',
      'tankType': selectedType,
      'address': _addressController.text,
      'deliveryType': deliveryType,
      'scheduledTime': deliveryType == 'Scheduled'
          ? scheduledDateTime?.toIso8601String()
          : null,
      'price': price,
    });

    if (mounted) {
      AppSnackbar.show(context, "Tank cleaning request submitted!");
      Navigator.pop(context);
    }
  }

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null || !mounted) return;

    setState(() {
      scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Tank Cleaning Service"),
        centerTitle: true,
      ),
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Tank Type"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: tankTypes.map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: selectedType == type,
                        onSelected: (_) => setState(() => selectedType = type),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  AppInputField(
                    controller: _addressController,
                    labelText: "Service Location Address",
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 20),
                  const Text("Service Type"),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Immediate',
                        groupValue: deliveryType,
                        onChanged: (value) => setState(() => deliveryType = value!),
                      ),
                      const Text("Immediate"),
                      Radio<String>(
                        value: 'Scheduled',
                        groupValue: deliveryType,
                        onChanged: (value) => setState(() => deliveryType = value!),
                      ),
                      const Text("Scheduled"),
                    ],
                  ),
                  if (deliveryType == 'Scheduled')
                    TextButton.icon(
                      onPressed: _pickDateTime,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        scheduledDateTime == null
                            ? "Pick Date & Time"
                            : "${scheduledDateTime!.toLocal()}".split('.')[0],
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Service Price: Rs. $price",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          AppSnackbar.show(context, "This feature is under development");
                        },
                        icon: const Icon(Icons.handshake, size: 18),
                        label: const Text("Bargain"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: AppButton(
                      text: "Confirm Cleaning",
                      onPressed: _submitCleaningRequest,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
