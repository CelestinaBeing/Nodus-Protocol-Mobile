import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/pool_service.dart';
import '../../widgets/token_input.dart';
import '../../widgets/transaction_button.dart';
import 'estimated_lp_tokens.dart';
import 'pool_share_display.dart';

class RemoveLiquidityForm extends StatefulWidget {
  const RemoveLiquidityForm({super.key});

  @override
  State<RemoveLiquidityForm> createState() => _RemoveLiquidityFormState();
}

class _RemoveLiquidityFormState extends State<RemoveLiquidityForm> {
  final _lpController = TextEditingController();
  final _service = PoolService();
  double _slippage = 0.5;

  @override
  void dispose() {
    _lpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final wallet = context.read<WalletProvider>();
    final txProvider = context.read<TransactionProvider>();

    if (wallet.state != WalletState.connected || wallet.address == null) {
      throw Exception('Please connect your wallet first');
    }
    final liquidity = double.tryParse(_lpController.text);
    if (liquidity == null || liquidity <= 0) {
      throw Exception('Enter a valid LP token amount');
    }

    final deadline =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 300;

    final unsignedTx = await _service.buildRemoveLiquidity({
      'from': wallet.address,
      'to': wallet.address,
      'liquidity': liquidity.toStringAsFixed(7),
      'amount_0_min': '0',
      'amount_1_min': '0',
      'deadline': deadline,
    });

    txProvider.add(TxRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: 'Remove ${_lpController.text} LP tokens',
      status: TxStatus.pending,
      unsignedTx: unsignedTx,
      createdAt: DateTime.now(),
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction built: ${unsignedTx.note}'),
          backgroundColor: Colors.green,
        ),
      );
      _lpController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TokenInput(
            token: null,
            controller: _lpController,
            hintText: 'LP Token Amount',
          ),
          const SizedBox(height: 16),
          EstimatedLpTokens(
            lpAmount: double.tryParse(_lpController.text) ?? 0.0,
            isRemoving: true,
          ),
          const SizedBox(height: 16),
          const PoolShareDisplay(),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Slippage:'),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('0.1%'),
                selected: _slippage == 0.1,
                onSelected: (_) => setState(() => _slippage = 0.1),
              ),
              const SizedBox(width: 4),
              ChoiceChip(
                label: const Text('0.5%'),
                selected: _slippage == 0.5,
                onSelected: (_) => setState(() => _slippage = 0.5),
              ),
              const SizedBox(width: 4),
              ChoiceChip(
                label: const Text('1%'),
                selected: _slippage == 1.0,
                onSelected: (_) => setState(() => _slippage = 1.0),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TransactionButton(
            label: 'Remove Liquidity',
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}
