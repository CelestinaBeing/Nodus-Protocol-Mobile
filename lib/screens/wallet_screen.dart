import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallet_provider.dart';
import '../widgets/transaction_button.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: Consumer<WalletProvider>(
        builder: (context, provider, child) {
          if (provider.state == WalletState.disconnected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 64),
                  const SizedBox(height: 16),
                  const Text('Wallet not connected'),
                  const SizedBox(height: 24),
                  TransactionButton(
                    label: 'Connect Wallet',
                    onSubmit: () => provider.connect(),
                  ),
                ],
              ),
            );
          }

          if (provider.state == WalletState.connecting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.state == WalletState.error) {
            return Center(
              child: Text('Error: ${provider.error}'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.account_circle),
                    ),
                    title: const Text('Connected Account'),
                    subtitle: Text(provider.address ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {},
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Balances',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.balances.length,
                    itemBuilder: (context, index) {
                      final entry = provider.balances.entries.elementAt(index);
                      return ListTile(
                        leading: const Icon(Icons.token_outlined),
                        title: Text(entry.key),
                        trailing: Text(entry.value.toStringAsFixed(4)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => provider.disconnect(),
                    child: const Text('Disconnect'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
