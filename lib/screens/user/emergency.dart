import 'package:flutter/material.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';
import '../../services/order_service.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final TextEditingController _addressController = TextEditingController();
  final List<int> sizes = [500, 1000, 2000, 3000];
  int selectedSize = 1000;

  int get emergencyPrice => selectedSize * 5 + 1000;

  Future<void> _submitEmergencyOrder() async {
    if (_addressController.text.isEmpty) {
      AppSnackbar.show(context, "Please enter delivery address");
      return;
    }

    await OrderService.submitOrder({
      'type': 'Urgent Tanker',
      'size': selectedSize,
      'address': _addressController.text,
      'price': emergencyPrice,
    });

    if (mounted) {
      AppSnackbar.show(context, "Urgent order placed!");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Urgent Water Tanker Request")),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "This is a high-priority request and includes an extra charge of PKR 1000.",
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Select Tanker Size (in gallons)",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: sizes.map((size) {
                    return ChoiceChip(
                      label: Text('$size'),
                      selected: selectedSize == size,
                      onSelected: (_) => setState(() => selectedSize = size),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                AppInputField(
                  controller: _addressController,
                  labelText: "Enter Delivery Address",
                  keyboardType: TextInputType.streetAddress,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Total Price: Rs. $emergencyPrice",
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
                AppButton(
                  text: "Confirm Urgent Tanker",
                  onPressed: _submitEmergencyOrder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
