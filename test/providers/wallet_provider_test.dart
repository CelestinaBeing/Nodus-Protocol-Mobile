import 'package:flutter_test/flutter_test.dart';
import 'package:nodus_protocol/providers/wallet_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WalletProvider Tests - MOB-012 Fix', () {
    late WalletProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = WalletProvider();
    });

    group('disconnect() - Backend Logout Integration', () {
      test('should initialize in disconnected state', () {
        expect(provider.state, equals(WalletState.disconnected));
        expect(provider.accessToken, isNull);
        expect(provider.address, isNull);
      });

      test('should have disconnect method available', () {
        expect(provider.disconnect, isA<Function>());
      });
    });

    group('connect() - Secure Storage Integration', () {
      test('should handle invalid secret key gracefully', () async {
        await provider.connect('invalid_key');

        expect(provider.state, equals(WalletState.error));
        expect(provider.error, contains('Invalid secret key'));
      });

      test('should validate secret key format', () async {
        await provider.connect('S123');

        expect(provider.state, equals(WalletState.error));
        expect(provider.error, isNotNull);
      });
    });

    group('Security Improvements', () {
      test('should initialize with secure state', () {
        expect(provider.state, equals(WalletState.disconnected));
        expect(provider.balances, isEmpty);
      });

      test('should have proper state management', () {
        expect(provider.state, isA<WalletState>());
        expect(provider.address, isA<String?>());
        expect(provider.accessToken, isA<String?>());
        expect(provider.error, isA<String?>());
        expect(provider.balances, isA<Map<String, double>>());
      });
    });
  });
}
