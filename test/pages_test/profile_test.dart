import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nearby_connections_example/pages/Profile.dart';
import 'package:flutter_nearby_connections_example/pages/DeviceListScreen.dart';
import 'package:nanoid/nanoid.dart';
import '../classes/Global.dart';

void main() {
  testWidgets('Profile UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Profile()));

    // Verify that the app has the expected text.
    expect(find.text("Your Username will be your name+\$custom_length_id"), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Profile Interaction Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Profile()));

    // Enter a name into the TextFormField.
    await tester.enterText(find.byType(TextFormField), 'JohnDoe');

    // Tap on the save button.
    await tester.tap(find.text('Save'));
    await tester.pump();

    // Verify that the Global.myName is updated.
    expect(Global.myName, 'JohnDoe');

    // Verify that the navigation to DeviceListScreen occurs.
    expect(find.byType(DevicesListScreen), findsOneWidget);
  });
}
