import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:TrueTrack/models/product.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:TrueTrack/pages/tracked_products_page.dart';
import 'dart:math';
import 'package:TrueTrack/constants/price_formatter.dart';
import 'package:TrueTrack/pages/product_specifications_page.dart';
import 'package:TrueTrack/services/amazon_service.dart';
import 'package:TrueTrack/services/flipkart_service.dart';
import 'package:TrueTrack/services/ai_service.dart';
import 'package:TrueTrack/services/firestore_service.dart';
import 'package:TrueTrack/services/service_registry.dart';
import 'package:TrueTrack/widgets/product_image.dart';

class ProductPage extends StatefulWidget {
  final Product product;
  final String productId;

  const ProductPage(
      {super.key, required this.product, required this.productId});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late List<String> imageUrls;
  late double rating;
  late int ratingsCount;
  late String customerReview;
  late String productUrl;
  late String originalPrice;
  String _currentPrice = '';
  final TextEditingController _priceAlertController = TextEditingController();
  bool _isProductTracked = false;

  List<Product> _relatedProducts = [];
  bool _isRelatedLoading = false;
  String? _relatedError;

  late final AmazonService _amazonService;
  late final FlipkartService _flipkartService;
  late final AiService _aiService;
  late final FirestoreService _firestoreService;

  @override
  void initState() {
    super.initState();
    _amazonService = context.read<ServiceRegistry>().amazon;
    _flipkartService = context.read<ServiceRegistry>().flipkart;
    _aiService = context.read<ServiceRegistry>().ai;
    _firestoreService = context.read<ServiceRegistry>().firestore;

    imageUrls = [];
    rating = 0.0;
    ratingsCount = 0;
    customerReview = 'Loading customer review summary...';
    productUrl = widget.product.productUrl ?? widget.product.url ?? '';
    originalPrice = widget.product.originalPrice ?? '';
    imageUrls = [widget.product.imageUrl];
    _fetchProductDetails();
    _checkIfProductIsTracked();
    _fetchRelatedProducts();
  }

  Future<void> _checkIfProductIsTracked() async {
    final tracked = await _firestoreService.isProductTracked(widget.productId);
    if (mounted) setState(() => _isProductTracked = tracked);
  }

  Future<void> _fetchProductDetails() async {
    try {
      final data = widget.product.source == 'Amazon'
          ? await _amazonService.getDetails(widget.productId)
          : await _flipkartService.getDetails(widget.productId);

      if (!mounted) return;
      setState(() {
        if (widget.product.source == 'Amazon') {
          _parseAmazonData(data);
        } else {
          _parseFlipkartData(data);
        }
      });
    } catch (e) {
      if (mounted) {
        print('Error fetching product details: $e');
      }
    }
  }

  void _parseAmazonData(Map<String, dynamic> data) {
    productUrl = data['product_url'] ?? productUrl;
    imageUrls = data['product_photos'] != null
        ? List<String>.from(data['product_photos'])
        : (data['product_photo'] != null ? [data['product_photo']] : imageUrls);
    originalPrice = data['product_original_price']?.toString() ?? originalPrice;
    rating = double.tryParse(data['product_star_rating'].toString()) ?? 0.0;
    ratingsCount = data['product_num_ratings'] ?? 0;
    _currentPrice = data['product_price']?.toString() ?? _currentPrice;

    final rawReviews = data['customers_say'] ?? '';
    if (rawReviews.isNotEmpty) {
      _aiService
          .summarizeReviews(
            reviews: rawReviews,
            source: 'Amazon',
            productUrl: productUrl,
            productName: widget.product.name,
          )
          .then((summary) =>
              mounted ? setState(() => customerReview = summary) : null);
    }
  }

  void _parseFlipkartData(Map<String, dynamic> data) {
    productUrl = data['url'] ?? productUrl;
    imageUrls =
        data['images'] != null ? List<String>.from(data['images']) : imageUrls;
    originalPrice = data['mrp']?.toString() ?? originalPrice;
    rating = (data['rating']?['overall']?['average'] ?? 0.0).toDouble();
    ratingsCount = data['rating']?['overall']?['count'] ?? 0;
    _currentPrice = data['price']?.toString() ?? _currentPrice;

    final reviews = data['reviews'] ?? [];
    if (reviews.isNotEmpty) {
      _aiService
          .summarizeReviews(
            reviews: reviews,
            source: 'Flipkart',
            productUrl: productUrl,
            productName: widget.product.name,
          )
          .then((summary) =>
              mounted ? setState(() => customerReview = summary) : null);
    }
  }

