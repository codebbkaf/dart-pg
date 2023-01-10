import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:test/test.dart';
import 'package:dart_pg/src/helpers.dart';
import 'package:dart_pg/src/crypto/cipher/des.dart';

void main() {
  group('cipher tests', (() {
    test('IDEA test', (() {}));

    test('Triple DES test', (() {}));

    test('CAST5 test', (() {}));

    test('Blowfish test', (() {}));

    /// DES tester - vectors from <a href=https://www.itl.nist.gov/fipspubs/fip81.htm>FIPS 81</a>
    test('DES test', (() {
      final input1 = utf8.encoder.convert('Now is the time for all ').toHexadecimal();
      final input2 = utf8.encoder.convert('Now is the').toHexadecimal();

      // final input3 = '4e6f7720697320746865aabbcc';
      final key = '0123456789abcdef';
      final iv = '1234567890abcdef';

      _blockCipherVectorTest(
        0,
        DESEngine(),
        _kp(key),
        input1,
        '3fa40e8a984d48156a271787ab8883f9893d51ec4b563b53',
      );

      _blockCipherVectorTest(
        1,
        CBCBlockCipher(DESEngine()),
        _kpWithIV(key, iv),
        input1,
        'e5c7cdde872bf27c43e934008c389c0f683788499a7c05f6',
      );

      _blockCipherVectorTest(
        2,
        CFBBlockCipher(DESEngine(), 8),
        _kpWithIV(key, iv),
        input2,
        'f31fda07011462ee187f',
      );

      _blockCipherVectorTest(
        3,
        CFBBlockCipher(DESEngine(), 64),
        _kpWithIV(key, iv),
        input1,
        'f3096249c7f46e51a69e839b1a92f78403467133898ea622',
      );

      _blockCipherVectorTest(
        4,
        OFBBlockCipher(DESEngine(), 8),
        _kpWithIV(key, iv),
        input2,
        'f34a2850c9c64985d684',
      );
    }));

    test('Twofish test', (() {}));
  }));
}

KeyParameter _kp(String src) {
  return KeyParameter(src.hexToBytes());
}

ParametersWithIV<KeyParameter> _kpWithIV(String src, String iv) {
  return ParametersWithIV(KeyParameter(src.hexToBytes()), iv.hexToBytes());
}

void _blockCipherVectorTest(int id, BlockCipher cipher, CipherParameters parameters, String input, String output) {
  final inBytes = input.hexToBytes();
  final outBytes = output.hexToBytes();
  var out = Uint8List(inBytes.length);

  cipher.init(true, parameters);
  var offset = 0;
  while (offset < inBytes.length) {
    offset += cipher.processBlock(inBytes, offset, out, offset);
  }
  expect(outBytes, equals(out), reason: '${cipher.algorithmName} test $id did not match output');

  cipher.init(false, parameters);
  out = Uint8List(outBytes.length);
  offset = 0;
  while (offset < outBytes.length) {
    offset += cipher.processBlock(outBytes, offset, out, offset);
  }
  expect(inBytes, equals(out), reason: '${cipher.algorithmName} test $id did not match input');
}
