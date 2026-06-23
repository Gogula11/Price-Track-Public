import 'package:TrueTrack/models/product.dart';
import 'package:TrueTrack/services/flipkart_service.dart';
import 'package:TrueTrack/services/mock/mock_data.dart';

class MockFlipkartService implements FlipkartService {
  @override
  Future<List<Product>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockFlipkartProducts;
  }

  @override
  Future<Map<String, dynamic>> getDetails(String pid) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Map<String, dynamic>.from(mockFlipkartProductDetails);
  }
}
