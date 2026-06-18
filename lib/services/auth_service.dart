import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

import '../models/auth_token.dart';

const String _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

const String _stellarNetwork = String.fromEnvironment(
  'STELLAR_NETWORK',
  defaultValue: 'testnet',
);

class AuthService {
  AuthService() : _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  final Dio _dio;

  /// Signs the SEP-10 challenge locally using the provided Stellar keypair
  /// and exchanges it for a JWT token pair.
  Future<AuthToken> authenticateWithStellar(KeyPair keypair) async {
    final accountId = keypair.accountId;

    // 1. Fetch the challenge XDR from the backend
    final challengeResponse = await _dio.get(
      '/api/v1/auth/stellar/challenge',
      queryParameters: {'account': accountId},
    );
    final challengeXdr = challengeResponse.data['data']['transaction'] as String;

    // 2. Sign the challenge with the keypair locally
    final network = _stellarNetwork == 'mainnet' ? Network.PUBLIC : Network.TESTNET;
    final signedXdr = _signChallenge(challengeXdr, keypair, network);

    // 3. Exchange the signed challenge for JWT tokens
    final tokenResponse = await _dio.post(
      '/api/v1/auth/stellar/token',
      data: {'transaction': signedXdr},
    );
    final tokens = tokenResponse.data['data']['tokens'] as Map<String, dynamic>;
    return AuthToken.fromJson(tokens);
  }

  /// Logs out the user by invalidating the access token on the backend.
  /// This blacklists the JWT token to prevent its further use.
  /// Even if the backend call fails, the local logout should proceed
  /// to ensure the user can always disconnect from the app.
  Future<void> logout(String accessToken) async {
    try {
      await _dio.post(
        '/api/v1/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } catch (e) {
      // Log the failure for monitoring but don't block local disconnect
      // This ensures users can always logout locally even if backend is unreachable
      debugPrint('[AuthService] Backend logout failed: $e');
    }
  }

  String _signChallenge(String xdrBase64, KeyPair keypair, Network network) {
    final envelope = XdrTransactionEnvelope.fromEnvelopeXdrString(xdrBase64);

    AbstractTransaction tx;
    if (envelope.discriminant == XdrEnvelopeType.ENVELOPE_TYPE_TX) {
      tx = AbstractTransaction.fromEnvelopeXdr(envelope);
    } else {
      throw StateError('Unsupported transaction envelope type in SEP-10 challenge');
    }

    tx.sign(keypair, network);
    return tx.toEnvelopeXdrBase64();
  }
}
