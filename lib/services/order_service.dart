import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import '../models/tracking_models.dart';
import 'tracking_service.dart';

class OrderService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final _trackingService = TrackingService.instance;

  static Future<String> submitOrder(Map<String, dynamic> orderData) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    final orderRef = _firestore.collection('orders').doc();
    final userOrderRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .doc(orderRef.id);

    final data = {
      ...orderData,
      'userId': user.uid,
      'status': 'Confirmed',
      'timestamp': Timestamp.now(),
      'orderId': orderRef.id,
    };

    await orderRef.set(data);
    await userOrderRef.set(data);

    // Create tracking for the order if address is provided and it's a trackable service
    if (orderData['address'] != null && isTrackableService(orderData['type'])) {
      await _createOrderTracking(orderRef.id, orderData);
    }

    return orderRef.id;
  }

  /// Check if a service type is trackable
  static bool isTrackableService(String? serviceType) {
    if (serviceType == null) return false;

    // Only Tanker and Bottled Water services are trackable
    // Boring and Tank Cleaning are not trackable as they are on-site services
    final trackableServices = ['Tanker', 'Bottled Water'];
    return trackableServices.contains(serviceType);
  }

  static Future<void> _createOrderTracking(String orderId, Map<String, dynamic> orderData) async {
    try {
      // Get coordinates from address
      final coordinates = await _getCoordinatesFromAddress(orderData['address']);

      // Create delivery location
      final deliveryLocation = DeliveryLocation(
        latitude: coordinates['latitude'] ?? 33.6844, // Default to Islamabad
        longitude: coordinates['longitude'] ?? 73.0479,
        address: orderData['address'],
        contactPerson: orderData['contactPerson'],
        contactPhone: orderData['contactPhone'],
      );

      // Create pickup location (default to company location)
      final pickupLocation = DeliveryLocation(
        latitude: 33.6844, // Company location - Islamabad
        longitude: 73.0479,
        address: 'Aab-e-Pak Water Services, Islamabad',
      );

      await _trackingService.createOrderTracking(
        orderId,
        pickupLocation,
        deliveryLocation,
        specialInstructions: orderData['specialInstructions'],
      );
    } catch (e) {
      debugPrint('Error creating order tracking: $e');
      // Don't throw error as order is already created
    }
  }

  static Future<Map<String, double?>> _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return {
          'latitude': locations.first.latitude,
          'longitude': locations.first.longitude,
        };
      }
    } catch (e) {
      debugPrint('Error getting coordinates from address: $e');
    }
    return {'latitude': null, 'longitude': null};
  }

  static Stream<QuerySnapshot> getUserOrders() {
    final user = _auth.currentUser;
    return _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({'status': newStatus});

    // Also update tracking status if it exists
    try {
      OrderStatus trackingStatus;
      switch (newStatus.toLowerCase()) {
        case 'confirmed':
          trackingStatus = OrderStatus.confirmed;
          break;
        case 'assigned':
          trackingStatus = OrderStatus.assigned;
          break;
        case 'picked up':
          trackingStatus = OrderStatus.pickedUp;
          break;
        case 'in transit':
          trackingStatus = OrderStatus.inTransit;
          break;
        case 'delivered':
          trackingStatus = OrderStatus.delivered;
          break;
        case 'cancelled':
          trackingStatus = OrderStatus.cancelled;
          break;
        default:
          trackingStatus = OrderStatus.pending;
      }

      await _trackingService.updateOrderStatus(
        orderId,
        trackingStatus,
        'Order status updated to $newStatus',
      );
    } catch (e) {
      debugPrint('Error updating tracking status: $e');
    }
  }

  /// Get order with tracking information
  static Future<Map<String, dynamic>?> getOrderWithTracking(String orderId) async {
    try {
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) return null;

      final orderData = orderDoc.data()!;

      // Try to get tracking information
      final trackingDoc = await _firestore.collection('order_tracking').doc(orderId).get();
      if (trackingDoc.exists) {
        orderData['tracking'] = trackingDoc.data();
      }

      return orderData;
    } catch (e) {
      debugPrint('Error getting order with tracking: $e');
      return null;
    }
  }

  /// Check if order has tracking enabled
  static Future<bool> hasTracking(String orderId) async {
    try {
      // First check if the order exists and get its type
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) return false;

      final orderData = orderDoc.data()!;
      final serviceType = orderData['type'];

      // Check if this service type is trackable
      if (!isTrackableService(serviceType)) return false;

      // Then check if tracking document exists
      final trackingDoc = await _firestore.collection('order_tracking').doc(orderId).get();
      return trackingDoc.exists;
    } catch (e) {
      debugPrint('Error checking tracking: $e');
      return false;
    }
  }

  /// Get orders with tracking information
  static Stream<QuerySnapshot> getUserOrdersWithTracking() {
    final user = _auth.currentUser;
    return _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
