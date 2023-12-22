import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nearby_connections_example/pages/ChatPage.dart';
import 'package:flutter_nearby_connections_example/classes/Global.dart';

void main() {
  testWidgets('ChatPage UI Test', (WidgetTester tester) async {
    final String converser = 'John Doe';
    await tester.pumpWidget(MaterialApp(home: ChatPage(converser)));
    await tester.pumpAndSettle();

    // Verify that the UI is as expected
    expect(find.text('Chat with $converser'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('ChatPage Interaction Test', (WidgetTester tester) async {
    final String converser = 'John Doe';
    await tester.pumpWidget(MaterialApp(home: ChatPage(converser)));
    await tester.pumpAndSettle();

    // Enter Text
    await tester.enterText(find.byType(TextFormField), 'Hello, John!');
    
    // Tap the send button
    await tester.tap(find.byType(ElevatedButton));
    
    // Wait for animations to complete
    await tester.pumpAndSettle();

    // Verify that the message is sent
    expect(find.text('sent: Hello, John!'), findsOneWidget);
  });
}
