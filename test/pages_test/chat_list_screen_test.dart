import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nearby_connections_example/pages/ChatListScreen.dart';
import 'package:flutter_nearby_connections_example/pages/ChatPage.dart';
import 'package:flutter_nearby_connections_example/classes/Global.dart';

void main() {
  testWidgets('ChatListScreen UI Test', (WidgetTester tester) async {
    
    Global.conversations['John Doe'] = {}; // Just a dummy conversation
    Global.messages = []; // Clearing messages for a clean slate

    await tester.pumpWidget(MaterialApp(home: ChatListScreen()));
    
    await tester.pumpAndSettle();

    // Verify that the UI is as expected
    expect(find.text('Chats'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('ChatListScreen Interaction Test', (WidgetTester tester) async {
    
    Global.conversations['John Doe'] = {}; // Just a dummy conversation
    Global.messages = []; // Clearing messages for a clean slate
    
    await tester.pumpWidget(MaterialApp(home: ChatListScreen()));
    
    await tester.pumpAndSettle();

    // Simulate tapping on a conversation
    await tester.tap(find.text('John Doe'));

    // Navigation to ChatPage
    await tester.pumpAndSettle();

    // Verify that we are on the ChatPage
    expect(find.text('Chat with John Doe'), findsOneWidget);
  });
}
