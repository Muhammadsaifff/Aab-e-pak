import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/tracking_models.dart';
import '../../services/tracking_service.dart';
import '../../services/order_service.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/app_snackbar.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String orderId;
  
  const LiveTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final TrackingService _trackingService = TrackingService.instance;

  OrderTracking? _orderTracking;
  DriverLocation? _driverLocation;

  StreamSubscription<OrderTracking?>? _orderSubscription;
  StreamSubscription<DriverLocation?>? _driverSubscription;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    _driverSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    try {
      // First check if this order has tracking
      final hasTracking = await OrderService.hasTracking(widget.orderId);

      if (!hasTracking) {
        if (mounted) {
          setState(() {
            _error = 'This order does not support live tracking. Only Tanker and Bottled Water deliveries can be tracked.';
            _isLoading = false;
          });
        }
        return;
      }

      // Listen to order tracking updates
      _orderSubscription = _trackingService.getOrderTrackingStream(widget.orderId).listen(
        (orderTracking) {
          if (mounted) {
            setState(() {
              _orderTracking = orderTracking;
              _isLoading = false;
            });

            if (orderTracking?.driverId != null) {
              _startDriverTracking(orderTracking!.driverId!);
            }

            // Add delay before updating markers to ensure map is ready
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _updateMapMarkers();
              }
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _error = 'Failed to load tracking information: ${error.toString()}';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error initializing tracking: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _startDriverTracking(String driverId) {
    _driverSubscription?.cancel();
    _driverSubscription = _trackingService.getDriverLocationStream(driverId).listen(
      (driverLocation) {
        if (mounted) {
          setState(() {
            _driverLocation = driverLocation;
          });
          _updateMapMarkers();
        }
      },
    );
  }

  void _updateMapMarkers() {
    if (!mounted) return;

    // Since we're using a custom map display instead of Google Maps,
    // we just need to trigger a UI update
    setState(() {
      // UI will be updated with the latest _orderTracking and _driverLocation data
    });
  }



  void _callDriver() {
    if (_driverLocation?.driverPhone != null) {
      // Implement phone call functionality
      AppSnackbar.show(context, 'Calling ${_driverLocation!.driverName}...');
    }
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required MaterialColor color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleMap() {
    // Custom tracking display with app theme
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Map placeholder with theme colors
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFe0f7fa), Color(0xFF80deea)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 48,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Live Tracking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_orderTracking != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Delivery Address',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _orderTracking!.deliveryLocation.address,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (_driverLocation != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_shipping,
                            size: 18,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Driver: ${_driverLocation!.driverName}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            size: 18,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Waiting for driver',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Location details with theme styling
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 12),
                if (_driverLocation != null) ...[
                  _buildLocationRow(
                    icon: Icons.local_shipping,
                    title: 'Driver Location',
                    subtitle: 'Lat: ${_driverLocation!.latitude.toStringAsFixed(4)}, Lng: ${_driverLocation!.longitude.toStringAsFixed(4)}',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                ],
                if (_orderTracking != null)
                  _buildLocationRow(
                    icon: Icons.location_on,
                    title: 'Delivery Location',
                    subtitle: 'Lat: ${_orderTracking!.deliveryLocation.latitude.toStringAsFixed(4)}, Lng: ${_orderTracking!.deliveryLocation.longitude.toStringAsFixed(4)}',
                    color: Colors.green,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Track Your Order'),
        centerTitle: true,
        actions: [
          if (_driverLocation != null)
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: _callDriver,
              tooltip: 'Call Driver',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFe0f7fa), Color(0xFF80deea)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: _isLoading
                ? const Center(child: AppLoader())
                : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _error!.contains('does not support live tracking')
                              ? Icons.info_outline
                              : Icons.error_outline,
                          size: 64,
                          color: _error!.contains('does not support live tracking')
                              ? Colors.orange
                              : Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!.contains('does not support live tracking')
                              ? 'Tracking Not Available'
                              : 'Error Loading Tracking',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        if (!_error!.contains('does not support live tracking'))
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _error = null;
                              });
                              _initializeTracking();
                            },
                            child: const Text('Retry'),
                          ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                )
              : _orderTracking == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Loading tracking information...',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Order status card with theme styling
                        Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getStatusIcon(_orderTracking?.status),
                                color: _getStatusColor(_orderTracking?.status),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _orderTracking?.status.displayName ?? 'Unknown Status',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _orderTracking?.status.description ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_orderTracking?.estimatedArrival != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'ETA: ${_formatTime(_orderTracking!.estimatedArrival!)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (_driverLocation != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Driver: ${_driverLocation!.driverName}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Map with theme styling
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _buildGoogleMap(),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus? status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return Icons.hourglass_empty;
      case OrderStatus.assigned:
        return Icons.person_add;
      case OrderStatus.pickedUp:
        return Icons.local_shipping;
      case OrderStatus.inTransit:
        return Icons.directions_car;
      case OrderStatus.nearDelivery:
        return Icons.location_on;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(OrderStatus? status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return Colors.orange;
      case OrderStatus.assigned:
      case OrderStatus.pickedUp:
      case OrderStatus.inTransit:
        return Colors.blue;
      case OrderStatus.nearDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.isNegative) {
      return 'Overdue';
    }
    
    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }
}
