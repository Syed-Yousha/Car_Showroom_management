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
  final s = price.toString();
  if (s.length <= 3) return 'Rs $s';
  String result = s.substring(s.length - 3);
  String remaining = s.substring(0, s.length - 3);
  while (remaining.length > 2) {
    result = '${remaining.substring(remaining.length - 2)},$result';
    remaining = remaining.substring(0, remaining.length - 2);
  }
  result = '$remaining,$result';
  return 'Rs $result';
}
