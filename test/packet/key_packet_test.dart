import 'dart:convert';

import 'package:dart_pg/src/crypto/math/big_int.dart';
import 'package:dart_pg/src/enum/key_algorithm.dart';
import 'package:dart_pg/src/enum/s2k_usage.dart';
import 'package:dart_pg/src/enum/symmetric_algorithm.dart';

import 'package:dart_pg/src/packet/key/dsa_public_params.dart';
import 'package:dart_pg/src/packet/key/dsa_secret_params.dart';
import 'package:dart_pg/src/packet/key/ec_secret_params.dart';
import 'package:dart_pg/src/packet/key/ecdh_public_params.dart';
import 'package:dart_pg/src/packet/key/ecdsa_public_params.dart';
import 'package:dart_pg/src/packet/key/elgamal_public_params.dart';
import 'package:dart_pg/src/packet/key/elgamal_secret_params.dart';
import 'package:dart_pg/src/packet/key/rsa_public_params.dart';
import 'package:dart_pg/src/packet/key/rsa_secret_params.dart';
import 'package:dart_pg/src/packet/public_key.dart';
import 'package:dart_pg/src/packet/public_subkey.dart';
import 'package:dart_pg/src/packet/secret_key.dart';
import 'package:dart_pg/src/packet/secret_subkey.dart';
import 'package:test/test.dart';

import '../test_data.dart';

