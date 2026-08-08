import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String currency(double amount) => _currencyFormat.format(amount);

  static String currencyCompact(double amount) {
    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return currency(amount);
  }

  static String date(DateTime date) => DateFormat('dd MMM yyyy').format(date);

  static String time(DateTime date) => DateFormat('h:mm a').format(date);

  static String dateTime(DateTime value) =>
      '${date(value)} · ${time(value)}';

  static String duration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  static String distance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }
}
