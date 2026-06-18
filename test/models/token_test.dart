import 'package:flutter_test/flutter_test.dart';
import 'package:nodus_protocol/models/token.dart';

void main() {
  group('Token enum', () {
    test('XLM has correct symbol', () {
      expect(Token.xlm.symbol, equals('XLM'));
    });

    test('USDC has correct symbol', () {
      expect(Token.usdc.symbol, equals('USDC'));
    });

    test('XLM has correct name', () {
      expect(Token.xlm.name, equals('Stellar Lumens'));
    });

    test('USDC has correct name', () {
      expect(Token.usdc.name, equals('USD Coin'));
    });

    test('all Token values have non-empty symbols', () {
      for (final token in Token.values) {
        expect(token.symbol.isNotEmpty, isTrue);
      }
    });

    test('all Token values have non-empty names', () {
      for (final token in Token.values) {
        expect(token.name.isNotEmpty, isTrue);
      }
    });
  });
}
