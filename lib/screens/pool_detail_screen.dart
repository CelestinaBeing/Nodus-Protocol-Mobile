import 'package:flutter/material.dart';

import '../models/pool_stats.dart';
import '../utils/formatters.dart';

class PoolDetailScreen extends StatelessWidget {
  const PoolDetailScreen({super.key, required this.pool});

  final PoolStats pool;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pool.pairLabel)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Pool detail coming soon',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    label: '${pool.reserves.token0} Reserve',
                    value: formatReserve(
                      pool.reserves.reserve0,
                      pool.reserves.token0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: '${pool.reserves.token1} Reserve',
                    value: formatReserve(
                      pool.reserves.reserve1,
                      pool.reserves.token1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Price (${pool.reserves.token0}/${pool.reserves.token1})',
                    value: pool.priceToken0InToken1.toStringAsFixed(6),
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'LP Supply',
                    value: compactNumber(pool.reserves.lpTotalSupply),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
