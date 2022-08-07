import 'package:provider/provider.dart';

import '../database/DatabaseHelper.dart';

import 'package:flutter/material.dart';

import '../classes/Global.dart';

import 'ChatPage.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool isLoading = false;
  List<String> conversers = [];

  @override
  void initState() {
    super.initState();
    readAllUpdateCache();
  }

  @override
  Widget build(BuildContext context) {
    conversers = [];
    Provider.of<Global>(context).conversations.forEach((key, value) {
      conversers.add(key);
    });
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.all(8),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade100)),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: conversers.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(conversers[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          converser: conversers[index],
                        ),
                      ),
                    );
                  },
                );
              }),
        )
      ],
    );
  }
}
