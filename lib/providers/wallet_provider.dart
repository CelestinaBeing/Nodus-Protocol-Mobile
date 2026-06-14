import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

import '../models/auth_token.dart';
import '../services/auth_service.dart';

enum WalletState { disconnected, connecting, connected, error }

class WalletProvider extends ChangeNotifier {
  WalletProvider() {
    _restoreSession();
  }

  static const _keyAddress = 'stellar_address';
  static const _keyAccess = 'stellar_access_token';
  static const _keyRefresh = 'stellar_refresh_token';

  WalletState _state = WalletState.disconnected;
  String? _address;
  String? _accessToken;
  String? _error;
  Map<String, double> _balances = {};

  final AuthService _authService = AuthService();

  WalletState get state => _state;
  String? get address => _address;
  String? get accessToken => _accessToken;
  String? get error => _error;
  Map<String, double> get balances => _balances;

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString(_keyAddress);
    final token = prefs.getString(_keyAccess);
    if (address != null && token != null) {
      _address = address;
      _accessToken = token;
      _state = WalletState.connected;
      notifyListeners();
    }
  }

  /// Authenticates via SEP-10 using the provided Stellar secret key.
  /// The secret key is used locally only to sign the challenge — it is never
  /// transmitted to the server or stored on device.
  Future<void> connect(String secretKey) async {
    _state = WalletState.connecting;
    _error = null;
    notifyListeners();

    try {
      final keypair = KeyPair.fromSecretSeed(secretKey);
      final AuthToken token = await _authService.authenticateWithStellar(keypair);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAddress, keypair.accountId);
      await prefs.setString(_keyAccess, token.accessToken);
      await prefs.setString(_keyRefresh, token.refreshToken);

      _address = keypair.accountId;
      _accessToken = token.accessToken;
      _balances = {'XLM': 0.0, 'USDC': 0.0};
      _state = WalletState.connected;
    } on ArgumentError {
      _error = 'Invalid secret key. Make sure you entered a valid Stellar secret key (starts with S).';
      _state = WalletState.error;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _state = WalletState.error;
    }

    notifyListeners();
  }

  Future<void> disconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAddress);
    await prefs.remove(_keyAccess);
    await prefs.remove(_keyRefresh);

    _address = null;
    _accessToken = null;
    _balances = {};
    _error = null;
    _state = WalletState.disconnected;
    notifyListeners();
  }
}
