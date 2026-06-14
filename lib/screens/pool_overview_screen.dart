import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pool_provider.dart';
import '../widgets/error_banner.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/pool_card.dart';

class PoolOverviewScreen extends StatefulWidget {
  const PoolOverviewScreen({super.key});

  @override
  State<PoolOverviewScreen> createState() => _PoolOverviewScreenState();
}

class _PoolOverviewScreenState extends State<PoolOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PoolProvider>().loadPools();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pools'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PoolProvider>().loadPools(),
          ),
        ],
      ),
      body: Consumer<PoolProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.pools.isEmpty) {
            return const LoadingOverlay();
          }

          if (provider.error != null && provider.pools.isEmpty) {
            return ErrorBanner(message: provider.error!);
          }

          return RefreshIndicator(
            onRefresh: provider.loadPools,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: provider.pools.length,
              itemBuilder: (context, index) {
                final pool = provider.pools[index];
                return PoolCard(pool: pool);
              },
            ),
          );
        },
      ),
    );
  }
}
