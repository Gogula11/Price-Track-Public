import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrueTrack/models/product.dart';
import 'package:TrueTrack/pages/product_page.dart';
import 'package:TrueTrack/constants/price_formatter.dart';
import 'package:TrueTrack/providers/auth_provider.dart';
import 'package:TrueTrack/services/service_registry.dart';
import 'package:TrueTrack/widgets/product_image.dart';

class TrackedProductsPage extends StatelessWidget {
  const TrackedProductsPage({super.key});

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    String documentId,
  ) async {
    bool isDeleteEnabled = false;
    int remainingSeconds = 5;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (!isDeleteEnabled) {
              Future.delayed(const Duration(seconds: 1), () {
                if (remainingSeconds > 0) {
                  setState(() {
                    remainingSeconds--;
                  });
                  if (remainingSeconds == 0) {
                    setState(() {
                      isDeleteEnabled = true;
                    });
                  }
                }
              });
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Delete Tracking?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Are you sure you want to delete this tracked product?',
                  ),
                  if (!isDeleteEnabled) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Delete button will be enabled in $remainingSeconds seconds',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              actionsPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 0,
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isDeleteEnabled
                            ? () async {
                                Navigator.of(context).pop();
                                try {
                                  await context
                                      .read<ServiceRegistry>()
                                      .firestore
                                      .untrackProduct(documentId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Tracked product deleted successfully.',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to delete tracked product: $e',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: TextButton.styleFrom(
                          foregroundColor:
                              isDeleteEnabled ? Colors.red : Colors.grey,
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tracked Products'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'Please log in to see your tracked products.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracked Products'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: context
            .read<ServiceRegistry>()
            .firestore
            .getTrackedProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No tracked products found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productData = products[index];
              final documentId = productData['id'] as String;

              final productObj = Product(
                name: productData['productName'] ?? 'Unknown',
                imageUrl: productData['productImage'] ?? '',
                price: productData['price']?.toString() ?? '0',
                originalPrice: productData['originalPrice']?.toString(),
                source: productData['source'] ?? 'Amazon',
                productId: productData['asinOrPid'] ?? '',
                isDeal: productData['isDeal'] ?? true,
                productUrl: productData['productUrl'],
                url: productData['productUrl'],
              );

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductPage(
                          product: productObj,
                          productId: productObj.productId,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        productObj.imageUrl.isNotEmpty
                            ? ProductImage(
                                imageUrl: productObj.imageUrl,
                                productName: productObj.name,
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      productObj.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                        context,
                                        documentId,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Current Price: ${formatIndianPrice(productObj.price)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Target Price: ${formatIndianPrice(productData['setTrackingPrice'].toString())}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Tap to view product details',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
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
    );
  }
}
