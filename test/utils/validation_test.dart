import 'package:flutter_test/flutter_test.dart';
import 'package:nodus_protocol/utils/validation.dart';

void main() {
  group('Validation.stellarSecretKey', () {
    test('valid 56-char S-key returns null', () {
      const key = 'SCZANGBA5AKIA7ORYH4RO2EQVN3ISYIKXT6EU7EOSQ37NQBP5M4OBK3';
      expect(Validation.stellarSecretKey(key), isNull);
    });

    test('empty string fails', () {
      expect(Validation.stellarSecretKey(''), isNotNull);
    });

    test('wrong prefix fails', () {
      expect(Validation.stellarSecretKey('GAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'), isNotNull);
    });

    test('wrong length fails', () {
      expect(Validation.stellarSecretKey('SSHORT'), isNotNull);
    });

    test('invalid base32 chars fail', () {
      expect(Validation.stellarSecretKey('S' + '1' * 55), isNotNull);
    });

    test('valid key with spaces trims and validates', () {
      const key = ' SCZANGBA5AKIA7ORYH4RO2EQVN3ISYIKXT6EU7EOSQ37NQBP5M4OBK3 ';
      expect(Validation.stellarSecretKey(key), isNull);
    });
  });

  group('Validation.stellarPublicKey', () {
    test('valid 56-char G-key returns null', () {
      const key = 'GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAXJH';
      expect(Validation.stellarPublicKey(key), isNull);
    });

    test('empty string fails', () {
      expect(Validation.stellarPublicKey(''), isNotNull);
    });

    test('wrong prefix fails', () {
      expect(Validation.stellarPublicKey('SAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'), isNotNull);
    });

    test('wrong length fails', () {
      expect(Validation.stellarPublicKey('GSHORT'), isNotNull);
    });
  });
}
