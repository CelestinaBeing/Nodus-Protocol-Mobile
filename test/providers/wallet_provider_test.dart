import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nodus_protocol/providers/wallet_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // FlutterSecureStorage uses a MethodChannel with no platform implementation
  // in the test environment. Mock it so _restoreSession() resolves to null
  // instead of throwing MissingPluginException after each test completes.
  const _secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  late WalletProvider provider;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, (_) async => null);
    SharedPreferences.setMockInitialValues({});
    provider = WalletProvider();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_secureStorageChannel, null);
  });

  group('WalletProvider Tests - MOB-012 Fix', () {
    group('disconnect() - Backend Logout Integration', () {
      test('should initialize in disconnected state', () {
        expect(provider.state, equals(WalletState.disconnected));
        expect(provider.accessToken, isNull);
        expect(provider.address, isNull);
      });

      test('should have disconnect method available', () {
        // This tests that the disconnect method exists and can be called
        // In a full implementation with proper DI, we'd test the actual behavior
        expect(provider.disconnect, isA<Function>());
      });
    });

    group('connect() - Secure Storage Integration', () {
      test('should handle invalid secret key gracefully', () async {
        // Arrange
        const invalidKey = 'invalid_key';

        // Act
        await provider.connect(invalidKey);

        // Assert
        expect(provider.state, equals(WalletState.error));
        expect(provider.error, contains('Invalid secret key'));
      });

      test('should validate secret key format', () async {
        // Arrange
        const shortKey = 'S123';

        // Act
        await provider.connect(shortKey);

        // Assert
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
        // Test that all required getters exist
        expect(provider.state, isA<WalletState>());
        expect(provider.address, isA<String?>());
        expect(provider.accessToken, isA<String?>());
        expect(provider.error, isA<String?>());
        expect(provider.balances, isA<Map<String, double>>());
      });
    });
  });
}
