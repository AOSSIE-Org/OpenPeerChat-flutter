import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'classes/global.dart';
import 'encyption/key_storage.dart';
import 'encyption/rsa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyStorage = KeyStorage();

  // Check if keys already exist
  String? privateKeyPem = await keyStorage.getPrivateKey();
  String? publicKeyPem = await keyStorage.getPublicKey();

  if (privateKeyPem == null || publicKeyPem == null) {
    // Generate RSA key pair
    final pair = generateRSAkeyPair(exampleSecureRandom());
    privateKeyPem = encodePrivateKeyToPem(pair.privateKey);
    publicKeyPem = encodePublicKeyToPem(pair.publicKey);

    // Store keys
    await keyStorage.savePrivateKey(privateKeyPem);
    await keyStorage.savePublicKey(publicKeyPem);
  }

  Global.myPrivateKey = parsePrivateKeyFromPem(privateKeyPem);
  Global.myPublicKey = parsePublicKeyFromPem(publicKeyPem);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Global(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}

Route<dynamic> generateRoute(RouteSettings settings) {
  return MaterialPageRoute(
    builder: (_) => const HomePage(),
  );
}
