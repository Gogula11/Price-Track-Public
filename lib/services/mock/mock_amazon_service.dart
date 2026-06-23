import 'package:TrueTrack/models/product.dart';
import 'package:TrueTrack/services/amazon_service.dart';
import 'package:TrueTrack/services/mock/mock_data.dart';

class MockAmazonService implements AmazonService {
  @override
  Future<List<Product>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockAmazonProducts;
  }

  @override
  Future<Map<String, dynamic>> getDetails(String asin) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final details = Map<String, dynamic>.from(mockAmazonProductDetails);
    details['product_photos'] = [details['product_photo'] ?? ''];
    return details;
  }

  @override
  Future<List<dynamic>> getDeals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockDeals;
  }
}
