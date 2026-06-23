import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final double width;
  final double height;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.productName,
    this.width = double.infinity,
    this.height = 150,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _buildPlaceholder();

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoading();
      },
    );
  }

  Widget _buildPlaceholder() {
    final color = _colorFromName(productName);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          productName.isNotEmpty ? productName[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: height * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  static Color _colorFromName(String name) {
    final hash = name.hashCode;
    final hue = (hash & 0xFFF).toDouble() / 0xFFF * 360;
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
  }
}