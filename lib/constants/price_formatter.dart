import 'package:intl/intl.dart';

extension PriceFormatter on String {
  String get formatIndianPrice {
    try {
      final cleaned = replaceAll(RegExp(r'[^0-9.]'), '');
      final amount = double.parse(cleaned);
      return NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 0,
      ).format(amount);
    } catch (e) {
      return '₹$this';
    }
  }
}

String formatIndianPrice(String price) {
  try {
    final cleaned = price.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.parse(cleaned);
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  } catch (e) {
    return '₹$price';
  }
}
