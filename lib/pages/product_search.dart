import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrueTrack/models/product.dart';
import 'package:TrueTrack/pages/product_page.dart';
import 'package:TrueTrack/constants/price_formatter.dart';
import 'package:TrueTrack/services/amazon_service.dart';
import 'package:TrueTrack/services/flipkart_service.dart';
import 'package:TrueTrack/services/firestore_service.dart';
import 'package:TrueTrack/services/service_registry.dart';
import 'package:TrueTrack/widgets/product_image.dart';

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  _ProductSearchPageState createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSearchFocused = false;

  late final AmazonService _amazonService;
  late final FlipkartService _flipkartService;
  late final FirestoreService _firestoreService;

  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _amazonService = context.read<ServiceRegistry>().amazon;
    _flipkartService = context.read<ServiceRegistry>().flipkart;
    _firestoreService = context.read<ServiceRegistry>().firestore;
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final history = await _firestoreService.getSearchHistory();
    setState(() => _searchHistory = history);
  }

  Future<void> _saveSearchQuery(String query) async {
    await _firestoreService.saveSearchQuery(query);
    await _loadSearchHistory();
  }

  Future<void> _deleteSearchQuery(String query) async {
    await _firestoreService.deleteSearchQuery(query);
    setState(() => _searchHistory.remove(query));
  }

  Future<void> _clearSearchHistory() async {
    await _firestoreService.clearSearchHistory();
    setState(() => _searchHistory = []);
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _products = [];
      _isSearchFocused = false;
    });

    await _saveSearchQuery(query);

    try {
      final amazonProducts = await _amazonService.search(query);
      final flipkartProducts = await _flipkartService.search(query);

      setState(() {
        _isLoading = false;
        _products = [...amazonProducts, ...flipkartProducts];
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: ${error.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() => _isSearchFocused = false);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Enter a product name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                onTap: () => setState(() => _isSearchFocused = true),
                onSubmitted: (query) {
                  if (query.isNotEmpty) _searchProducts(query);
                },
              ),
            ),
            if (_isSearchFocused && _searchHistory.isNotEmpty)
              _buildSearchHistory(),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(child: Center(child: Text(_errorMessage!)))
            else if (_products.isNotEmpty)
              _buildProductList()
            else if (!_isSearchFocused && _searchHistory.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Search for products to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: _clearSearchHistory,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                final query = _searchHistory[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(query),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _deleteSearchQuery(query),
                  ),
                  onTap: () {
                    _searchController.text = query;
                    _searchProducts(query);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ProductImage(
                  imageUrl: product.imageUrl,
                  productName: product.name,
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain),
              title: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    formatIndianPrice(product.price),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    product.source,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductPage(
                      product: product,
                      productId: product.productId,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
