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
import 'providers/theme_provider.dart';

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

Future<void> requestPermissions() async {
  try {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Base permissions for all Android versions
      final basePermissions = [
        Permission.storage,
        Permission.microphone,
        Permission.location,
        Permission.bluetooth,
      ];

      // Permissions for Android 12 and above
      final modernPermissions = [
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.nearbyWifiDevices,
      ];

      // Permissions for Android 10 and above
      final storagePermissions = [
        Permission.manageExternalStorage,
      ];

      final permissions = [...basePermissions];

      if (sdkInt >= 31) { // Android 12 or higher
        permissions.addAll(modernPermissions);
      }

      if (sdkInt >= 29) { // Android 10 or higher
        permissions.addAll(storagePermissions);
      }

      for (var permission in permissions) {
        if (await permission.status.isDenied) {
          final status = await permission.request();
          if (status.isPermanentlyDenied) {
            openAppSettings();
            break;
          }
        }
      }
    } else {
      // iOS permissions
      await Permission.microphone.request();
      await Permission.bluetooth.request();
      await Permission.location.request();
    }
  } catch (e) {
    debugPrint('Permission request error: $e');
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
    return Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            theme: themeProvider.theme,
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
