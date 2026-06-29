import 'package:flutter_test/flutter_test.dart';
import 'package:nodus_protocol/models/pool_stats.dart';

void main() {
  final reservesJson = <String, dynamic>{
    'reserve_0': '1000000',
    'reserve_1': '500000',
    'token_0': 'XLM',
    'token_1': 'USDC',
    'lp_total_supply': '707106',
    'timestamp_last': 1700000000,
  };

  final poolStatsJson = <String, dynamic>{
    'reserves': reservesJson,
    'price_token0_in_token1': 0.5,
    'price_token1_in_token0': 2.0,
    'k_invariant': '500000000000',
    'fee_bps': 30,
  };

  group('PoolReserves.fromJson', () {
    test('parses reserve fields correctly', () {
      final reserves = PoolReserves.fromJson(reservesJson);
      expect(reserves.reserve0, equals('1000000'));
      expect(reserves.reserve1, equals('500000'));
      expect(reserves.token0, equals('XLM'));
      expect(reserves.token1, equals('USDC'));
      expect(reserves.lpTotalSupply, equals('707106'));
      expect(reserves.timestampLast, equals(1700000000));
    });
  });

  group('PoolStats.fromJson', () {
    late PoolStats stats;

    setUp(() {
      stats = PoolStats.fromJson(poolStatsJson);
    });

    test('parses price fields correctly', () {
      expect(stats.priceToken0InToken1, equals(0.5));
      expect(stats.priceToken1InToken0, equals(2.0));
    });

    test('parses kInvariant correctly', () {
      expect(stats.kInvariant, equals('500000000000'));
    });

    test('parses feeBps correctly', () {
      expect(stats.feeBps, equals(30));
    });

    test('feePercent converts bps to percent correctly', () {
      expect(stats.feePercent, equals(0.3));
    });

    test('pairLabel formats token pair correctly', () {
      expect(stats.pairLabel, equals('XLM/USDC'));
    });

    test('nested reserves are parsed', () {
      expect(stats.reserves.token0, equals('XLM'));
      expect(stats.reserves.token1, equals('USDC'));
    });
  });

  group('PriceQuote.fromJson', () {
    final quoteJson = <String, dynamic>{
      'amount_in': '100000',
      'amount_out': '49850',
      'token_in': 'XLM',
      'token_out': 'USDC',
      'fee_bps': 30,
      'price_impact_bps': 15,
      'effective_price': 0.4985,
    };

    late PriceQuote quote;

    setUp(() {
      quote = PriceQuote.fromJson(quoteJson);
    });

    test('parses amount fields correctly', () {
      expect(quote.amountIn, equals('100000'));
      expect(quote.amountOut, equals('49850'));
    });

    test('parses token fields correctly', () {
      expect(quote.tokenIn, equals('XLM'));
      expect(quote.tokenOut, equals('USDC'));
    });

    test('parses feeBps correctly', () {
      expect(quote.feeBps, equals(30));
    });

    test('parses priceImpactBps correctly', () {
      expect(quote.priceImpactBps, equals(15));
    });

    test('priceImpactPercent converts bps to percent correctly', () {
      expect(quote.priceImpactPercent, equals(0.15));
    });

    test('parses effectivePrice correctly', () {
      expect(quote.effectivePrice, closeTo(0.4985, 0.0001));
    });
  });

  group('UnsignedTx.fromJson', () {
    final txJson = <String, dynamic>{
      'contract_id': 'CXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
      'function': 'swap',
      'args': ['100000', 'XLM', 'USDC'],
      'note': 'Swap 100000 XLM for USDC',
    };

    test('parses all fields correctly', () {
      final tx = UnsignedTx.fromJson(txJson);
      expect(tx.contractId, equals('CXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'));
      expect(tx.function, equals('swap'));
      expect(tx.note, equals('Swap 100000 XLM for USDC'));
    });

    test('parses args as dynamic', () {
      final tx = UnsignedTx.fromJson(txJson);
      expect(tx.args, isNotNull);
    });
  });
}
