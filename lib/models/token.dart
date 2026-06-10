enum Token {
  xlm,
  usdc;

  String get symbol {
    switch (this) {
      case Token.xlm:
        return 'XLM';
      case Token.usdc:
        return 'USDC';
    }
  }

  String get name {
    switch (this) {
      case Token.xlm:
        return 'Stellar Lumens';
      case Token.usdc:
        return 'USD Coin';
    }
  }
}
