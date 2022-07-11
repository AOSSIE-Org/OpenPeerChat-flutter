import 'package:pointycastle/api.dart' as crypto;
import 'package:rsa_encrypt/rsa_encrypt.dart';

//Future to hold our KeyPair
Future<crypto.AsymmetricKeyPair>? futureKeyPair;

//to store the KeyPair once we get data from our future
crypto.AsymmetricKeyPair? keyPair;

Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
    getKeyPair() {
  var helper = RsaKeyHelper();
  return helper.computeRSAKeyPair(helper.getSecureRandom());
}

// void createPair() {
//   futureKeyPair = getKeyPair();
//   futureKeyPair.then((value) => keyPair = value);
//   var x = encodePrivateKeyToPemPKCS1(keyPair.privateKey);
// }
