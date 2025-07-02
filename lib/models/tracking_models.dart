import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents the current location and status of a driver
class DriverLocation {
  final String driverId;
  final String driverName;
  final String driverPhone;
  final double latitude;
  final double longitude;
  final double? heading; // Direction the driver is facing
  final DateTime timestamp;
  final bool isOnline;
  final String? vehicleInfo;

  DriverLocation({
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.latitude,
    required this.longitude,
    this.heading,
    required this.timestamp,
    required this.isOnline,
    this.vehicleInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'timestamp': Timestamp.fromDate(timestamp),
      'isOnline': isOnline,
      'vehicleInfo': vehicleInfo,
    };
  }

  factory DriverLocation.fromMap(Map<String, dynamic> map) {
    return DriverLocation(
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? '',
      driverPhone: map['driverPhone'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      heading: map['heading']?.toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isOnline: map['isOnline'] ?? false,
      vehicleInfo: map['vehicleInfo'],
    );
  }
}

/// Represents tracking information for an order
class OrderTracking {
  final String orderId;
  final String customerId;
  final String? driverId;
  final OrderStatus status;
  final List<TrackingUpdate> updates;
  final DeliveryLocation pickupLocation;
  final DeliveryLocation deliveryLocation;
  final DateTime? estimatedArrival;
  final DateTime? actualArrival;
  final double? totalDistance;
  final String? specialInstructions;

  OrderTracking({
    required this.orderId,
    required this.customerId,
    this.driverId,
    required this.status,
    required this.updates,
    required this.pickupLocation,
    required this.deliveryLocation,
    this.estimatedArrival,
    this.actualArrival,
    this.totalDistance,
    this.specialInstructions,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'driverId': driverId,
      'status': status.name,
      'updates': updates.map((update) => update.toMap()).toList(),
      'pickupLocation': pickupLocation.toMap(),
      'deliveryLocation': deliveryLocation.toMap(),
      'estimatedArrival': estimatedArrival != null ? Timestamp.fromDate(estimatedArrival!) : null,
      'actualArrival': actualArrival != null ? Timestamp.fromDate(actualArrival!) : null,
      'totalDistance': totalDistance,
      'specialInstructions': specialInstructions,
    };
  }

  factory OrderTracking.fromMap(Map<String, dynamic> map) {
    return OrderTracking(
      orderId: map['orderId'] ?? '',
      customerId: map['customerId'] ?? '',
      driverId: map['driverId'],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      updates: (map['updates'] as List<dynamic>?)
          ?.map((update) => TrackingUpdate.fromMap(update))
          .toList() ?? [],
      pickupLocation: DeliveryLocation.fromMap(map['pickupLocation']),
      deliveryLocation: DeliveryLocation.fromMap(map['deliveryLocation']),
      estimatedArrival: map['estimatedArrival'] != null 
          ? (map['estimatedArrival'] as Timestamp).toDate() 
          : null,
      actualArrival: map['actualArrival'] != null 
          ? (map['actualArrival'] as Timestamp).toDate() 
          : null,
      totalDistance: map['totalDistance']?.toDouble(),
      specialInstructions: map['specialInstructions'],
    );
  }
}

/// Represents a tracking update/event
class TrackingUpdate {
  final String id;
  final OrderStatus status;
  final String message;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String? driverId;
  final Map<String, dynamic>? additionalData;

  TrackingUpdate({
    required this.id,
    required this.status,
    required this.message,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.driverId,
    this.additionalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status.name,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'latitude': latitude,
      'longitude': longitude,
      'driverId': driverId,
      'additionalData': additionalData,
    };
  }

  factory TrackingUpdate.fromMap(Map<String, dynamic> map) {
    return TrackingUpdate(
      id: map['id'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      driverId: map['driverId'],
      additionalData: map['additionalData'],
    );
  }
}

/// Represents a delivery location
class DeliveryLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String? landmark;
  final String? contactPerson;
  final String? contactPhone;

  DeliveryLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.landmark,
    this.contactPerson,
    this.contactPhone,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'landmark': landmark,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
    };
  }

  factory DeliveryLocation.fromMap(Map<String, dynamic> map) {
    return DeliveryLocation(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      address: map['address'] ?? '',
      landmark: map['landmark'],
      contactPerson: map['contactPerson'],
      contactPhone: map['contactPhone'],
    );
  }
}

/// Order status enumeration
enum OrderStatus {
  pending,
  confirmed,
  assigned,
  pickedUp,
  inTransit,
  nearDelivery,
  delivered,
  cancelled,
  failed,
}

/// Extension to get user-friendly status messages
extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Order Pending';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.assigned:
        return 'Driver Assigned';
      case OrderStatus.pickedUp:
        return 'Order Picked Up';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.nearDelivery:
        return 'Near Delivery Location';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.failed:
        return 'Delivery Failed';
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.pending:
        return 'Your order is being processed';
      case OrderStatus.confirmed:
        return 'Your order has been confirmed';
      case OrderStatus.assigned:
        return 'A driver has been assigned to your order';
      case OrderStatus.pickedUp:
        return 'Your order has been picked up';
      case OrderStatus.inTransit:
        return 'Your order is on the way';
      case OrderStatus.nearDelivery:
        return 'Driver is near your location';
      case OrderStatus.delivered:
        return 'Your order has been delivered';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled';
      case OrderStatus.failed:
        return 'Delivery attempt failed';
    }
  }
}
