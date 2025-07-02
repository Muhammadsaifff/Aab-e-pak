import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/tracking_models.dart';
import 'location_service.dart';
import 'notification_service.dart';

class TrackingService {
  static TrackingService? _instance;
  static TrackingService get instance => _instance ??= TrackingService._();
  TrackingService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocationService _locationService = LocationService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  StreamSubscription<Position>? _locationSubscription;
  Timer? _locationUpdateTimer;

  /// Initialize tracking service
  Future<void> initialize() async {
    await _locationService.initialize();
    await _notificationService.initialize();
  }

  /// Start tracking for a driver
  Future<bool> startDriverTracking(String driverId, String driverName, String driverPhone, {String? vehicleInfo}) async {
    try {
      bool locationStarted = await _locationService.startTracking();
      
      if (!locationStarted) {
        debugPrint('Failed to start location tracking');
        return false;
      }

      // Listen to location updates and update driver location in real-time
      _locationSubscription = _locationService.locationStream.listen((position) {
        _updateDriverLocation(driverId, driverName, driverPhone, position, vehicleInfo);
      });

      // Also update location every 30 seconds even if position hasn't changed much
      _locationUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
        Position? position = await _locationService.getCurrentPosition();
        if (position != null) {
          _updateDriverLocation(driverId, driverName, driverPhone, position, vehicleInfo);
        }
      });

