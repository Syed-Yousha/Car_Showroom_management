// Shared formatting & pricing utilities used across all screens.

/// Formats price with abbreviated suffixes (Cr, L, K).
/// [zeroText] controls what to show when price is 0 (default: 'Rs 0').
String formatPrice(int price, {String zeroText = 'Rs 0'}) {
  if (price >= 10000000) return 'Rs ${(price / 10000000).toStringAsFixed(1)}Cr';
  if (price >= 100000) return 'Rs ${(price / 100000).toStringAsFixed(1)}L';
  if (price >= 1000) return 'Rs ${(price / 1000).toStringAsFixed(0)}K';
  if (price == 0) return zeroText;
  return 'Rs $price';
}

/// Formats price with full comma-separated Indian numbering (e.g. Rs 85,00,000).
String formatFullPrice(int price) {
  final str = price.toString();
  final buf = StringBuffer();
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    buf.write(str[i]);
    count++;
    if (count == 3 && i > 0) {
      buf.write(',');
      count = 0;
    } else if (count > 3 && (count - 3) % 2 == 0 && i > 0) {
      buf.write(',');
    }
  }
  return 'Rs ${buf.toString().split('').reversed.join()}';
}
