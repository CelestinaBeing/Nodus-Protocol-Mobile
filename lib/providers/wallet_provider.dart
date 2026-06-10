import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WalletState { disconnected, connecting, connected, error }

const _kAddress = 'nodus_wallet_address';

class WalletProvider extends ChangeNotifier {
  WalletState _state = WalletState.disconnected;
  String? _address;
  String? _error;
  Map<String, double> _balances = {};

  WalletState get state => _state;
  String? get address => _address;
  String? get error => _error;
  Map<String, double> get balances => _balances;

  WalletProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kAddress);
    if (saved != null) {
      _address = saved;
      _state = WalletState.connected;
      notifyListeners();
    }
  }

  /// Connect by providing a Stellar public key (G...).
  /// In production this would integrate with a mobile wallet SDK or
  /// hardware wallet; for now it accepts the public key directly.
  Future<void> connect({String? publicKey}) async {
    _state = WalletState.connecting;
    _error = null;
    notifyListeners();

    try {
      if (publicKey == null || publicKey.isEmpty) {
        throw Exception('A Stellar public key is required');
      }
      if (!publicKey.startsWith('G') || publicKey.length != 56) {
        throw Exception('Invalid Stellar public key');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAddress, publicKey);

      _address = publicKey;
      _balances = {'XLM': 0, 'USDC': 0};
      _state = WalletState.connected;
    } catch (e) {
      _error = e.toString();
      _state = WalletState.error;
    }

    notifyListeners();
  }

  Future<void> disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAddress);
    _address = null;
    _balances = {};
    _state = WalletState.disconnected;
    notifyListeners();
  }
}
