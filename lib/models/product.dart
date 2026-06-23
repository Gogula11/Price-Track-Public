class Product {
  final String name;
  final String imageUrl;
  final String price;
  final String?
      originalPrice; // Nullable to handle cases where it might not exist
  final String source;
  final String productId; // Product ID field
  final bool isDeal;
  final String? productUrl;
  final String? url;
  // Constructor
  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice, // Initialize originalPrice
    required this.source,
    required this.productId, // Initialize productId
    required this.isDeal,
    this.productUrl,
    this.url,
  });

  // Factory method to parse data from JSON
  factory Product.fromJson(Map<String, dynamic> json, String source) {
    return Product(
      name: json['name'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? '',
      price: json['price'] ?? '0',
      originalPrice: json['originalPrice'], // Parse the originalPrice field
      source: source,
      productId: json['productId'] ?? '', // Use the appropriate field for ID
      isDeal: json['isDeal'] ?? false,
    );
  }
}
