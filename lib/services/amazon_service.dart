import 'dart:convert';
import 'package:TrueTrack/models/product.dart';
import 'package:TrueTrack/services/rapidapi_client.dart';

class AmazonService {
  final RapidApiClient _client;
  final String _host = 'real-time-amazon-data.p.rapidapi.com';

  AmazonService(this._client);

  Future<List<Product>> search(String query) async {
    final url =
        'https://$_host/search?query=$query&page=1&country=IN&sort_by=RELEVANCE&product_condition=ALL';
    final response = await _client.get(url, _host);

    if (response.statusCode != 200) {
      throw Exception('Failed to search Amazon products');
    }

    final data = json.decode(response.body);
    final products = data['data']?['products'] as List? ?? [];
    return products
        .map<Product>((item) => Product(
              name: item['product_title'] ?? 'No Title',
              imageUrl: item['product_photo'] ?? '',
              price: item['product_price']?.toString() ?? '0',
              source: 'Amazon',
              productId: item['asin'] ?? '',
              isDeal: item['isDeal'] ?? false,
            ))
        .toList();
  }

  Future<Map<String, dynamic>> getDetails(String asin) async {
    final url = 'https://$_host/product-details?asin=$asin&country=IN';
    final response = await _client.get(url, _host);

    if (response.statusCode != 200) {
      throw Exception('Failed to load Amazon product details');
    }

    return json.decode(response.body)['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getDeals() async {
    final url =
        'https://$_host/deals-v2?country=IN&min_product_star_rating=ALL&price_range=ALL&discount_range=ALL';
    final response = await _client.get(url, _host);

    if (response.statusCode != 200) {
      throw Exception('Failed to load Amazon deals');
    }

    final data = json.decode(response.body);
    return data['data']['deals'] as List<dynamic>;
  }
}
