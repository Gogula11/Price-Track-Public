import 'package:TrueTrack/pages/accounts_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_search.dart';
import 'product_page.dart';
import 'package:TrueTrack/models/product.dart';
import 'package:TrueTrack/constants/price_formatter.dart';
import 'package:TrueTrack/pages/settings_page.dart';
import 'package:TrueTrack/services/amazon_service.dart';
import 'package:TrueTrack/services/service_registry.dart';
import 'package:TrueTrack/widgets/product_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'TrueTrack',
    'Search',
    'Account',
    'Settings',
  ];

  static final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    const ProductSearchPage(),
    const AccountPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    context
        .read<ServiceRegistry>()
        .notification
        .subscribeToTopic('trackedProducts');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AmazonService _amazonService;

  @override
  void initState() {
    super.initState();
    _amazonService = context.read<ServiceRegistry>().amazon;
  }

  Future<void> _refreshDeals() async {
    setState(() {});
  }

  Future<List<dynamic>> fetchDeals() => _amazonService.getDeals();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshDeals,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Deals',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<dynamic>>(
                future: fetchDeals(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No deals available.🙇‍♂️'));
                  }

                  final deals = snapshot.data!;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: deals.length,
                    itemBuilder: (context, index) {
                      final deal = deals[index];
                      final dealTitle = deal['deal_title'] ?? 'Unknown';
                      final truncatedTitle = dealTitle.length > 40
                          ? '${dealTitle.substring(0, 40)}...'
                          : dealTitle;
                      final dealPrice = deal['deal_price']?['amount'] ?? '0';
                      final originalPrice =
                          deal['list_price']?['amount'] ?? '0';
                      final dealBadge = deal['deal_badge'] ?? '';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductPage(
                                product: Product(
                                  name: deal['deal_title'] ?? 'Unknown',
                                  imageUrl: deal['deal_photo'] ?? '',
                                  price: deal['deal_price']?['amount']
                                          ?.toString() ??
                                      '0',
                                  source: 'Amazon',
                                  productId: deal['product_asin'] ?? '',
                                  isDeal: true,
                                ),
                                productId: deal['product_asin'] ?? '',
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 80,
                                  child: ProductImage(
                                    imageUrl: deal['deal_photo'] ?? '',
                                    productName: deal['deal_title'] ?? '',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 40,
                                  child: Text(
                                    truncatedTitle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatIndianPrice(dealPrice),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  formatIndianPrice(originalPrice),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (dealBadge.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      dealBadge,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text(
                    'Refresh / Retry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
