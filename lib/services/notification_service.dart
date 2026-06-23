import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications;
  late final FirebaseMessaging _messaging;

  NotificationService()
      : _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    _messaging = FirebaseMessaging.instance;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
        settings: const InitializationSettings(android: androidSettings));

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('FCM permission status: ${settings.authorizationStatus}');
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    try {
      await _localNotifications.show(
        id: title.hashCode,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'price_updates_channel',
            'Price Updates',
            channelDescription: 'Notifications for product price updates',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            fullScreenIntent: true,
          ),
        ),
      );
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  Future<void> handleForegroundMessage(RemoteMessage message) async {
    final title = message.data['title'] as String?;
    final body = message.data['body'] as String?;
    if (title != null && body != null) {
      await showLocalNotification(title: title, body: body);
    }
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    final title = message.data['title'] as String?;
    final body = message.data['body'] as String?;
    if (title != null && body != null) {
      // Background handling uses the global plugin instance
      final plugin = FlutterLocalNotificationsPlugin();
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      await plugin.initialize(
          settings: const InitializationSettings(android: androidSettings));
      await plugin.show(
        id: title.hashCode,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'price_updates_channel',
            'Price Updates',
            channelDescription: 'Notifications for product price updates',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            fullScreenIntent: true,
          ),
        ),
      );
    }
  }

  void subscribeToTopic(String topic) {
    _messaging.subscribeToTopic(topic);
  }

  Future<void> saveFcmToken(User user) async {
    final token = await _messaging.getToken();
    if (token == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.email).set({
      'fcmTokens': FieldValue.arrayUnion([token])
    }, SetOptions(merge: true));
  }

  void listenTokenRefresh(User user) {
    _messaging.onTokenRefresh.listen((newToken) async {
      await FirebaseFirestore.instance.collection('users').doc(user.email).set({
        'fcmTokens': FieldValue.arrayUnion([newToken])
      }, SetOptions(merge: true));
    });
  }

  Future<void> removeFcmToken(User user) async {
    final token = await _messaging.getToken();
    if (token == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.email)
        .update({
      'fcmTokens': FieldValue.arrayRemove([token])
    });
  }
}
