import 'dart:convert';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/src/platform_check/platform_check.dart';
import "package:pointycastle/export.dart";

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
    SecureRandom secureRandom,
    {int bitLength = 2048}) {
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
        secureRandom));

  final pair = keyGen.generateKeyPair();

  final myPublic = pair.publicKey as RSAPublicKey;
  final myPrivate = pair.privateKey as RSAPrivateKey;

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
}

SecureRandom exampleSecureRandom() {
  final secureRandom = FortunaRandom()
    ..seed(KeyParameter(
        Platform.instance.platformEntropySource().getBytes(32)));
  return secureRandom;
}


Uint8List rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
  final encryptor = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

  return _processInBlocks(encryptor, dataToEncrypt);
}

Uint8List rsaDecrypt(RSAPrivateKey myPrivate, Uint8List cipherText) {
  final decryptor = OAEPEncoding(RSAEngine())
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(myPrivate)); // false=decrypt

  return _processInBlocks(decryptor, cipherText);
}


Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
  final numBlocks = input.length ~/ engine.inputBlockSize +
      ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

  final output = Uint8List(numBlocks * engine.outputBlockSize);

  var inputOffset = 0;
  var outputOffset = 0;
  while (inputOffset < input.length) {
    final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
        ? engine.inputBlockSize
        : input.length - inputOffset;

    outputOffset += engine.processBlock(
        input, inputOffset, chunkSize, output, outputOffset);

    inputOffset += chunkSize;
  }

  return (output.length == outputOffset)
      ? output
      : output.sublist(0, outputOffset);
}


String encodePrivateKeyToPem(RSAPrivateKey privateKey) {
  final topLevel = ASN1Sequence();
  topLevel.add(ASN1Integer(BigInt.from(0)));
  topLevel.add(ASN1Integer(privateKey.n!));
  topLevel.add(ASN1Integer(BigInt.from(65537)));
  topLevel.add(ASN1Integer(privateKey.privateExponent!));
  topLevel.add(ASN1Integer(privateKey.p!));
  topLevel.add(ASN1Integer(privateKey.q!));
  topLevel.add(ASN1Integer(privateKey.privateExponent! % (privateKey.p! - BigInt.one)));
  topLevel.add(ASN1Integer(privateKey.privateExponent! % (privateKey.q! - BigInt.one)));
  topLevel.add(ASN1Integer(privateKey.q!.modInverse(privateKey.p!)));

  final dataBase64 = base64.encode(topLevel.encodedBytes);
  return "-----BEGIN PRIVATE KEY-----\r\n$dataBase64\r\n-----END PRIVATE KEY-----";
}

String encodePublicKeyToPem(RSAPublicKey publicKey) {
  final topLevel = ASN1Sequence();
  topLevel.add(ASN1Integer(publicKey.modulus!));
  topLevel.add(ASN1Integer(publicKey.exponent!));

  final dataBase64 = base64.encode(topLevel.encodedBytes);
  return "-----BEGIN PUBLIC KEY-----\r\n$dataBase64\r\n-----END PUBLIC KEY-----";
}

//parsePrivateKeyFromPem
RSAPrivateKey parsePrivateKeyFromPem(String pem) {
  final data = pem.split(RegExp(r'\r?\n'));
  final raw = base64.decode(data.sublist(1, data.length - 1).join(''));
  final topLevel = ASN1Sequence.fromBytes(raw);

  final n = topLevel.elements[1] as ASN1Integer;
  final d = topLevel.elements[3] as ASN1Integer;
  final p = topLevel.elements[4] as ASN1Integer;
  final q = topLevel.elements[5] as ASN1Integer;

  return RSAPrivateKey(
      n.valueAsBigInteger, d.valueAsBigInteger, p.valueAsBigInteger, q.valueAsBigInteger);
}

RSAPublicKey parsePublicKeyFromPem(String pem) {
  final data = pem.split(RegExp(r'\r?\n'));
  final raw = base64.decode(data.sublist(1, data.length - 1).join(''));
  final topLevel = ASN1Sequence.fromBytes(raw);

  final modulus = topLevel.elements[0] as ASN1Integer;
  final exponent = topLevel.elements[1] as ASN1Integer;

  return RSAPublicKey(modulus.valueAsBigInteger, exponent.valueAsBigInteger);
}

