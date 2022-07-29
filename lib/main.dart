import 'package:flutter/material.dart';
import 'classes/Global.dart';
import 'package:provider/provider.dart';
import 'pages/Profile.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Global(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

Route<dynamic> generateRoute(RouteSettings settings) {
  return MaterialPageRoute(
    builder: (_) => Profile(
      onLogin: true,
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}
