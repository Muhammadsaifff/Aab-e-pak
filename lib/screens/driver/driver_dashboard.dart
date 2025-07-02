import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/tracking_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/app_snackbar.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  final TrackingService _trackingService = TrackingService.instance;
  
  bool _isOnline = false;
  bool _isLoading = false;
  String? _driverId;
  String _driverName = 'Driver';
  String _driverPhone = '';
  String _vehicleInfo = '';

  @override
  void initState() {
    super.initState();
    _initializeDriver();
  }

  @override
  void dispose() {
    if (_isOnline && _driverId != null) {
      _trackingService.stopDriverTracking(_driverId!);
    }
    super.dispose();
  }

  Future<void> _initializeDriver() async {
    final user = AuthService.currentUser;
    if (user != null) {
      setState(() {
        _driverId = user.uid;
        _driverName = user.displayName ?? 'Driver';
        _driverPhone = user.phoneNumber ?? '';
      });
    }
  }

  Future<void> _toggleOnlineStatus() async {
    if (_driverId == null) {
      AppSnackbar.show(context, 'Driver ID not found');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isOnline) {
        // Go offline
        await _trackingService.stopDriverTracking(_driverId!);
        setState(() => _isOnline = false);
        if (mounted) AppSnackbar.show(context, 'You are now offline');
      } else {
        // Go online
        bool success = await _trackingService.startDriverTracking(
          _driverId!,
          _driverName,
          _driverPhone,
          vehicleInfo: _vehicleInfo.isNotEmpty ? _vehicleInfo : null,
        );
        
        if (success) {
          setState(() => _isOnline = true);
          if (mounted) AppSnackbar.show(context, 'You are now online and ready for deliveries');
        } else {
          if (mounted) AppSnackbar.show(context, 'Failed to go online. Please check location permissions.');
        }
      }
    } catch (e) {
      if (mounted) AppSnackbar.show(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isOnline ? Icons.online_prediction : Icons.offline_bolt),
            color: _isOnline ? Colors.green : Colors.red,
            onPressed: _toggleOnlineStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: AppLoader())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _isOnline ? Colors.green : Colors.red,
                                child: Icon(
                                  _isOnline ? Icons.check : Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _driverName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _isOnline ? 'Online - Ready for deliveries' : 'Offline',
                                      style: TextStyle(
                                        color: _isOnline ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Vehicle Information',
                              hintText: 'e.g., Blue Toyota Corolla - ABC 123',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => _vehicleInfo = value,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Online/Offline Toggle Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _toggleOnlineStatus,
                      icon: Icon(_isOnline ? Icons.stop : Icons.play_arrow),
                      label: Text(_isOnline ? 'Go Offline' : 'Go Online'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isOnline ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildActionCard(
                          'Assigned Orders',
                          Icons.assignment,
                          Colors.blue,
                          () => _showAssignedOrders(),
                        ),
                        _buildActionCard(
                          'Update Location',
                          Icons.my_location,
                          Colors.orange,
                          () => _updateCurrentLocation(),
                        ),
                        _buildActionCard(
                          'Delivery History',
                          Icons.history,
                          Colors.purple,
                          () => _showDeliveryHistory(),
                        ),
                        _buildActionCard(
                          'Emergency',
                          Icons.emergency,
                          Colors.red,
                          () => _handleEmergency(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignedOrders() {
    // TODO: Implement assigned orders screen
    AppSnackbar.show(context, 'Assigned orders feature coming soon');
  }

  Future<void> _updateCurrentLocation() async {
    if (!_isOnline) {
      AppSnackbar.show(context, 'Please go online first');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) AppSnackbar.show(context, 'Location updated: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}');
    } catch (e) {
      if (mounted) AppSnackbar.show(context, 'Failed to get location: $e');
    }
  }

  void _showDeliveryHistory() {
    // TODO: Implement delivery history screen
    AppSnackbar.show(context, 'Delivery history feature coming soon');
  }

  void _handleEmergency() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency'),
        content: const Text('Are you sure you want to report an emergency?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppSnackbar.show(context, 'Emergency reported. Help is on the way.');
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}
