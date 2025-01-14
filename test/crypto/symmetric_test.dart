import 'package:dart_pg/src/crypto/symmetric/blowfish.dart';
import 'package:dart_pg/src/crypto/symmetric/buffered_cipher.dart';
import 'package:dart_pg/src/crypto/symmetric/camellia.dart';
import 'package:dart_pg/src/crypto/symmetric/camellia_light.dart';
import 'package:dart_pg/src/crypto/symmetric/cast5.dart';
import 'package:dart_pg/src/crypto/symmetric/idea.dart';
import 'package:dart_pg/src/crypto/symmetric/twofish.dart';
import 'package:pointycastle/export.dart';
import 'package:test/test.dart';
import 'package:dart_pg/src/helpers.dart';

void main() {
  group('Block cipher tests', (() {
    test('IDEA test', (() {
      _blockCipherVectorTest(
        0,
        IDEAEngine(),
        _kp('00112233445566778899aabbccddeeff'),
        '000102030405060708090a0b0c0d0e0f',
        'ed732271a7b39f475b4b2b6719f194bf',
      );

      _blockCipherVectorTest(
        1,
        IDEAEngine(),
        _kp('00112233445566778899aabbccddeeff'),
        'f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff',
        'b8bc6ed5c899265d2bcfad1fc6d4287d',
      );
    }));

    test('CAST5 test', (() {
      _blockCipherVectorTest(
        0,
        CAST5Engine(),
        _kp('0123456712345678234567893456789a'),
        '0123456789abcdef',
        '238b4fe5847e44b2',
      );

      _blockCipherVectorTest(
        1,
        CAST5Engine(),
        _kp('01234567123456782345'),
        '0123456789abcdef',
        'eb6a711a2c02271b',
      );

      _blockCipherVectorTest(
        2,
        CAST5Engine(),
        _kp('0123456712'),
        '0123456789abcdef',
        '7ac816d16e9b302e',
      );
    }));

    test('Blowfish test', (() {
      _blockCipherVectorTest(
        0,
        BlowfishEngine(),
        _kp('0000000000000000'),
        '0000000000000000',
        '4ef997456198dd78',
      );

      _blockCipherVectorTest(
        1,
        BlowfishEngine(),
        _kp('ffffffffffffffff'),
        'ffffffffffffffff',
        '51866fd5b85ecb8a',
      );

      _blockCipherVectorTest(
        2,
        BlowfishEngine(),
        _kp('3000000000000000'),
        '1000000000000001',
        '7d856f9a613063f2',
      );

      _blockCipherVectorTest(
        3,
        BlowfishEngine(),
        _kp('1111111111111111'),
        '1111111111111111',
        '2466dd878b963c9d',
      );

      _blockCipherVectorTest(
        4,
        BlowfishEngine(),
        _kp('0123456789abcdef'),
        '1111111111111111',
        '61f9c3802281b096',
      );

      _blockCipherVectorTest(
        5,
        BlowfishEngine(),
        _kp('fedcba9876543210'),
        '0123456789abcdef',
        '0aceab0fc6a0a28d',
      );

      _blockCipherVectorTest(
        6,
        BlowfishEngine(),
        _kp('7ca110454a1a6e57'),
        '01a1d6d039776742',
        '59c68245eb05282b',
      );

      _blockCipherVectorTest(
        7,
        BlowfishEngine(),
        _kp('0131d9619dc1376e'),
        '5cd54ca83def57da',
        'b1b8cc0b250f09a0',
      );
    }));

    test('Twofish test', (() {
      final input = '000102030405060708090a0b0c0d0e0f';

      _blockCipherVectorTest(
        0,
        TwofishEngine(),
        _kp('000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f'),
        input,
        '8ef0272c42db838bcf7b07af0ec30f38',
      );

      _blockCipherVectorTest(
        1,
        TwofishEngine(),
        _kp('000102030405060708090a0b0c0d0e0f1011121314151617'),
        input,
        '95accc625366547617f8be4373d10cd7',
      );

      _blockCipherVectorTest(
        2,
        TwofishEngine(),
        _kp('000102030405060708090a0b0c0d0e0f'),
        input,
        '9fb63337151be9c71306d159ea7afaa4',
      );

      _blockCipherVectorTest(
        3,
        CBCBlockCipher(TwofishEngine()),
        _kpWithIV('0123456789abcdef1234567890abcdef', '1234567890abcdef0123456789abcdef'),
        input,
        'd6bfdbb2090562e960273783127e2658',
      );
    }));

    test('Camellia test', (() {
      _blockCipherVectorTest(
        0,
        CamelliaEngine(),
        _kp('00000000000000000000000000000000'),
        '80000000000000000000000000000000',
        '07923a39eb0a817d1c4d87bdb82d1f1c',
      );

      _blockCipherVectorTest(
        1,
        CamelliaEngine(),
        _kp('80000000000000000000000000000000'),
        '00000000000000000000000000000000',
        '6c227f749319a3aa7da235a9bba05a2c',
      );

      _blockCipherVectorTest(
        2,
        CamelliaEngine(),
        _kp('0123456789abcdeffedcba9876543210'),
        '0123456789abcdeffedcba9876543210',
        '67673138549669730857065648eabe43',
      );

      /// 192 bit
      _blockCipherVectorTest(
        3,
        CamelliaEngine(),
        _kp('0123456789abcdeffedcba98765432100011223344556677'),
        '0123456789abcdeffedcba9876543210',
        'b4993401b3e996f84ee5cee7d79b09b9',
      );

      _blockCipherVectorTest(
        4,
        CamelliaEngine(),
        _kp('000000000000000000000000000000000000000000000000'),
        '00040000000000000000000000000000',
        '9BCA6C88B928C1B0F57F99866583A9BC',
      );

      _blockCipherVectorTest(
        5,
        CamelliaEngine(),
        _kp('949494949494949494949494949494949494949494949494'),
        '636eb22d84b006381235641bcf0308d2',
        '94949494949494949494949494949494',
      );

      /// 256 bit
      _blockCipherVectorTest(
        6,
        CamelliaEngine(),
        _kp('0123456789abcdeffedcba987654321000112233445566778899aabbccddeeff'),
        '0123456789abcdeffedcba9876543210',
        '9acc237dff16d76c20ef7c919e3a7509',
      );

      _blockCipherVectorTest(
        7,
        CamelliaEngine(),
        _kp('4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A'),
        '057764fe3a500edbd988c5c3b56cba9a',
        '4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a',
      );

      _blockCipherVectorTest(
        8,
        CamelliaEngine(),
        _kp('0303030303030303030303030303030303030303030303030303030303030303'),
        '7968b08aba92193f2295121ef8d75c8a',
        '03030303030303030303030303030303',
      );
    }));

    test('Camellia light test', (() {
      _blockCipherVectorTest(
        0,
        CamelliaLightEngine(),
        _kp('00000000000000000000000000000000'),
        '80000000000000000000000000000000',
        '07923a39eb0a817d1c4d87bdb82d1f1c',
      );

      _blockCipherVectorTest(
        1,
        CamelliaLightEngine(),
        _kp('80000000000000000000000000000000'),
        '00000000000000000000000000000000',
        '6c227f749319a3aa7da235a9bba05a2c',
      );

      _blockCipherVectorTest(
        2,
        CamelliaLightEngine(),
        _kp('0123456789abcdeffedcba9876543210'),
        '0123456789abcdeffedcba9876543210',
        '67673138549669730857065648eabe43',
      );

      /// 192 bit
      _blockCipherVectorTest(
        3,
        CamelliaLightEngine(),
        _kp('0123456789abcdeffedcba98765432100011223344556677'),
        '0123456789abcdeffedcba9876543210',
        'b4993401b3e996f84ee5cee7d79b09b9',
      );

      _blockCipherVectorTest(
        4,
        CamelliaLightEngine(),
        _kp('000000000000000000000000000000000000000000000000'),
        '00040000000000000000000000000000',
        '9BCA6C88B928C1B0F57F99866583A9BC',
      );

      _blockCipherVectorTest(
        5,
        CamelliaLightEngine(),
        _kp('949494949494949494949494949494949494949494949494'),
        '636eb22d84b006381235641bcf0308d2',
        '94949494949494949494949494949494',
      );

      /// 256 bit
      _blockCipherVectorTest(
        6,
        CamelliaLightEngine(),
        _kp('0123456789abcdeffedcba987654321000112233445566778899aabbccddeeff'),
        '0123456789abcdeffedcba9876543210',
        '9acc237dff16d76c20ef7c919e3a7509',
      );

      _blockCipherVectorTest(
        7,
        CamelliaLightEngine(),
        _kp('4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A'),
        '057764fe3a500edbd988c5c3b56cba9a',
        '4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a',
      );

      _blockCipherVectorTest(
        8,
        CamelliaLightEngine(),
        _kp('0303030303030303030303030303030303030303030303030303030303030303'),
        '7968b08aba92193f2295121ef8d75c8a',
        '03030303030303030303030303030303',
      );
    }));
  }));
}

KeyParameter _kp(String key) {
  return KeyParameter(key.hexToBytes());
}

ParametersWithIV<KeyParameter> _kpWithIV(String key, String iv) {
  return ParametersWithIV(_kp(key), iv.hexToBytes());
}

void _blockCipherVectorTest(int id, BlockCipher engine, CipherParameters params, String input, String output) {
  final inBytes = input.hexToBytes();
  final outBytes = output.hexToBytes();

  final cipher = BufferedCipher(engine);
  cipher.init(true, params);
  expect(outBytes, equals(cipher.process(inBytes)), reason: '${cipher.algorithmName} test $id did not match output');

  cipher.init(false, params);
  expect(inBytes, equals(cipher.process(outBytes)), reason: '${cipher.algorithmName} test $id did not match input');
}
