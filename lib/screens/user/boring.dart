import 'package:flutter/material.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_snackbar.dart';
import '../../services/order_service.dart';

class BoringServiceScreen extends StatefulWidget {
  const BoringServiceScreen({super.key});

  @override
  State<BoringServiceScreen> createState() => _BoringServiceScreenState();
}

class _BoringServiceScreenState extends State<BoringServiceScreen> {
  final _addressController = TextEditingController();
  final _depthController = TextEditingController();
  String boringType = 'Residential';
  String serviceType = 'Immediate';
  DateTime? scheduledDateTime;

  int totalPrice = 0;

  static const int pricePerFoot = 200;

  void _updatePrice(String value) {
    final depth = int.tryParse(value) ?? 0;
    setState(() {
      totalPrice = depth * pricePerFoot;
    });
  }

  void _submitBoringRequest() async {
    final depth = int.tryParse(_depthController.text);
    if (_addressController.text.isEmpty || depth == null || depth <= 0) {
      AppSnackbar.show(context, "Please enter a valid address and depth.");
      return;
    }

    await OrderService.submitOrder({
      'type': 'Boring',
      'boringType': boringType,
      'depth': depth,
      'price': totalPrice,
      'address': _addressController.text,
      'deliveryType': serviceType,
      'scheduledTime': serviceType == 'Scheduled'
          ? scheduledDateTime?.toIso8601String()
          : null,
    });

    if (mounted) {
      AppSnackbar.show(context, "Boring service request submitted!");
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
        title: const Text("Water Boring Service"),
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
                  const Text("Select Boring Type"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: ['Residential', 'Commercial', 'Agricultural'].map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: boringType == type,
                        onSelected: (_) => setState(() => boringType = type),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _depthController,
                    keyboardType: TextInputType.number,
                    onChanged: _updatePrice,
                    decoration: const InputDecoration(
                      labelText: "Required Depth (in feet)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Estimated Price: Rs. $totalPrice",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                        groupValue: serviceType,
                        onChanged: (value) => setState(() => serviceType = value!),
                      ),
                      const Text("Immediate"),
                      Radio<String>(
                        value: 'Scheduled',
                        groupValue: serviceType,
                        onChanged: (value) => setState(() => serviceType = value!),
                      ),
                      const Text("Scheduled"),
                    ],
                  ),
                  if (serviceType == 'Scheduled')
                    TextButton.icon(
                      onPressed: _pickDateTime,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        scheduledDateTime == null
                            ? "Pick Date & Time"
                            : "${scheduledDateTime!.toLocal()}".split('.')[0],
                      ),
                    ),
                  const SizedBox(height: 30),
                  Center(
                    child: AppButton(
                      text: "Confirm Booking",
                      onPressed: _submitBoringRequest,
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
