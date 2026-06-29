import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nodus_protocol/models/pool_stats.dart';
import 'package:nodus_protocol/widgets/pool_card.dart';

@Tags(['golden'])
void main() {
  testWidgets('PoolCard renders correctly with mock data', (tester) async {
    const mockPool = PoolStats(
      reserves: PoolReserves(
        token0: 'XLM',
        token1: 'USDC',
        reserve0: '1000000',
        reserve1: '5000000',
        lpTotalSupply: '2236067',
        timestampLast: 1640000000,
      ),
      priceToken0InToken1: 0.2,
      priceToken1InToken0: 5.0,
      kInvariant: '5000000000000',
      feeBps: 30,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: PoolCard(pool: mockPool),
        ),
      ),
    );

    await expectLater(
      find.byType(PoolCard),
      matchesGoldenFile('goldens/pool_card.png'),
    );
  });

  testWidgets('PoolCard renders correctly in dark theme', (tester) async {
    const mockPool = PoolStats(
      reserves: PoolReserves(
        token0: 'XLM',
        token1: 'USDC',
        reserve0: '1000000',
        reserve1: '5000000',
        lpTotalSupply: '2236067',
        timestampLast: 1640000000,
      ),
      priceToken0InToken1: 0.2,
      priceToken1InToken0: 5.0,
      kInvariant: '5000000000000',
      feeBps: 30,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: PoolCard(pool: mockPool),
        ),
      ),
    );

    await expectLater(
      find.byType(PoolCard),
      matchesGoldenFile('goldens/pool_card_dark.png'),
    );
  });
}
