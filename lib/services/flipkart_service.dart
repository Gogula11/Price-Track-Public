import 'dart:convert';
import 'package:TrueTrack/models/product.dart';
import 'package:TrueTrack/services/rapidapi_client.dart';

class FlipkartService {
  final RapidApiClient _client;
  final String _host = 'real-time-flipkart-api.p.rapidapi.com';

  FlipkartService(this._client);

  Future<List<Product>> search(String query) async {
    final url =
        'https://$_host/product-search?q=$query&page=1&sort_by=popularity';
    final response = await _client.get(url, _host);

    if (response.statusCode != 200) {
      throw Exception('Failed to search Flipkart products');
    }

    final data = json.decode(response.body);
    final products = data['products'] as List? ?? [];
    return products
        .map<Product>((item) => Product(
              name: item['title'] ?? 'No Title',
              imageUrl: (item['images'] != null &&
                      (item['images'] as List).isNotEmpty)
                  ? (item['images'] as List)[0]
                  : '',
              price: item['price']?.toString() ?? '0',
              source: 'Flipkart',
              productId: item['pid'] ?? '',
              isDeal: item['isDeal'] ?? false,
            ))
        .toList();
  }

  Future<Map<String, dynamic>> getDetails(String pid) async {
    final url = 'https://$_host/product-details?pid=$pid';
    final response = await _client.get(url, _host);

    if (response.statusCode != 200) {
      throw Exception('Failed to load Flipkart product details');
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }
}
