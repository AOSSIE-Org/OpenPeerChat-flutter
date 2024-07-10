import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final LocalAuthentication auth;
  bool _supportState = false;

  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
    auth
        .isDeviceSupported()
        .then((isSupported) => setState(() => _supportState = isSupported));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_supportState)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Authentication is supported',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ElevatedButton(
                onPressed: _supportState ? _authenticate : _authenticate2,
                child: const Text('Authenticate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _authenticate2() async {
   if (kDebugMode) {
     print('Authentication is not supported');
   }
   Navigator.pushReplacement(
     context,
     MaterialPageRoute(
       builder: (context) => const Profile(onLogin: true),
     ),
   );
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate for access',
        options: const AuthenticationOptions(
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );
      if (kDebugMode) {
        print(authenticated);
      }
      if (authenticated) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Profile(onLogin: true),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
