import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> savePrivateKey(String privateKey) async {
    await _storage.write(key: 'privateKey', value: privateKey);
  }

  Future<String?> getPrivateKey() async {
    return await _storage.read(key: 'privateKey');
  }

  Future<void> savePublicKey(String publicKey) async {
    await _storage.write(key: 'publicKey', value: publicKey);
  }

  Future<String?> getPublicKey() async {
    return await _storage.read(key: 'publicKey');
  }
}
