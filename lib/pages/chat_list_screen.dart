import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import 'package:flutter/material.dart';
import '../classes/global.dart';
import 'chat_page.dart';

/// This is ChatListScreen. This screen lists all the Devices with which the
/// device has chat with and keeps all the previous messages records.

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
 State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool isLoading = false;
  List<String> conversers = [];
  // In the init state, we need to update the cache everytime.
  @override
  void initState() {
    super.initState();
    readAllUpdateCache();
  }

  @override
  Widget build(BuildContext context) {
    // Whenever the the UI is built, each converser is added to the list
    // from the conversations map that stores the key as name of the device.
    // The names are inserted into the list conversers here and then displayed
    // with the help of ListView.builder.
    conversers = [];
    Provider.of<Global>(context).conversations.forEach((key, value) {
      conversers.add(key);
    });
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
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
              contentPadding: const EdgeInsets.all(8),
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
                    // Whenever tapped on the Device tile, it navigates to the
                    // chatpage
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
