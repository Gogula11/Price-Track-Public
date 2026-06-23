import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrueTrack/services/amazon_service.dart';
import 'package:TrueTrack/services/flipkart_service.dart';
import 'package:TrueTrack/services/ai_service.dart';
import 'package:TrueTrack/services/service_registry.dart';

class ProductSpecificationsPage extends StatefulWidget {
  final String productName;
  final String productId;
  final String source;

  const ProductSpecificationsPage({
    super.key,
    required this.productName,
    required this.productId,
    required this.source,
  });

  @override
  _ProductSpecificationsPageState createState() =>
      _ProductSpecificationsPageState();
}

class _ProductSpecificationsPageState extends State<ProductSpecificationsPage> {
  Map<String, dynamic> specificationsData = {};
  bool _isLoading = true;
  String? _error;
  String _aiSummary = '';
  bool _isSummarizing = false;

  late final AmazonService _amazonService;
  late final FlipkartService _flipkartService;
  late final AiService _aiService;

  @override
  void initState() {
    super.initState();
    _amazonService = context.read<ServiceRegistry>().amazon;
    _flipkartService = context.read<ServiceRegistry>().flipkart;
    _aiService = context.read<ServiceRegistry>().ai;
    _fetchSpecifications();
  }

  Future<void> _fetchSpecifications() async {
    try {
      final data = widget.source == 'Amazon'
          ? await _amazonService.getDetails(widget.productId)
          : await _flipkartService.getDetails(widget.productId);

      setState(() {
        _isLoading = false;
        specificationsData = widget.source == 'Amazon'
            ? _parseAmazonSpecifications(data)
            : _parseFlipkartSpecifications(data);
      });
      _generateAISummary();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error: ${e.toString()}';
      });
    }
  }

  Map<String, dynamic> _parseAmazonSpecifications(Map<String, dynamic> data) {
    return {'Product Information': data['product_information'] ?? {}};
  }

  Map<String, dynamic> _parseFlipkartSpecifications(Map<String, dynamic> data) {
    return data['specifications'] ?? {};
  }

  String _cleanValue(dynamic value) {
    if (value is List) return value.join(', ');
    return value.toString().replaceAll(RegExp(r'[\[\]]'), '');
  }

  Future<void> _generateAISummary() async {
    setState(() => _isSummarizing = true);

    try {
      final summary = await _aiService.summarizeSpecs(
        productName: widget.productName,
        specifications: specificationsData,
      );
      setState(() => _aiSummary = summary);
    } catch (e) {
      setState(() => _aiSummary = 'Error generating AI summary: $e');
    } finally {
      setState(() => _isSummarizing = false);
    }
  }

  Widget _buildSpecCard(String title, Map<String, dynamic>? section) {
    if (section == null || section.isEmpty) return Container();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(height: 20),
            ...section.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${entry.key}:',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _cleanValue(entry.value),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAISummary() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI-Powered Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(height: 20),
            if (_isSummarizing)
              const Center(child: CircularProgressIndicator())
            else if (_aiSummary.isEmpty)
              const Text('No AI summary available.')
            else
              Text(
                _aiSummary,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Specifications'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          widget.productName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildAISummary(),
                        ...specificationsData.entries.map(
                            (entry) => _buildSpecCard(entry.key, entry.value)),
                      ],
                    ),
                  ),
                ),
    );
  }
}
