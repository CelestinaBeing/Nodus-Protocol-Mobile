import 'package:intl/intl.dart';

const int _stroopsPerXlm = 10000000; // 1e7
const int _rawPerUsdc = 1000000; // 1e6

final _decimal4 = NumberFormat('#,##0.0000', 'en_US');
final _compact = NumberFormat.compact(locale: 'en_US');

/// Converts a raw stroop string to a formatted XLM string.
/// Example: "1500000000000" → "150,000.0000"
String stroopsToXlm(String rawStroops) {
  final raw = BigInt.tryParse(rawStroops) ?? BigInt.zero;
  final whole = raw ~/ BigInt.from(_stroopsPerXlm);
  final remainder = raw % BigInt.from(_stroopsPerXlm);
  final value = whole.toDouble() + remainder.toDouble() / _stroopsPerXlm;
  return _decimal4.format(value);
}

/// Converts a raw USDC micro-unit string to a formatted USDC string.
/// Example: "250000000" → "250.0000"
String rawToUsdc(String rawAmount) {
  final raw = BigInt.tryParse(rawAmount) ?? BigInt.zero;
  final whole = raw ~/ BigInt.from(_rawPerUsdc);
  final remainder = raw % BigInt.from(_rawPerUsdc);
  final value = whole.toDouble() + remainder.toDouble() / _rawPerUsdc;
  return _decimal4.format(value);
}

/// Formats a raw numeric string using compact notation.
/// Example: "1500000" → "1.5M"
String compactNumber(String raw) {
  final n = double.tryParse(raw) ?? 0.0;
  return _compact.format(n);
}

/// Formats a token reserve amount based on the token symbol.
/// XLM reserves are in stroops; all others are treated as 6-decimal assets.
String formatReserve(String rawAmount, String tokenSymbol) {
  if (tokenSymbol == 'XLM') {
    return '${stroopsToXlm(rawAmount)} XLM';
  }
  return '${rawToUsdc(rawAmount)} $tokenSymbol';
}
