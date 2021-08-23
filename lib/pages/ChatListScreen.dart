import 'package:flutter_nearby_connections_example/database/DatabaseHelper.dart';

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
    refreshMessages();
    Global.conversations.forEach((key, value) {
      conversers.add(key);
    });
    print(" 37 reloaded:" + Global.cache.toString());
  }

  Future refreshMessages() async {
    setState(() => isLoading = true);

    readAllUpdateCache();
    readAllUpdateConversation();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text("Chats"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work),
            title: Text("Available"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            title: Text("Profile"),
          ),
        ],
      ),
      body: Container(
          child: Column(
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
          ListView.builder(
              itemCount: conversers.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ChatPage(conversers[index]);
                                  },
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Text(conversers[index]),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          )),
                          // Request connect
                        ],
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey,
                      ),
                      Text("hello"),
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: Global.messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 15,
                              // color: Colors.amber[colorCodes[index]],
                              child: Center(
                                  child: Text(Global.messages[index].msgtype +
                                      ":" +
                                      " " +
                                      Global.messages[index].message)),
                            );
                          }),
                    ],
                  ),
                );
              })
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
