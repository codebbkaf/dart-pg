// Copyright 2022-present by Nguyen Van Nguyen <nguyennv1981@gmail.com>. All rights reserved.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.

import 'dart:typed_data';

import '../../enums.dart';
import '../signature_subpacket.dart';

/// RFC 4880, Section 5.2.3.25 - Signature Target subpacket.
class SignatureTarget extends SignatureSubpacket {
  SignatureTarget(Uint8List data, {super.critical, super.isLongLength})
      : super(SignatureSubpacketType.signatureTarget, data);

  factory SignatureTarget.fromHashData(
    KeyAlgorithm keyAlgorithm,
    HashAlgorithm hashAlgorithm,
    Uint8List hashData, {
    bool critical = false,
  }) =>
      SignatureTarget(_hashDataBytes(keyAlgorithm, hashAlgorithm, hashData), critical: critical);

  KeyAlgorithm get keyAlgorithm => KeyAlgorithm.values.firstWhere((alg) => alg.value == data[0]);

  HashAlgorithm get hashAlgorithm => HashAlgorithm.values.firstWhere((alg) => alg.value == data[1]);

  Uint8List get hashData => data.sublist(2);

  static Uint8List _hashDataBytes(
    KeyAlgorithm keyAlgorithm,
    HashAlgorithm hashAlgorithm,
    Uint8List hashData,
  ) =>
      Uint8List.fromList([keyAlgorithm.value, hashAlgorithm.value, ...hashData]);
}
