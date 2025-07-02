import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("About Us")),
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'About Aab-e-Pak',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aab-e-Pak is your all-in-one water management app. '
                    'We aim to solve every household and commercial water-related issue through technology. '
                    'From water delivery to maintenance services, we ensure accessibility, hygiene, and reliability.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'What We Offer:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Emergency Water Tanker Services\n'
                    '• Scheduled Tanker Deliveries\n'
                    '• Branded Bottled Water Bookings\n'
                    '• Water Tank Cleaning Services\n'
                    '• Water Boring & Installation Services\n'
                    '• Transparent Pricing & Order History\n'
                    '• Smart Address-Based Delivery',
                    style: TextStyle(fontSize: 16, height: 1.6),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Our Vision',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'To become Pakistan\'s go-to digital platform for all water-related needs — '
                    'ensuring clean water, safe storage, and easy access for everyone.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Developer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Muhammad Saif Shakil\nMaham Shahzad\n',
                    style: TextStyle(fontSize: 16, height: 1.5),
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
