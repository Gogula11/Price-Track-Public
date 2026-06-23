import 'dart:async';
import 'package:TrueTrack/services/firestore_service.dart';
import 'package:TrueTrack/services/mock/mock_data.dart';

class MockFirestoreService implements FirestoreService {
  final Map<String, Map<String, dynamic>> _trackedProducts = {};
  final List<String> _searchHistory = ['iPhone 15', 'laptop', 'headphones'];
  final Map<String, List<Map<String, dynamic>>> _priceEntries = {};

  @override
  String? userEmail = 'demo@truetrack.app';

  MockFirestoreService() {
    _seedTrackedProducts();
  }

  void _seedTrackedProducts() {
    final products = [
      mockAmazonProducts[0],
      mockAmazonProducts[1],
      mockAmazonProducts[2],
    ];
    for (final p in products) {
      _trackedProducts[p.productId] = {
        'id': p.productId,
        'productName': p.name,
        'productImage': p.imageUrl,
        'price': p.price,
        'setTrackingPrice': (int.parse(p.price) - 20000).toString(),
        'asinOrPid': p.productId,
        'productUrl': 'https://example.com/${p.productId}',
        'source': p.source,
        'timestamp': DateTime.now().toIso8601String(),
      };
      _priceEntries[p.productId] = mockPriceEntries;
    }
  }

  @override
  Future<void> trackProduct({
    required String productId,
    required String productName,
    required String productImage,
    required String price,
    required String targetPrice,
    required String productUrl,
    required String source,
  }) async {
    _trackedProducts[productId] = {
      'id': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'setTrackingPrice': targetPrice,
      'asinOrPid': productId,
      'productUrl': productUrl,
      'source': source,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<void> untrackProduct(String productId) async {
    _trackedProducts.remove(productId);
  }

  @override
  Future<bool> isProductTracked(String productId) async {
    return _trackedProducts.containsKey(productId);
  }

  @override
  Stream<List<Map<String, dynamic>>> getTrackedProductsStream() {
    final list = _trackedProducts.entries
        .map((e) => Map<String, dynamic>.from(e.value))
        .toList();
    return Stream.value(list);
  }

  @override
  Future<List<String>> getSearchHistory() async {
    return List.from(_searchHistory);
  }

  @override
  Future<void> saveSearchQuery(String query) async {
    if (!_searchHistory.contains(query)) {
      _searchHistory.add(query);
    }
  }

  @override
  Future<void> deleteSearchQuery(String query) async {
    _searchHistory.remove(query);
  }

  @override
  Future<void> clearSearchHistory() async {
    _searchHistory.clear();
  }

  @override
  Stream<Map<String, dynamic>?> getPriceHistoryStream(String productId) {
    final data = _priceEntries.containsKey(productId)
        ? {
            'predictedPrice': mockPredictedPrices,
            'buyAdvice': mockBuyAdvice,
          }
        : null;
    return Stream.value(data);
  }

  @override
  Stream<List<Map<String, dynamic>>> getPriceEntriesStream(String productId) {
    final entries = _priceEntries[productId] ?? [];
    return Stream.value(entries);
  }

  @override
  Future<Map<String, dynamic>?> getPriceHistory(String productId) async {
    return _priceEntries.containsKey(productId)
        ? {
            'predictedPrice': mockPredictedPrices,
            'buyAdvice': mockBuyAdvice,
          }
        : null;
  }
}