void main() {
  group('public key packet', () {
    test('rsa test', () {
      final publicKey = PublicKeyPacket.fromByteData(
          base64.decode(rsaPublicKeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      expect(publicKey.fingerprint, '44ebf9e6dc6647d61c556de27a686b5a10709559');
      expect(publicKey.algorithm, KeyAlgorithm.rsaEncryptSign);

      final publicSubkey = PublicSubkeyPacket.fromByteData(
          base64.decode(rsaPublicSubkeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      expect(publicSubkey.fingerprint, '8da510f6630e613b4e4b627a1500062542172d9c');
      expect(publicSubkey.algorithm, KeyAlgorithm.rsaEncryptSign);
    });

    test('dsa elgamal test', () {
      final publicKey = PublicKeyPacket.fromByteData(
          base64.decode(dsaPublicKeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      expect(publicKey.fingerprint, 'd7143f20460ecd568e1ed6cd76c0caec8769a8a7');
      expect(publicKey.algorithm, KeyAlgorithm.dsa);

      final publicSubkey = PublicSubkeyPacket.fromByteData(
          base64.decode(elgamalPublicSubkeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      expect(publicSubkey.fingerprint, 'cabe81ea1ab72a92e1c0c65c16e7d1ac9c6620c8');
      expect(publicSubkey.algorithm, KeyAlgorithm.elgamal);
    });

    test('ecc test', () {
      final publicKey = PublicKeyPacket.fromByteData(
          base64.decode(ecdsaPublicKeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      expect(publicKey.fingerprint, '2d84ae177c1bed087cb9903cdeefcc766e22aedf');
      expect(publicKey.algorithm, KeyAlgorithm.ecdsa);

      final publicSubkey = PublicSubkeyPacket.fromByteData(
          base64.decode(ecdhPublicSubkeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      expect(publicSubkey.fingerprint, '7a2da9aa8c176411d6ed1d2f24373aaf7d84b6be');
      expect(publicSubkey.algorithm, KeyAlgorithm.ecdh);
    });
  });

  group('secret key packet', () {
    test('rsa test', (() {
      final secretKey = SecretKeyPacket.fromByteData(
          base64.decode(rsaSecretKeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      final publicParams = secretKey.publicKey.publicParams as RSAPublicParams;
      final secretParams = secretKey.decrypt(passphrase).secretParams as RSASecretParams;

      expect(secretKey.fingerprint, '44ebf9e6dc6647d61c556de27a686b5a10709559');
      expect(secretKey.algorithm, KeyAlgorithm.rsaEncryptSign);
      expect(secretParams.pInv, secretParams.primeP.modInverse(secretParams.primeQ));
      expect(publicParams.modulus, secretParams.modulus);

      final secretSubkey = SecretSubkeyPacket.fromByteData(
          base64.decode(rsaSecretSubkeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      final subkeyPublicParams = secretSubkey.publicKey.publicParams as RSAPublicParams;
      final subkeySecretParams = secretSubkey.decrypt(passphrase).secretParams as RSASecretParams;

      expect(secretSubkey.fingerprint, '8da510f6630e613b4e4b627a1500062542172d9c');
      expect(secretSubkey.algorithm, KeyAlgorithm.rsaEncryptSign);
      expect(subkeySecretParams.pInv, subkeySecretParams.primeP.modInverse(subkeySecretParams.primeQ));
      expect(subkeyPublicParams.modulus, subkeySecretParams.modulus);
    }));

    test('dsa elgamal test', () {
      final secretKey = SecretKeyPacket.fromByteData(
          base64.decode(dsaSecretKeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      final publicParams = secretKey.publicKey.publicParams as DSAPublicParams;
      final secretParams = secretKey.decrypt(passphrase).secretParams as DSASecretParams;

      expect(secretKey.fingerprint, 'd7143f20460ecd568e1ed6cd76c0caec8769a8a7');
      expect(secretKey.algorithm, KeyAlgorithm.dsa);
      expect(
          publicParams.publicExponent, publicParams.generator.modPow(secretParams.secretExponent, publicParams.prime));

      final secretSubkey = SecretSubkeyPacket.fromByteData(
          base64.decode(elgamalSecretKeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      final subkeyPublicParams = secretSubkey.publicKey.publicParams as ElGamalPublicParams;
      final subkeySecretParams = secretSubkey.decrypt(passphrase).secretParams as ElGamalSecretParams;

      expect(secretSubkey.fingerprint, 'cabe81ea1ab72a92e1c0c65c16e7d1ac9c6620c8');
      expect(secretSubkey.algorithm, KeyAlgorithm.elgamal);
      expect(subkeyPublicParams.publicExponent,
          subkeyPublicParams.generator.modPow(subkeySecretParams.secretExponent, subkeyPublicParams.prime));
    });

    test('ecc test', () {
      final secretKey = SecretKeyPacket.fromByteData(
          base64.decode(ecdsaSecretKeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      final publicParams = secretKey.publicKey.publicParams as ECDSAPublicParams;
      final secretParams = secretKey.decrypt(passphrase).secretParams as ECSecretParams;

      expect(secretKey.fingerprint, '2d84ae177c1bed087cb9903cdeefcc766e22aedf');
      expect(secretKey.algorithm, KeyAlgorithm.ecdsa);

      final qPoint = publicParams.parameters.curve.decodePoint(publicParams.q.toUnsignedBytes());
      expect(qPoint, publicParams.parameters.G * secretParams.d);

      final secretSubkey = SecretSubkeyPacket.fromByteData(
          base64.decode(ecdhSecretKeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      final subkeyPublicParams = secretSubkey.publicKey.publicParams as ECDHPublicParams;
      final subkeySecretParams = secretSubkey.decrypt(passphrase).secretParams as ECSecretParams;

      expect(secretSubkey.fingerprint, '7a2da9aa8c176411d6ed1d2f24373aaf7d84b6be');
      expect(secretSubkey.algorithm, KeyAlgorithm.ecdh);

      final subkeyQPoint = publicParams.parameters.curve.decodePoint(subkeyPublicParams.q.toUnsignedBytes());
      expect(subkeyQPoint, subkeyPublicParams.parameters.G * subkeySecretParams.d);
    });

    test('encrypt test', (() {
      final secretKey = SecretKeyPacket.fromByteData(
          base64.decode(secretKeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      final publicParams = secretKey.publicKey.publicParams as RSAPublicParams;
      final secretParams = secretKey.secretParams as RSASecretParams;

      expect(secretKey.fingerprint, '93456c517e3eddb679bb510c2213de9391374950');
      expect(secretKey.algorithm, KeyAlgorithm.rsaEncryptSign);
      expect(secretParams.pInv, secretParams.primeP.modInverse(secretParams.primeQ));
      expect(publicParams.modulus, secretParams.modulus);

      expect(secretKey.isDecrypted, true);
      expect(secretKey.s2kUsage, S2kUsage.none);
      expect(secretKey.symmetric, SymmetricAlgorithm.plaintext);
      expect(secretKey.iv, isNull);
      expect(secretKey.s2k, isNull);

      final encryptedKey = secretKey.encrypt(passphrase);
      expect(encryptedKey.fingerprint, secretKey.fingerprint);
      expect(encryptedKey.secretParams, secretKey.secretParams);

      expect(encryptedKey.s2kUsage, S2kUsage.sha1);
      expect(encryptedKey.symmetric, SymmetricAlgorithm.aes256);
      expect(encryptedKey.iv, isNotNull);
      expect(encryptedKey.s2k, isNotNull);

      final decryptedKey = SecretKeyPacket.fromByteData(encryptedKey.toByteData()).decrypt(passphrase);
      final decryptedParams = decryptedKey.secretParams as RSASecretParams;

      expect(decryptedKey.fingerprint, secretKey.fingerprint);
      expect(decryptedParams.privateExponent, secretParams.privateExponent);
      expect(decryptedParams.primeP, secretParams.primeP);
      expect(decryptedParams.primeQ, secretParams.primeQ);
      expect(decryptedParams.pInv, secretParams.pInv);

      final secretSubkey = SecretSubkeyPacket.fromByteData(
          base64.decode(secretSubkeyPacket.replaceAll(RegExp(r'\r?\n', multiLine: true), '')));
      final subkeyPublicParams = secretSubkey.publicKey.publicParams as RSAPublicParams;
      final subkeySecretParams = secretSubkey.secretParams as RSASecretParams;

      expect(secretSubkey.fingerprint, 'c503083b150f47a5d6fdb661c865808a31866def');
      expect(secretSubkey.algorithm, KeyAlgorithm.rsaEncryptSign);
      expect(subkeySecretParams.pInv, subkeySecretParams.primeP.modInverse(subkeySecretParams.primeQ));
      expect(subkeyPublicParams.modulus, subkeySecretParams.modulus);

      expect(secretSubkey.isDecrypted, true);
      expect(secretSubkey.s2kUsage, S2kUsage.none);
      expect(secretSubkey.symmetric, SymmetricAlgorithm.plaintext);
      expect(secretSubkey.iv, isNull);
      expect(secretSubkey.s2k, isNull);

      final subkeyEncryptedKey = secretSubkey.encrypt(passphrase);
      expect(subkeyEncryptedKey.fingerprint, secretSubkey.fingerprint);
      expect(subkeyEncryptedKey.secretParams, secretSubkey.secretParams);

      expect(subkeyEncryptedKey.s2kUsage, S2kUsage.sha1);
      expect(subkeyEncryptedKey.symmetric, SymmetricAlgorithm.aes256);
      expect(subkeyEncryptedKey.iv, isNotNull);
      expect(subkeyEncryptedKey.s2k, isNotNull);

      final subkeyDecryptedKey = SecretKeyPacket.fromByteData(subkeyEncryptedKey.toByteData()).decrypt(passphrase);
      final subkeyDecryptedParams = subkeyDecryptedKey.secretParams as RSASecretParams;

      expect(subkeyDecryptedKey.fingerprint, secretSubkey.fingerprint);
      expect(subkeyDecryptedParams.privateExponent, subkeySecretParams.privateExponent);
      expect(subkeyDecryptedParams.primeP, subkeySecretParams.primeP);
      expect(subkeyDecryptedParams.primeQ, subkeySecretParams.primeQ);
      expect(subkeyDecryptedParams.pInv, subkeySecretParams.pInv);
    }));
  });
}
