import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/tracking_models.dart';
import '../../services/tracking_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/app_snackbar.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final TrackingService _trackingService = TrackingService.instance;
  String? _driverId;

  @override
  void initState() {
    super.initState();
    _driverId = AuthService.currentUser?.uid;
  }

  Future<void> _updateOrderStatus(String orderId, OrderStatus status, String message) async {
    try {
      Position? position = await Geolocator.getCurrentPosition();
      await _trackingService.updateOrderStatus(
        orderId,
        status,
        message,
        driverId: _driverId,
        location: position,
      );
      if (mounted) AppSnackbar.show(context, 'Order status updated successfully');
    } catch (e) {
      if (mounted) AppSnackbar.show(context, 'Failed to update order status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Orders'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('order_tracking')
            .where('driverId', isEqualTo: _driverId)
            .where('status', whereIn: ['assigned', 'pickedUp', 'inTransit'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppLoader());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No assigned orders',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final orderTracking = OrderTracking.fromMap(doc.data() as Map<String, dynamic>);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(orderTracking.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              orderTracking.status.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Order #${orderTracking.orderId.substring(0, 8)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Delivery Address
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              orderTracking.deliveryLocation.address,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      
                      if (orderTracking.specialInstructions != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.note, size: 20, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                orderTracking.specialInstructions!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Action Buttons
                      Row(
                        children: [
                          if (orderTracking.status == OrderStatus.assigned) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateOrderStatus(
                                  orderTracking.orderId,
                                  OrderStatus.pickedUp,
                                  'Order has been picked up and is ready for delivery',
                                ),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Pick Up'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ] else if (orderTracking.status == OrderStatus.pickedUp) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateOrderStatus(
                                  orderTracking.orderId,
                                  OrderStatus.inTransit,
                                  'Order is now in transit to delivery location',
                                ),
                                icon: const Icon(Icons.local_shipping),
                                label: const Text('Start Delivery'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ] else if (orderTracking.status == OrderStatus.inTransit) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateOrderStatus(
                                  orderTracking.orderId,
                                  OrderStatus.nearDelivery,
                                  'Driver is near the delivery location',
                                ),
                                icon: const Icon(Icons.near_me),
                                label: const Text('Near Location'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateOrderStatus(
                                  orderTracking.orderId,
                                  OrderStatus.delivered,
                                  'Order has been successfully delivered',
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text('Delivered'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Navigation and Call buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _openNavigation(orderTracking.deliveryLocation),
                              icon: const Icon(Icons.navigation),
                              label: const Text('Navigate'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (orderTracking.deliveryLocation.contactPhone != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _callCustomer(orderTracking.deliveryLocation.contactPhone!),
                                icon: const Icon(Icons.phone),
                                label: const Text('Call'),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.assigned:
        return Colors.blue;
      case OrderStatus.pickedUp:
        return Colors.orange;
      case OrderStatus.inTransit:
        return Colors.purple;
      case OrderStatus.nearDelivery:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _openNavigation(DeliveryLocation location) {
    // TODO: Implement navigation to Google Maps or other navigation app
    AppSnackbar.show(context, 'Opening navigation to ${location.address}');
  }

  void _callCustomer(String phoneNumber) {
    // TODO: Implement phone call functionality
    AppSnackbar.show(context, 'Calling $phoneNumber');
  }
}