  Future<void> _fetchRelatedProducts() async {
    final query = widget.product.name;
    setState(() {
      _isRelatedLoading = true;
      _relatedError = null;
      _relatedProducts = [];
    });

    try {
      final amazonProducts = await _amazonService.search(query);
      final flipkartProducts = await _flipkartService.search(query);

      if (!mounted) return;
      setState(() {
        _relatedProducts = [...amazonProducts, ...flipkartProducts];
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _relatedError = 'An error occurred: ${error.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isRelatedLoading = false);
      }
    }
  }

  Future<void> _launchURL() async {
    final uri = Uri.parse(productUrl);
    await launchUrl(uri);
  }

  void _handleTrackButtonPress() async {
    final priceText = _priceAlertController.text.trim();
    if (priceText.isEmpty || double.tryParse(priceText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              priceText.isEmpty ? 'Please enter a price' : 'Invalid price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _firestoreService.trackProduct(
      productId: widget.productId,
      productName: widget.product.name,
      productImage: imageUrls.isNotEmpty ? imageUrls[0] : '',
      price: _currentPrice,
      targetPrice: priceText.replaceAll('₹', ''),
      productUrl: productUrl,
      source: widget.product.source,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product tracked successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TrackedProductsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            const SizedBox(height: 20),
            _buildProductInfo(),
            const SizedBox(height: 20),
            _buildTrackingSection(),
            const SizedBox(height: 20),
            _buildReviewSummary(),
            const SizedBox(height: 20),
            _buildPriceHistoryChart(),
            const SizedBox(height: 20),
            _buildPredictedPriceChart(),
            const SizedBox(height: 20),
            _buildBuyAdviceSection(),
            const SizedBox(height: 20),
            _buildRelatedProducts(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return CarouselSlider(
      items: imageUrls
          .map((url) => ProductImage(
              imageUrl: url,
              productName: widget.product.name,
              height: 300))
          .toList(),
      options: CarouselOptions(
        height: 300,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.product.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            ...List.generate(
                5,
                (i) => Icon(
                      Icons.star,
                      color: i < rating.floor() ? Colors.amber : Colors.grey,
                    )),
            const SizedBox(width: 10),
            Text('(${NumberFormat.compact().format(ratingsCount)} reviews)'),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Text(
              _currentPrice.isNotEmpty
                  ? _currentPrice.formatIndianPrice
                  : 'Loading...',
              style: const TextStyle(
                  fontSize: 28,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            if (originalPrice.isNotEmpty) ...[
              const SizedBox(width: 15),
              Text(
                originalPrice.formatIndianPrice,
                style: const TextStyle(
                    decoration: TextDecoration.lineThrough, color: Colors.grey),
              ),
            ],
          ],
        ),
        const SizedBox(height: 15),
        Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _launchURL,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text('Buy on ${widget.product.source}',
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductSpecificationsPage(
                        productName: widget.product.name,
                        productId: widget.productId,
                        source: widget.product.source,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('View Specifications',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingSection() {
    return _isProductTracked
        ? Column(
            children: [
              const Text('Already tracking this product',
                  style: TextStyle(color: Colors.green)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TrackedProductsPage()),
                ),
                child: const Text('View Tracked Products'),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceAlertController,
                  decoration: const InputDecoration(
                    labelText: 'Set Price Alert',
                    prefixText: '₹',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _handleTrackButtonPress,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                ),
                child: const Text('Track Price'),
              ),
            ],
          );
  }

  Widget _buildReviewSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Summary and Alternatives',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(customerReview),
        ),
      ],
    );
  }

  Widget _buildPriceHistoryChart() {
    String? selectedDate;
    String? selectedPrice;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getPriceEntriesStream(widget.productId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('No price history available'));
        }

        final dateFormat = DateFormat('dd-MM-yyyy');
        final sortedDocs = docs.toList()
          ..sort((a, b) => dateFormat
              .parse(a['id'] as String)
              .compareTo(dateFormat.parse(b['id'] as String)));

        final List<FlSpot> spots = [];
        final List<String> dates = [];

        for (int i = 0; i < sortedDocs.length; i++) {
          final doc = sortedDocs[i];
          final price = double.tryParse(
                  doc['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ??
              0.0;
          spots.add(FlSpot(i.toDouble(), price));
          dates.add(doc['id'] as String);
        }

        final minY = spots.map((s) => s.y).reduce(min) * 0.98;
        final maxY = spots.map((s) => s.y).reduce(max) * 1.02;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'Price History Graph',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              height: 280,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: spots.length - 1,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: Colors.indigo,
                      barWidth: 2.5,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.indigo.withOpacity(0.1),
                      ),
                      dotData: const FlDotData(
                        show: false,
                      ),
                      shadow: const Shadow(
                        blurRadius: 8,
                        color: Colors.indigo,
                        offset: Offset(0, 2),
                      ),
                    ),
                  ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${dates[spot.x.toInt()]}\n₹${spot.y.toStringAsFixed(0)}',
                            const TextStyle(
                                color: Colors.white, fontSize: 12, height: 1.4),
                          );
                        }).toList();
                      },
                    ),
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? response) {
                      if (event is FlTapUpEvent &&
                          response?.lineBarSpots != null) {
                        final spot = response?.lineBarSpots?.first;
                        if (spot != null) {
                          setState(() {
                            selectedDate = dates[spot.x.toInt()];
                            selectedPrice = '₹${spot.y.toStringAsFixed(0)}';
                          });
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (selectedDate != null && selectedPrice != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '$selectedDate  •  $selectedPrice',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPredictedPriceChart() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _firestoreService.getPriceHistoryStream(widget.productId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;
        final predictedPriceArray = data?['predictedPrice'] as List<dynamic>?;

        if (predictedPriceArray == null || predictedPriceArray.isEmpty) {
          return const Center(child: Text('No predicted price available'));
        }

        final List<FlSpot> spots = [];
        final List<String> dates = [];

        for (int i = 0; i < predictedPriceArray.length; i++) {
          final prediction = predictedPriceArray[i] as Map<String, dynamic>;
          final dateStr = prediction['date'] as String? ?? '';
          final priceStr = prediction['price'] as String? ?? '0';

          final price =
              double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ??
                  0.0;

          spots.add(FlSpot(i.toDouble(), price));
          dates.add(dateStr);
        }

        final minY = spots.map((s) => s.y).reduce(min) * 0.98;
        final maxY = spots.map((s) => s.y).reduce(max) * 1.02;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'Possible future price trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              height: 280,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: spots.length - 1,
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: Colors.deepOrangeAccent,
                      barWidth: 2.5,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.deepOrangeAccent.withOpacity(0.1),
                      ),
                      dotData: const FlDotData(
                        show: false,
                      ),
                      shadow: const Shadow(
                        blurRadius: 8,
                        color: Colors.deepOrangeAccent,
                        offset: Offset(0, 2),
                      ),
                    ),
                  ],
                  lineTouchData: const LineTouchData(
                    enabled: false,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBuyAdviceSection() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _firestoreService.getPriceHistoryStream(widget.productId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;
        final buyAdviceText =
            data?['buyAdvice'] as String? ?? 'No buy advice available.';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buy Advice',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(buyAdviceText),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRelatedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Related Products',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (_isRelatedLoading)
          const Center(child: CircularProgressIndicator())
        else if (_relatedError != null)
          Center(child: Text(_relatedError!))
        else if (_relatedProducts.isEmpty)
          const Center(child: Text('No related products found'))
        else
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _relatedProducts.length,
              itemBuilder: (context, index) {
                final related = _relatedProducts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductPage(
                          product: related,
                          productId: related.productId,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 180,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          related.imageUrl.isNotEmpty
                              ? ProductImage(
                                  imageUrl: related.imageUrl,
                                  productName: related.name,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                )
                              : const Icon(Icons.shopping_bag, size: 80),
                          const SizedBox(height: 8),
                          Text(
                            related.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            related.price.formatIndianPrice,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            related.source,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
