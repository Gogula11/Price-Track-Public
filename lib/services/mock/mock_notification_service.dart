import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:firebase_messaging/firebase_messaging.dart' show RemoteMessage;
import 'package:TrueTrack/services/notification_service.dart';

class MockNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    print('[Mock] Notification: $title - $body');
  }

  @override
  Future<void> handleForegroundMessage(RemoteMessage message) async {}

  @override
  Future<void> saveFcmToken(User user) async {}

  @override
  void listenTokenRefresh(User user) {}

  @override
  Future<void> removeFcmToken(User user) async {}

  @override
  void subscribeToTopic(String topic) {
    print('[Mock] Subscribed to topic: $topic');
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('[Mock] Background message: ${message.data}');
  }
}
