import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Help & Support")),
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
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                const Text(
                  'How to Use Aab-e-Pak App',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  '1. Select a Service:\n'
                  '   • Water Tanker Delivery\n'
                  '   • Bottled Water Delivery\n'
                  '   • Tank Cleaning\n'
                  '   • Boring / Water Drilling\n\n'
                  '2. Enter your address and choose delivery type (Immediate or Scheduled).\n\n'
                  '3. Confirm your booking — prices are calculated based on tank size or boring length.\n\n'
                  '4. Track Orders: Go to "My Orders" to check ongoing and previous orders.\n\n'
                  '5. Rate the Service: Provide feedback after completion.\n\n'
                  '6. Update Profile: You can change your name and manage your preferences under Profile.\n',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 30),
                Text(
                  'Need more help? Contact us at support@aabepak.pk',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