      debugPrint('Driver tracking started for: $driverId');
      return true;
    } catch (e) {
      debugPrint('Error starting driver tracking: $e');
      return false;
    }
  }

  /// Stop driver tracking
  Future<void> stopDriverTracking(String driverId) async {
    await _locationSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    await _locationService.stopTracking();
    
    // Mark driver as offline
    await _realtimeDb.ref('drivers/$driverId').update({
      'isOnline': false,
      'lastSeen': ServerValue.timestamp,
    });
    
    debugPrint('Driver tracking stopped for: $driverId');
  }

  /// Update driver location in real-time database
  Future<void> _updateDriverLocation(String driverId, String driverName, String driverPhone, Position position, String? vehicleInfo) async {
    try {
      final driverLocation = DriverLocation(
        driverId: driverId,
        driverName: driverName,
        driverPhone: driverPhone,
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
        timestamp: DateTime.now(),
        isOnline: true,
        vehicleInfo: vehicleInfo,
      );

      await _realtimeDb.ref('drivers/$driverId').set(driverLocation.toMap());
      debugPrint('Driver location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('Error updating driver location: $e');
    }
  }

  /// Create order tracking
  Future<void> createOrderTracking(String orderId, DeliveryLocation pickupLocation, DeliveryLocation deliveryLocation, {String? specialInstructions}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final orderTracking = OrderTracking(
        orderId: orderId,
        customerId: user.uid,
        status: OrderStatus.pending,
        updates: [
          TrackingUpdate(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            status: OrderStatus.pending,
            message: 'Order created and pending confirmation',
            timestamp: DateTime.now(),
          ),
        ],
        pickupLocation: pickupLocation,
        deliveryLocation: deliveryLocation,
        specialInstructions: specialInstructions,
      );

      await _firestore.collection('order_tracking').doc(orderId).set(orderTracking.toMap());
      debugPrint('Order tracking created for: $orderId');
    } catch (e) {
      debugPrint('Error creating order tracking: $e');
      rethrow;
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status, String message, {String? driverId, Position? location}) async {
    try {
      final update = TrackingUpdate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        status: status,
        message: message,
        timestamp: DateTime.now(),
        latitude: location?.latitude,
        longitude: location?.longitude,
        driverId: driverId,
      );

      final updateData = {
        'status': status.name,
        'updates': FieldValue.arrayUnion([update.toMap()]),
      };

      if (driverId != null) {
        updateData['driverId'] = driverId;
      }

      if (status == OrderStatus.delivered) {
        updateData['actualArrival'] = Timestamp.now();
      }

      await _firestore.collection('order_tracking').doc(orderId).update(updateData);
      debugPrint('Order status updated: $orderId -> ${status.name}');

      // Send notification to customer
      String? driverName;
      if (driverId != null) {
        final driverSnapshot = await _realtimeDb.ref('drivers/$driverId').get();
        if (driverSnapshot.exists) {
          final driverData = Map<String, dynamic>.from(driverSnapshot.value as Map);
          driverName = driverData['driverName'];
        }
      }

      await _notificationService.showOrderStatusNotification(
        orderId: orderId,
        status: status,
        message: message,
        driverName: driverName,
      );

      // Special handling for delivery completion
      if (status == OrderStatus.delivered) {
        // Get order type for completion notification
        final orderDoc = await _firestore.collection('orders').doc(orderId).get();
        if (orderDoc.exists) {
          final orderData = orderDoc.data()!;
          await _notificationService.showDeliveryCompletionNotification(
            orderId: orderId,
            orderType: orderData['type'] ?? 'order',
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  /// Assign driver to order
  Future<void> assignDriverToOrder(String orderId, String driverId) async {
    try {
      await updateOrderStatus(
        orderId, 
        OrderStatus.assigned, 
        'Driver has been assigned to your order',
        driverId: driverId,
      );
      
      // Set estimated arrival time (this could be calculated based on distance and traffic)
      final estimatedArrival = DateTime.now().add(const Duration(minutes: 30));
      await _firestore.collection('order_tracking').doc(orderId).update({
        'estimatedArrival': Timestamp.fromDate(estimatedArrival),
      });
      
      debugPrint('Driver assigned to order: $orderId -> $driverId');
    } catch (e) {
      debugPrint('Error assigning driver to order: $e');
      rethrow;
    }
  }

  /// Get order tracking stream
  Stream<OrderTracking?> getOrderTrackingStream(String orderId) {
    return _firestore.collection('order_tracking').doc(orderId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return OrderTracking.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  /// Get driver location stream
  Stream<DriverLocation?> getDriverLocationStream(String driverId) {
    return _realtimeDb.ref('drivers/$driverId').onValue.map((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        return DriverLocation.fromMap(data);
      }
      return null;
    });
  }

  /// Get all active drivers
  Stream<List<DriverLocation>> getActiveDriversStream() {
    return _realtimeDb.ref('drivers').onValue.map((event) {
      final List<DriverLocation> drivers = [];
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          final driverData = Map<String, dynamic>.from(value);
          if (driverData['isOnline'] == true) {
            drivers.add(DriverLocation.fromMap(driverData));
          }
        });
      }
      return drivers;
    });
  }

  /// Calculate estimated arrival time
  Future<DateTime?> calculateEstimatedArrival(String orderId) async {
    try {
      final orderDoc = await _firestore.collection('order_tracking').doc(orderId).get();
      if (!orderDoc.exists) return null;

      final orderTracking = OrderTracking.fromMap(orderDoc.data()!);
      if (orderTracking.driverId == null) return null;

      // Get driver's current location
      final driverSnapshot = await _realtimeDb.ref('drivers/${orderTracking.driverId}').get();
      if (!driverSnapshot.exists) return null;

      final driverData = Map<String, dynamic>.from(driverSnapshot.value as Map);
      final driverLocation = DriverLocation.fromMap(driverData);

      // Calculate distance to delivery location
      final distance = _locationService.calculateDistance(
        driverLocation.latitude,
        driverLocation.longitude,
        orderTracking.deliveryLocation.latitude,
        orderTracking.deliveryLocation.longitude,
      );

      // Estimate time based on average speed (assuming 30 km/h in city)
      final estimatedMinutes = (distance / 1000) * 2; // 2 minutes per km
      final estimatedArrival = DateTime.now().add(Duration(minutes: estimatedMinutes.round()));

      // Update the order with estimated arrival
      await _firestore.collection('order_tracking').doc(orderId).update({
        'estimatedArrival': Timestamp.fromDate(estimatedArrival),
      });

      return estimatedArrival;
    } catch (e) {
      debugPrint('Error calculating estimated arrival: $e');
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _locationSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    _locationService.dispose();
  }
}
