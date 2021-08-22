import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/Profile.dart';
import 'p2p/MatrixServerModel.dart';

void main() {
  runApp(MyApp());
}

Route<dynamic> generateRoute(RouteSettings settings) {
  return MaterialPageRoute(builder: (_) => Profile());
}

class MyApp extends StatelessWidget {
  void initState() {}
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MatrixServer())],
      child: const MaterialApp(
        onGenerateRoute: generateRoute,
        initialRoute: '/',
      ),
    );
  }
}
