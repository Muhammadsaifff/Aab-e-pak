import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/user/login.dart';
import 'screens/user/register.dart';
import 'screens/user/home.dart';
import 'screens/desktop/desktop_home.dart';
import 'screens/user/tanker_booking.dart';
import 'screens/user/bottle_booking.dart';
import 'screens/user/emergency.dart';
import 'screens/user/history.dart';
import 'screens/user/ratings.dart';
import 'screens/user/scheduled_refills.dart';
import 'screens/user/settings.dart'; 
import 'screens/user/about_us.dart';
import 'screens/user/profile.dart';
import 'screens/user/help.dart';
import 'screens/user/boring.dart';
import 'screens/user/tank_cleaning.dart';
import 'screens/user/live_tracking.dart';
import 'screens/driver/driver_dashboard.dart';
import 'screens/driver/order_management.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const AabEPakApp(),
    ),
  );
}

class AabEPakApp extends StatelessWidget {
  const AabEPakApp({super.key});

  bool _isDesktop() {
    return defaultTargetPlatform == TargetPlatform.windows ||
           defaultTargetPlatform == TargetPlatform.macOS ||
           defaultTargetPlatform == TargetPlatform.linux;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Aab-e-Pak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.currentTheme,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => _isDesktop() ? const DesktopHomeScreen() : const HomeScreen(),
        '/tanker': (context) => const TankerBookingScreen(),
        '/bottle': (context) => const BottleBookingScreen(),
        '/emergency': (context) => const EmergencyScreen(),
        '/history': (context) => const OrderHistoryScreen(),
        '/ratings': (context) => const RatingsScreen(),
        '/refills': (context) => const ScheduledRefillsScreen(),
        '/settings': (context) => const SettingsScreen(), 
        '/profile': (context) => const ProfileScreen(),
        '/about_us': (context) => const AboutUsScreen(),
        '/boring': (context) => const BoringServiceScreen(),
        '/tank_cleaning': (context) => const TankCleaningScreen(),
        '/help_support': (context) => const HelpScreen(),
        '/live_tracking': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return LiveTrackingScreen(orderId: args['orderId']);
        },
        '/driver_dashboard': (context) => const DriverDashboardScreen(),
        '/order_management': (context) => const OrderManagementScreen(),
      },
    );
  }
}
