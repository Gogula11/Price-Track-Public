import 'package:flutter/foundation.dart';
import 'package:TrueTrack/services/amazon_service.dart';
import 'package:TrueTrack/services/flipkart_service.dart';
import 'package:TrueTrack/services/ai_service.dart';
import 'package:TrueTrack/services/firestore_service.dart';
import 'package:TrueTrack/services/notification_service.dart';
import 'package:TrueTrack/services/mock/mock_amazon_service.dart';
import 'package:TrueTrack/services/mock/mock_flipkart_service.dart';
import 'package:TrueTrack/services/mock/mock_ai_service.dart';
import 'package:TrueTrack/services/mock/mock_firestore_service.dart';
import 'package:TrueTrack/services/mock/mock_notification_service.dart';

class ServiceRegistry extends ChangeNotifier {
  final AmazonService? _realAmazon;
  final FlipkartService? _realFlipkart;
  final AiService? _realAi;
  final FirestoreService? _realFirestore;
  final NotificationService? _realNotification;

  final MockAmazonService _mockAmazon;
  final MockFlipkartService _mockFlipkart;
  final MockAiService _mockAi;
  final MockFirestoreService _mockFirestore;
  final MockNotificationService _mockNotification;

  bool _mockMode;

  ServiceRegistry({
    AmazonService? amazonService,
    FlipkartService? flipkartService,
    AiService? aiService,
    FirestoreService? firestoreService,
    NotificationService? notificationService,
    bool mockMode = false,
  })  : _realAmazon = amazonService,
        _realFlipkart = flipkartService,
        _realAi = aiService,
        _realFirestore = firestoreService,
        _realNotification = notificationService,
        _mockAmazon = MockAmazonService(),
        _mockFlipkart = MockFlipkartService(),
        _mockAi = MockAiService(),
        _mockFirestore = MockFirestoreService(),
        _mockNotification = MockNotificationService(),
        _mockMode = mockMode;

  bool get mockMode => _mockMode;

  void setMockMode(bool value) {
    if (_mockMode != value) {
      _mockMode = value;
      notifyListeners();
    }
  }

  AmazonService get amazon =>
      _mockMode || _realAmazon == null ? _mockAmazon : _realAmazon;
  FlipkartService get flipkart =>
      _mockMode || _realFlipkart == null ? _mockFlipkart : _realFlipkart;
  AiService get ai => _mockMode || _realAi == null ? _mockAi : _realAi;
  FirestoreService get firestore =>
      _mockMode || _realFirestore == null ? _mockFirestore : _realFirestore;
  NotificationService get notification => _mockMode || _realNotification == null
      ? _mockNotification
      : _realNotification;
}
