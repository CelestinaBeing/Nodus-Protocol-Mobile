import 'package:flutter_test/flutter_test.dart';
import 'package:nodus_protocol/utils/formatters.dart';

void main() {
  group('stroopsToXlm', () {
    test('converts 150,000 XLM in stroops correctly', () {
      expect(stroopsToXlm('1500000000000'), '150,000.0000');
    });

    test('converts 25 XLM in stroops correctly', () {
      expect(stroopsToXlm('250000000'), '25.0000');
    });

    test('converts 1 stroop to fractional XLM', () {
      expect(stroopsToXlm('1'), '0.0000');
    });

    test('converts zero', () {
      expect(stroopsToXlm('0'), '0.0000');
    });

    test('handles invalid input as zero', () {
      expect(stroopsToXlm(''), '0.0000');
      expect(stroopsToXlm('abc'), '0.0000');
    });

    test('formats with thousand separators', () {
      // 1,000 XLM = 10,000,000,000 stroops
      expect(stroopsToXlm('10000000000'), '1,000.0000');
    });
  });

  group('rawToUsdc', () {
    test('converts 250 USDC correctly', () {
      expect(rawToUsdc('250000000'), '250.0000');
    });

    test('converts 1 USDC correctly', () {
      expect(rawToUsdc('1000000'), '1.0000');
    });

    test('converts zero', () {
      expect(rawToUsdc('0'), '0.0000');
    });

    test('handles invalid input as zero', () {
      expect(rawToUsdc('abc'), '0.0000');
    });
  });

  group('compactNumber', () {
    test('formats millions compactly', () {
      expect(compactNumber('1500000'), '1.5M');
    });

    test('formats thousands compactly', () {
      expect(compactNumber('25000'), '25K');
    });

    test('formats small numbers', () {
      expect(compactNumber('500'), '500');
    });

    test('handles zero', () {
      expect(compactNumber('0'), '0');
    });

    test('handles invalid input as zero', () {
      expect(compactNumber('abc'), '0');
    });
  });

  group('formatReserve', () {
    test('formats XLM reserve in stroops', () {
      expect(formatReserve('1500000000000', 'XLM'), '150,000.0000 XLM');
    });

    test('formats USDC reserve', () {
      expect(formatReserve('250000000', 'USDC'), '250.0000 USDC');
    });

    test('formats unknown token as 6-decimal asset', () {
      expect(formatReserve('1000000', 'TOKEN'), '1.0000 TOKEN');
    });
  });
}
