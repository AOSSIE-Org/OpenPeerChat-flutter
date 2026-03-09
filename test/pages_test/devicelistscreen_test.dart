import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nearby_connections_example/pages/DevicesListScreen.dart';
import 'package:flutter_nearby_connections_example/pages/ChatPage.dart';
import 'package:flutter_nearby_connections_example/classes/Global.dart';

void main() {
  testWidgets('DevicesListScreen UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: DevicesListScreen(deviceType: DeviceType.browser)));
    await tester.pumpAndSettle();

    // Verify that the UI is as expected
    expect(find.text('Available Devices'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('DevicesListScreen Interaction Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: DevicesListScreen(deviceType: DeviceType.browser)));
    await tester.pumpAndSettle();

    // Simulate tapping on the first device in the list
    await tester.tap(find.byType(GestureDetector).first);

    // Wait for animations to complete
    await tester.pumpAndSettle();

    // Verify that we have navigated to ChatPage
    expect(find.byType(ChatPage), findsOneWidget);
  });
}
