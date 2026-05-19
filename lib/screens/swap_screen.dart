import 'package:flutter/material.dart';

import '../components/swap/swap_card.dart';

class SwapScreen extends StatelessWidget {
  const SwapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swap'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: SwapCard(),
      ),
    );
  }
}
