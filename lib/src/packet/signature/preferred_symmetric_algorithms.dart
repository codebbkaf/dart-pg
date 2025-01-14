// Copyright 2022-present by Nguyen Van Nguyen <nguyennv1981@gmail.com>. All rights reserved.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.

import 'dart:typed_data';

import '../../enum/signature_subpacket_type.dart';
import '../../enum/symmetric_algorithm.dart';
import '../signature_subpacket.dart';

class PreferredSymmetricAlgorithms extends SignatureSubpacket {
  PreferredSymmetricAlgorithms(
    final Uint8List data, {
    super.critical,
    super.isLong,
  }) : super(SignatureSubpacketType.preferredSymmetricAlgorithms, data);

  List<SymmetricAlgorithm> get preferences => data
      .map((pref) =>
          SymmetricAlgorithm.values.firstWhere((alg) => alg.value == pref))
      .toList(growable: false);
}
