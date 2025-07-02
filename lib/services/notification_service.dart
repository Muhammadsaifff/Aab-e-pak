import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/tracking_models.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request notification permissions
      await _requestPermissions();

      // Initialize the plugin
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        debugPrint('Notification permission denied');
      }
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: Handle navigation based on notification payload
  }

  /// Show order status notification
  Future<void> showOrderStatusNotification({
    required String orderId,
    required OrderStatus status,
    required String message,
    String? driverName,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'order_updates',
        'Order Updates',
        channelDescription: 'Notifications for order status updates',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final title = _getNotificationTitle(status, driverName);
      final body = message;

      await _flutterLocalNotificationsPlugin.show(
        orderId.hashCode,
        title,
        body,
        platformChannelSpecifics,
        payload: 'order_update:$orderId',
      );

      debugPrint('Order status notification sent: $title - $body');
    } catch (e) {
      debugPrint('Error showing order status notification: $e');
    }
  }

  /// Show driver arrival notification
  Future<void> showDriverArrivalNotification({
    required String orderId,
    required String driverName,
    required int estimatedMinutes,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'driver_arrival',
        'Driver Arrival',
        channelDescription: 'Notifications for driver arrival updates',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final title = 'Driver Arriving Soon!';
      final body = '$driverName will arrive in approximately $estimatedMinutes minutes';

      await _flutterLocalNotificationsPlugin.show(
        'arrival_$orderId'.hashCode,
        title,
        body,
        platformChannelSpecifics,
        payload: 'driver_arrival:$orderId',
      );

      debugPrint('Driver arrival notification sent: $title - $body');
    } catch (e) {
      debugPrint('Error showing driver arrival notification: $e');
    }
  }

  /// Show delivery completion notification
  Future<void> showDeliveryCompletionNotification({
    required String orderId,
    required String orderType,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'delivery_completion',
        'Delivery Completion',
        channelDescription: 'Notifications for completed deliveries',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final title = 'Delivery Completed! 🎉';
      final body = 'Your $orderType order has been successfully delivered. Thank you for choosing Aab-e-Pak!';

      await _flutterLocalNotificationsPlugin.show(
        'completion_$orderId'.hashCode,
        title,
        body,
        platformChannelSpecifics,
        payload: 'delivery_completion:$orderId',
      );

      debugPrint('Delivery completion notification sent: $title - $body');
    } catch (e) {
      debugPrint('Error showing delivery completion notification: $e');
    }
  }

  /// Show emergency notification for drivers
  Future<void> showEmergencyNotification({
    required String message,
    required String location,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'emergency',
        'Emergency Alerts',
        channelDescription: 'Emergency notifications',
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        sound: RawResourceAndroidNotificationSound('emergency_sound'),
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final title = '🚨 Emergency Alert';
      final body = '$message\nLocation: $location';

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch,
        title,
        body,
        platformChannelSpecifics,
        payload: 'emergency:$location',
      );

      debugPrint('Emergency notification sent: $title - $body');
    } catch (e) {
      debugPrint('Error showing emergency notification: $e');
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      debugPrint('Notification cancelled: $id');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// Get notification title based on order status
  String _getNotificationTitle(OrderStatus status, String? driverName) {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Order Confirmed! ✅';
      case OrderStatus.assigned:
        return driverName != null ? 'Driver Assigned: $driverName' : 'Driver Assigned';
      case OrderStatus.pickedUp:
        return 'Order Picked Up! 📦';
      case OrderStatus.inTransit:
        return 'Order In Transit! 🚚';
      case OrderStatus.nearDelivery:
        return 'Driver Near Your Location! 📍';
      case OrderStatus.delivered:
        return 'Order Delivered! 🎉';
      case OrderStatus.cancelled:
        return 'Order Cancelled ❌';
      case OrderStatus.failed:
        return 'Delivery Failed ⚠️';
      default:
        return 'Order Update';
    }
  }

  /// Schedule a notification for later (simplified version)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration delay,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // For now, we'll just show the notification immediately
      // In a production app, you'd want to use timezone package for proper scheduling
      await Future.delayed(delay);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'scheduled',
        'Scheduled Notifications',
        channelDescription: 'Scheduled notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      debugPrint('Scheduled notification shown after delay: $delay');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }
}
