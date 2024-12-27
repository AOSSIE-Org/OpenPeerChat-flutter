import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/pages/auth_fail.dart';
import 'package:flutter_nearby_connections_example/pages/profile.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'classes/global.dart';
import 'encyption/key_storage.dart';
import 'encyption/rsa.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      color: Colors.black87,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[900],
  hintColor: Colors.blueAccent,
  scaffoldBackgroundColor: Colors.grey[850],
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      color: Colors.white70,
    ),
  ),
);

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      initialRoute: '/',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}


Future<void> _authenticate(BuildContext context) async {
  final LocalAuthentication auth = LocalAuthentication();
  bool authenticated = false;

  try {
    authenticated = await auth.authenticate(
      localizedReason: 'Please authenticate to proceed',
      options: const AuthenticationOptions(
        stickyAuth: true,
        sensitiveTransaction: true,
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
  if (!context.mounted) return;
  if (authenticated) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Profile(onLogin: true)),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthFailedPage(onRetry: () => _authenticate(context))),
    );
  }
}

Route<dynamic> generateRoute(RouteSettings settings) {
  return MaterialPageRoute(
    builder: (context) {
      _authenticate(context);
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  );
}

