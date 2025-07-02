import 'package:flutter/material.dart';
import '../../widgets/build_service_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/settings');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aab-e-Pak',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 2,
      ),
      backgroundColor: Colors.transparent,
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListView(
              children: [
                Center(
                  child: Image.asset(
                    'assets/tanker.png',
                    height: 120, // Reduced from 160 to 120
                  ),
                ),
                const SizedBox(height: 20), // Reduced from 30 to 20

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 75, // Reduced from 90 to 75
                        child: buildServiceCard(
                          context,
                          title: 'Tanker\nDelivery',
                          icon: Icons.local_shipping,
                          backgroundColor: Colors.blue.shade700,
                          onTap: () => Navigator.pushNamed(context, '/tanker'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 75, // Reduced from 90 to 75
                        child: buildServiceCard(
                          context,
                          title: 'Bottled\nWater',
                          icon: Icons.local_drink,
                          backgroundColor: Colors.lightBlue.shade400,
                          onTap: () => Navigator.pushNamed(context, '/bottle'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Reduced from 16 to 12

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 75, // Reduced from 90 to 75
                        child: buildServiceCard(
                          context,
                          title: 'Boring\nService',
                          icon: Icons.construction,
                          backgroundColor: Colors.deepPurple.shade400,
                          onTap: () => Navigator.pushNamed(context, '/boring'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 75, // Reduced from 90 to 75
                        child: buildServiceCard(
                          context,
                          title: 'Tank\nCleaning',
                          icon: Icons.cleaning_services,
                          backgroundColor: Colors.green.shade600,
                          onTap: () => Navigator.pushNamed(context, '/tank_cleaning'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Reduced from 16 to 12

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 75, // Reduced from 90 to 75
                        child: buildServiceCard(
                          context,
                          title: 'Scheduled\nRefills',
                          icon: Icons.schedule,
                          backgroundColor: Colors.teal.shade600,
                          onTap: () => Navigator.pushNamed(context, '/refills'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 75, // Reduced from 90 to 75
                        child: buildServiceCard(
                          context,
                          title: 'My\nOrders',
                          icon: Icons.list_alt,
                          backgroundColor: Colors.cyan.shade600,
                          onTap: () => Navigator.pushNamed(context, '/history'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Reduced from 16 to 12

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 75, // Reduced from 90 to 75
                        child: buildServiceCard(
                          context,
                          title: 'About Us',
                          icon: Icons.info_outline,
                          backgroundColor: Colors.indigo.shade400,
                          onTap: () => Navigator.pushNamed(context, '/about_us'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 75, // Reduced from 90 to 75
                        child: buildServiceCard(
                          context,
                          title: 'Rate\nService',
                          icon: Icons.star_rate,
                          backgroundColor: Colors.lightBlue.shade800,
                          onTap: () => Navigator.pushNamed(context, '/ratings'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Added bottom padding to prevent overlap with urgent button
              ],
            ),
          ),

          Positioned(
            bottom: 70, // Moved higher to avoid bottom nav overlap
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                elevation: 0, // Remove default elevation since we have custom shadow
                icon: const Icon(Icons.warning, size: 20), // Smaller icon
                label: const Text(
                  "Urgent",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12, // Smaller text
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/emergency');
                },
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
