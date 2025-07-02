import 'package:flutter/material.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/app_snackbar.dart';
import '../../services/order_service.dart';

class BottleBookingScreen extends StatefulWidget {
  const BottleBookingScreen({super.key});

  @override
  State<BottleBookingScreen> createState() => _BottleBookingScreenState();
}

class _BottleBookingScreenState extends State<BottleBookingScreen> {
  final List<String> brands = ['Nestlé', 'Aquafina', 'Kinley', 'Local Brand'];
  final TextEditingController _addressController = TextEditingController();

  String? selectedBrand;
  int quantity = 1;
  bool returnBottles = false;
  String frequency = 'One-time';

  int _getPrice() {
    const int basePrice = 250;
    return quantity * basePrice;
  }

  Future<void> _submitOrder() async {
    if (selectedBrand == null) {
      AppSnackbar.show(context, "Please select a brand.");
      return;
    }
    if (_addressController.text.isEmpty) {
      AppSnackbar.show(context, "Please enter a delivery address.");
      return;
    }

    await OrderService.submitOrder({
      'type': 'Bottled Water',
      'brand': selectedBrand,
      'quantity': quantity,
      'returnBottles': returnBottles,
      'frequency': frequency,
      'estimatedPrice': _getPrice(),
      'address': _addressController.text,
    });

    if (mounted) {
      AppSnackbar.show(context, "Bottle order submitted!");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Book Bottled Water"),
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
                  const Text("Choose Water Brand", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: brands.map((brand) {
                      return ChoiceChip(
                        label: Text(brand),
                        selected: selectedBrand == brand,
                        onSelected: (_) => setState(() => selectedBrand = brand),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  const Text("Select Quantity (× 19L)", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text('$quantity', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        onPressed: () => setState(() => quantity++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SwitchListTile(
                    title: const Text("Returning empty bottles?"),
                    value: returnBottles,
                    onChanged: (value) => setState(() => returnBottles = value),
                  ),

                  const SizedBox(height: 20),
                  const Text("Delivery Frequency", style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'One-time',
                        groupValue: frequency,
                        onChanged: (value) => setState(() => frequency = value!),
                      ),
                      const Text("One-time"),
                      Radio<String>(
                        value: 'Weekly',
                        groupValue: frequency,
                        onChanged: (value) => setState(() => frequency = value!),
                      ),
                      const Text("Weekly"),
                    ],
                  ),

                  const SizedBox(height: 20),
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
                          "Estimated Price: PKR ${_getPrice()}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      text: "Confirm Booking",
                      onPressed: _submitOrder,
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
