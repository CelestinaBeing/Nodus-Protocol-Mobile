import 'package:flutter/material.dart';

import '../components/liquidity/add_liquidity_form.dart';
import '../components/liquidity/remove_liquidity_form.dart';

class LiquidityScreen extends StatelessWidget {
  const LiquidityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Liquidity'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Add', icon: Icon(Icons.add)),
              Tab(text: 'Remove', icon: Icon(Icons.remove)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddLiquidityForm(),
            RemoveLiquidityForm(),
          ],
        ),
      ),
    );
  }
}
