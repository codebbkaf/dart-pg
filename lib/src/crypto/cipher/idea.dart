// Copyright 2022-present by Nguyen Van Nguyen <nguyennv1981@gmail.com>. All rights reserved.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.

import 'package:pointycastle/api.dart';

import 'dart:typed_data';

import '../../byte_utils.dart';
import 'base_cipher.dart';

/// A class that provides a basic International Data Encryption Algorithm (IDEA) engine.
class IDEAEngine extends BaseCipher {
  static const _mask = 0xffff;
  static const _base = 0x10001;

  static const _blockSize = 8;

  late Uint8List _workingKey;

  @override
  String get algorithmName => 'IDEA';

  @override
  int get blockSize => _blockSize;

  @override
  void init(bool forEncryption, CipherParameters? params) {
    if (params is KeyParameter) {
      _workingKey = _generateWorkingKey(forEncryption, params.key);
    } else {
      throw ArgumentError('Invalid parameter passed to $algorithmName init - ${params.runtimeType}');
    }
  }

  @override
  int processBlock(Uint8List inp, int inpOff, Uint8List out, int outOff) {
    if (_workingKey.isEmpty) {
      throw StateError('$algorithmName not initialised');
    }
    if ((inpOff + blockSize) > inp.length) {
      throw ArgumentError('input buffer too short');
    }
    if ((outOff + blockSize) > out.length) {
      throw ArgumentError('output buffer too short');
    }

    _ideaFunc(_workingKey, inp, inpOff, out, outOff);

    return _blockSize;
  }

  @override
  void reset() {}

  Uint8List _generateWorkingKey(bool forEncryption, Uint8List key) {
    if (forEncryption) {
      return _expandKey(key);
    } else {
      return _invertKey(_expandKey(key));
    }
  }

  Uint8List _expandKey(Uint8List uKey) {
    final key = List.filled(52, 0);
    final Uint8List tmpKey;
    if (uKey.length < 16) {
      tmpKey = Uint8List(16);
      tmpKey.setAll(tmpKey.length - uKey.length, uKey.sublist(0));
    } else {
      tmpKey = uKey;
    }

    for (var i = 0; i < 8; i++) {
      key[i] = ByteUtils.bytesToIn16(tmpKey.sublist(i * 2));
    }
    for (var i = 8; i < 52; i++) {
      if ((i & 7) < 6) {
        key[i] = ((key[i - 7] & 127) << 9 | key[i - 6] >> 7) & _mask;
      } else if ((i & 7) == 6) {
        key[i] = ((key[i - 7] & 127) << 9 | key[i - 14] >> 7) & _mask;
      } else {
        key[i] = ((key[i - 15] & 127) << 9 | key[i - 14] >> 7) & _mask;
      }
    }
    return Uint8List.fromList(key);
  }

  Uint8List _invertKey(Uint8List inKey) {
    int t1, t2, t3, t4;
    var p = 52;
    final key = List.filled(52, 0);
    var inOff = 0;

    t1 = _mulInv(inKey[inOff++]);
    t2 = _addInv(inKey[inOff++]);
    t3 = _addInv(inKey[inOff++]);
    t4 = _mulInv(inKey[inOff++]);
    key[--p] = t4;
    key[--p] = t3;
    key[--p] = t2;
    key[--p] = t1;

    for (var round = 1; round < 8; round++) {
      t1 = inKey[inOff++];
      t2 = inKey[inOff++];
      key[--p] = t2;
      key[--p] = t1;

      t1 = _mulInv(inKey[inOff++]);
      t2 = _addInv(inKey[inOff++]);
      t3 = _addInv(inKey[inOff++]);
      t4 = _mulInv(inKey[inOff++]);
      key[--p] = t4;
      key[--p] = t2;
      key[--p] = t3;
      key[--p] = t1;
    }

    t1 = inKey[inOff++];
    t2 = inKey[inOff++];
    key[--p] = t2;
    key[--p] = t1;

    t1 = _mulInv(inKey[inOff++]);
    t2 = _addInv(inKey[inOff++]);
    t3 = _addInv(inKey[inOff++]);
    t4 = _mulInv(inKey[inOff]);
    key[--p] = t4;
    key[--p] = t3;
    key[--p] = t2;
    key[--p] = t1;

    return Uint8List.fromList(key);
  }

  int _mulInv(int x) {
    int t0, t1, q, y;

    if (x < 2) {
      return x;
    }

    t0 = 1;
    t1 = _base ~/ x;
    y = _base % x;

    while (y != 1) {
      q = (x / y) as int;
      x = x % y;
      t0 = (t0 + (t1 * q)) & _mask;
      if (x == 1) {
        return t0;
      }
      q = (y / x) as int;
      y = y % x;
      t1 = (t1 + (t0 * q)) & _mask;
    }

    return (1 - t1) & _mask;
  }

  int _addInv(int x) {
    return (0 - x) & _mask;
  }

  void _ideaFunc(Uint8List workingKey, Uint8List inp, int inpOff, Uint8List out, int outOff) {
    int x0, x1, x2, x3, t0, t1;
    var keyOff = 0;

    x0 = ByteUtils.bytesToIn16(inp.sublist(inpOff));
    x1 = ByteUtils.bytesToIn16(inp.sublist(inpOff + 2));
    x2 = ByteUtils.bytesToIn16(inp.sublist(inpOff + 4));
    x3 = ByteUtils.bytesToIn16(inp.sublist(inpOff + 6));

    for (var round = 0; round < 8; round++) {
      x0 = _mul(x0, workingKey[keyOff++]);
      x1 += workingKey[keyOff++];
      x1 &= _mask;
      x2 += workingKey[keyOff++];
      x2 &= _mask;
      x3 = _mul(x3, workingKey[keyOff++]);

      t0 = x1;
      t1 = x2;
      x2 ^= x0;
      x1 ^= x3;

      x2 = _mul(x2, workingKey[keyOff++]);
      x1 += x2;
      x1 &= _mask;

      x1 = _mul(x1, workingKey[keyOff++]);
      x2 += x1;
      x2 &= _mask;

      x0 ^= x1;
      x3 ^= x2;
      x1 ^= t1;
      x2 ^= t0;
    }

    out.setAll(outOff, ByteUtils.int16Bytes(_mul(x0, workingKey[keyOff++])));
    out.setAll(outOff + 2, ByteUtils.int16Bytes(x2 + workingKey[keyOff++]));
    out.setAll(outOff + 4, ByteUtils.int16Bytes(x1 + workingKey[keyOff++]));
    out.setAll(outOff + 6, ByteUtils.int16Bytes(_mul(x3, workingKey[keyOff])));
  }

  int _mul(int x, int y) {
    if (x == 0) {
      x = (_base - y);
    } else if (y == 0) {
      x = (_base - x);
    } else {
      int p = x * y;

      y = p & _mask;
      x = p >>> 16;
      x = y - x + ((y < x) ? 1 : 0);
    }

    return x & _mask;
  }
}