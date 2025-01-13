import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/pages/auth_fail.dart';
import 'package:flutter_nearby_connections_example/pages/profile.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'classes/global.dart';
import 'encyption/key_storage.dart';
import 'encyption/rsa.dart';
import 'classes/themeProvider.dart';

Future<void> requestPermissions() async {
  final permissions = [
    Permission.storage,
    Permission.microphone,
    Permission.manageExternalStorage,
    Permission.nearbyWifiDevices,
    Permission.location,
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect
  ];

  for (var permission in permissions) {
    if (await permission.status.isDenied) {
      final status = await permission.request();
      if (status.isPermanentlyDenied) {
        openAppSettings();
        break;
      }
    }
  }
}





void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request permissions first
  await requestPermissions();

  final keyStorage = KeyStorage();

  String? privateKeyPem = await keyStorage.getPrivateKey();
  String? publicKeyPem = await keyStorage.getPublicKey();

  if (privateKeyPem == null || publicKeyPem == null) {
    final pair = generateRSAkeyPair(exampleSecureRandom());
    privateKeyPem = encodePrivateKeyToPem(pair.privateKey);
    publicKeyPem = encodePublicKeyToPem(pair.publicKey);

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: generateRoute,
            initialRoute: '/',
          );
        }
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
