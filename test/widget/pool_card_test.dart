@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nodus_protocol/models/pool_stats.dart';
import 'package:nodus_protocol/widgets/pool_card.dart';

void main() {
  testWidgets('PoolCard renders correctly with mock data', (tester) async {
    final mockPool = PoolStats(
      pairLabel: 'XLM/USDC',
      contractId: 'CTEST123',
      reserves: PoolReserves(
        token0: 'XLM',
        token1: 'USDC',
        reserve0: '1000000',
        reserve1: '5000000',
        lpTotalSupply: '2236067',
      ),
      feePercent: 0.3,
      volume24h: 125000.50,
      tvl: 6000000.00,
      apr: 12.5,
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
    final mockPool = PoolStats(
      pairLabel: 'XLM/USDC',
      contractId: 'CTEST123',
      reserves: PoolReserves(
        token0: 'XLM',
        token1: 'USDC',
        reserve0: '1000000',
        reserve1: '5000000',
        lpTotalSupply: '2236067',
      ),
      feePercent: 0.3,
      volume24h: 125000.50,
      tvl: 6000000.00,
      apr: 12.5,
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
