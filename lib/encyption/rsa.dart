import 'dart:convert';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'dart:math';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(SecureRandom secureRandom, {int bitLength = 2048}) {
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
  final secureRandom = FortunaRandom();
  final seedSource = Random.secure();
  final seed = List<int>.generate(32, (_) => seedSource.nextInt(256));
  secureRandom.seed(KeyParameter(Uint8List.fromList(seed)));
  return secureRandom;
}

Uint8List rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
  final encryptor = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic));

  return _processInBlocks(encryptor, dataToEncrypt);
}

Uint8List rsaDecrypt(RSAPrivateKey myPrivate, Uint8List cipherText) {
  final decryptor = OAEPEncoding(RSAEngine())
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(myPrivate));

  return _processInBlocks(decryptor, cipherText);
}

Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
  final inputBlockSize = engine.inputBlockSize;
  final outputBlockSize = engine.outputBlockSize;
  final numBlocks = (input.length / inputBlockSize).ceil();

  final output = Uint8List(numBlocks * outputBlockSize);
  var inputOffset = 0;
  var outputOffset = 0;

  while (inputOffset < input.length) {
    final chunkSize = (input.length - inputOffset > inputBlockSize)
        ? inputBlockSize
        : input.length - inputOffset;

    outputOffset += engine.processBlock(
        input, inputOffset, chunkSize, output, outputOffset);
    inputOffset += chunkSize;
  }

  return output.sublist(0, outputOffset);
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

RSAPrivateKey parsePrivateKeyFromPem(String pem) {
  final data = pem.split(RegExp(r'\r?\n')).where((line) => !line.contains('-----')).join('');
  final raw = base64.decode(data);
  final topLevel = ASN1Sequence.fromBytes(raw);

  final n = (topLevel.elements[1] as ASN1Integer).valueAsBigInteger;
  final d = (topLevel.elements[3] as ASN1Integer).valueAsBigInteger;
  final p = (topLevel.elements[4] as ASN1Integer).valueAsBigInteger;
  final q = (topLevel.elements[5] as ASN1Integer).valueAsBigInteger;

  return RSAPrivateKey(n, d, p, q);
}

RSAPublicKey parsePublicKeyFromPem(String pem) {
  final data = pem.split(RegExp(r'\r?\n')).where((line) => !line.contains('-----')).join('');
  final raw = base64.decode(data);
  final topLevel = ASN1Sequence.fromBytes(raw);

  final modulus = (topLevel.elements[0] as ASN1Integer).valueAsBigInteger;
  final exponent = (topLevel.elements[1] as ASN1Integer).valueAsBigInteger;

  return RSAPublicKey(modulus, exponent);
}
Future<Database> initDatabase() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'chat_database.db');

  return openDatabase(
    path,
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE messages(id INTEGER PRIMARY KEY, content TEXT, mediaPath TEXT)',
      );
    },
    version: 1,
  );
}

Future<void> saveMessage(String message, {String? mediaPath}) async {
  final db = await initDatabase();
  await db.insert(
    'messages',
    {'content': message, 'mediaPath': mediaPath},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Map<String, dynamic>>> retrieveMessages() async {
  final db = await initDatabase();
  return db.query('messages');
}

Future<void> exportChatHistory() async {
  final pdf = pw.Document();
  final messages = await retrieveMessages();

  for (var message in messages) {
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(message['content']),
          if (message['mediaPath'] != null)
            pw.Text('Media: ${message['mediaPath']}'),
        ],
      );
    }));
  }

  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/chat_history.pdf';
  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());
  print('Chat history exported to: $filePath');
}
