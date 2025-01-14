// Copyright 2022-present by Nguyen Van Nguyen <nguyennv1981@gmail.com>. All rights reserved.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.

import 'dart:collection';
import 'dart:typed_data';

import '../enum/packet_tag.dart';
import 'compressed_data.dart';
import 'contained_packet.dart';
import 'literal_data.dart';
import 'marker_packet.dart';
import 'modification_detection_code.dart';
import 'one_pass_signature.dart';
import 'packet_reader.dart';
import 'public_key.dart';
import 'public_key_encrypted_session_key.dart';
import 'public_subkey.dart';
import 'secret_key.dart';
import 'secret_subkey.dart';
import 'signature_packet.dart';
import 'sym_encrypted_integrity_protected_data.dart';
import 'sym_encrypted_session_key.dart';
import 'sym_encrypted_data.dart';
import 'trust_packet.dart';
import 'user_attribute.dart';
import 'user_id.dart';

/// This class represents a list of openpgp packets.
class PacketList extends ListBase<ContainedPacket> {
  final List<ContainedPacket> packets;

  PacketList(final Iterable<ContainedPacket> packets)
      : packets = packets.toList(
          growable: false,
        );

  factory PacketList.packetDecode(final Uint8List bytes) {
    final packets = <ContainedPacket>[];
    var offset = 0;
    while (offset < bytes.length) {
      final reader = PacketReader.read(bytes, offset);
      offset = reader.offset;

      switch (reader.tag) {
        case PacketTag.publicKeyEncryptedSessionKey:
          packets.add(
            PublicKeyEncryptedSessionKeyPacket.fromByteData(reader.data),
          );
          break;
        case PacketTag.signature:
          packets.add(SignaturePacket.fromByteData(reader.data));
          break;
        case PacketTag.symEncryptedSessionKey:
          packets.add(SymEncryptedSessionKeyPacket.fromByteData(reader.data));
          break;
        case PacketTag.onePassSignature:
          packets.add(OnePassSignaturePacket.fromByteData(reader.data));
          break;
        case PacketTag.secretKey:
          packets.add(SecretKeyPacket.fromByteData(reader.data));
          break;
        case PacketTag.publicKey:
          packets.add(PublicKeyPacket.fromByteData(reader.data));
          break;
        case PacketTag.secretSubkey:
          packets.add(SecretSubkeyPacket.fromByteData(reader.data));
          break;
        case PacketTag.compressedData:
          packets.add(CompressedDataPacket.fromByteData(reader.data));
          break;
        case PacketTag.symEncryptedData:
          packets.add(SymEncryptedDataPacket.fromByteData(reader.data));
          break;
        case PacketTag.marker:
          packets.add(MarkerPacket());
          break;
        case PacketTag.literalData:
          packets.add(LiteralDataPacket.fromByteData(reader.data));
          break;
        case PacketTag.trust:
          packets.add(TrustPacket.fromByteData(reader.data));
          break;
        case PacketTag.userID:
          packets.add(UserIDPacket.fromByteData(reader.data));
          break;
        case PacketTag.publicSubkey:
          packets.add(PublicSubkeyPacket.fromByteData(reader.data));
          break;
        case PacketTag.userAttribute:
          packets.add(UserAttributePacket.fromByteData(reader.data));
          break;
        case PacketTag.symEncryptedIntegrityProtectedData:
          packets.add(
            SymEncryptedIntegrityProtectedDataPacket.fromByteData(reader.data),
          );
          break;
        case PacketTag.modificationDetectionCode:
          packets.add(
            ModificationDetectionCodePacket.fromByteData(reader.data),
          );
          break;
        case PacketTag.aeadEncryptedData:
          break;
      }
    }
    return PacketList(packets);
  }

  Uint8List encode() => Uint8List.fromList(
        packets
            .map((packet) => packet.encode())
            .expand((byte) => byte)
            .toList(growable: false),
      );

  PacketList filterByTags([final List<PacketTag> tags = const []]) {
    if (tags.isNotEmpty) {
      return PacketList(packets.where((packet) => tags.contains(packet.tag)));
    }
    return this;
  }

  @override
  int get length => packets.length;

  @override
  ContainedPacket operator [](int index) => packets[index];

  @override
  void operator []=(int index, ContainedPacket packet) {
    packets[index] = packet;
  }

  @override
  set length(int newLength) {
    packets.length = newLength;
  }
}
