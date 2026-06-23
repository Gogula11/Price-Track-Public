import 'package:flutter/foundation.dart';
import 'package:TrueTrack/models/product.dart';
import 'package:TrueTrack/services/amazon_service.dart';
import 'package:TrueTrack/services/flipkart_service.dart';
import 'package:TrueTrack/services/firestore_service.dart';
import 'package:TrueTrack/services/rapidapi_client.dart';

class ProductProvider extends ChangeNotifier {
  final AmazonService _amazonService;
  final FlipkartService _flipkartService;
  final FirestoreService _firestoreService;

  List<Product> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  ProductProvider({RapidApiClient? client, FirestoreService? firestoreService})
      : _amazonService = AmazonService(client ?? RapidApiClient()),
        _flipkartService = FlipkartService(client ?? RapidApiClient()),
        _firestoreService = firestoreService ?? FirestoreService();

  List<Product> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;

  Future<void> search(String query) async {
    if (query.isEmpty) return;

    _isSearching = true;
    _searchError = null;
    _searchResults = [];
    notifyListeners();

    try {
      final amazonProducts = await _amazonService.search(query);
      final flipkartProducts = await _flipkartService.search(query);
      _searchResults = [...amazonProducts, ...flipkartProducts];
    } catch (e) {
      _searchError = e.toString();
    }

    _isSearching = false;
    notifyListeners();
  }

  Future<List<dynamic>> fetchDeals() => _amazonService.getDeals();

  Future<Map<String, dynamic>> fetchProductDetails(Product product) async {
    if (product.source == 'Amazon') {
      return _amazonService.getDetails(product.productId);
    }
    return _flipkartService.getDetails(product.productId);
  }

  Future<void> trackProduct({
    required Product product,
    required String targetPrice,
    required String productUrl,
    String imageUrl = '',
  }) =>
      _firestoreService.trackProduct(
        productId: product.productId,
        productName: product.name,
        productImage: imageUrl.isNotEmpty ? imageUrl : product.imageUrl,
        price: product.price,
        targetPrice: targetPrice,
        productUrl: productUrl,
        source: product.source,
      );

  Future<bool> isProductTracked(String productId) =>
      _firestoreService.isProductTracked(productId);
}
