import 'dart:typed_data';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../components/message_panel.dart';
import '../classes/msg.dart';
import '../classes/global.dart';
import 'dart:convert';
import 'package:pointycastle/asymmetric/api.dart';
import '../components/view_file.dart';
import '../encyption/rsa.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String themePreferenceKey = 'themePreference';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      color: Colors.black87,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[900],
  hintColor: Colors.blueAccent,
  scaffoldBackgroundColor: Colors.grey[850],
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      color: Colors.white70,
    ),
  ),
);

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.converser}) : super(key: key);

  final String converser;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  List<Msg> messageList = [];
  TextEditingController myController = TextEditingController();
  
  //initial theme of the system
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeIndex = prefs.getInt(themePreferenceKey);
    if (themeIndex != null) {
      setState(() {
        _themeMode = ThemeMode.values[themeIndex];
      });
    }
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themePreferenceKey, mode.index);
  }

  void _toggleTheme(bool value) {
    setState(() {
      _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    });
    _saveTheme(_themeMode);
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (Provider.of<Global>(context).conversations[widget.converser] != null) {
      messageList = [];
      Provider.of<Global>(context)
          .conversations[widget.converser]!
          .forEach((key, value) {
        messageList.add(value);
      });

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 50,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }

    Map<String, List<Msg>> groupedMessages = {};
    for (var msg in messageList) {
      String date = DateFormat('dd/MM/yyyy').format(DateTime.parse(msg.timestamp));
      if (groupedMessages[date] == null) {
        groupedMessages[date] = [];
      }
      groupedMessages[date]!.add(msg);
    }
      return Theme(
        data: ThemeData(
          brightness: _themeMode == ThemeMode.dark
              ? Brightness.dark
              : Brightness.light,
        ),
        child:
       Scaffold(
        appBar: AppBar(
          title: Text(widget.converser),
          actions: [
            Switch(
                  value: _themeMode == ThemeMode.dark,
                  onChanged: _toggleTheme,
                  activeColor: Colors.blueAccent,
                  inactiveThumbColor: Colors.grey,
                ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: messageList.isEmpty
                  ? const Center(
                child: Text('No messages yet'),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: groupedMessages.keys.length,
                itemBuilder: (BuildContext context, int index) {
                  String date = groupedMessages.keys.elementAt(index);
                  return Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            date,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ...groupedMessages[date]!.map((msg) {
                        String displayMessage = msg.message;
                        if (Global.myPrivateKey != null) {
                          RSAPrivateKey privateKey = Global.myPrivateKey!;
                          dynamic data = jsonDecode(msg.message);
                          if (data['type'] == 'text') {
                            Uint8List encryptedBytes = base64Decode(data['data']);
                            Uint8List decryptedBytes = rsaDecrypt(privateKey, encryptedBytes);
                            displayMessage = utf8.decode(decryptedBytes);
                          }
                        }
                        return Column(
                          crossAxisAlignment: msg.msgtype == 'sent' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: msg.msgtype == 'sent' ? Alignment.centerRight : Alignment.centerLeft,
                              child: Bubble(
                                padding: const BubbleEdges.all(12),
                                margin: const BubbleEdges.only(top: 10),
                                //add shadow
                                style: BubbleStyle(
                                  elevation: 3,
                                    shadowColor: Colors.black.withOpacity(0.5),
                                ),
                                // nip: msg.msgtype == 'sent' ? BubbleNip.rightTop : BubbleNip.leftTop,
                                radius: const Radius.circular(10),
                                color: msg.msgtype == 'sent' ? const Color(0xffd1c4e9) : const Color(0xff80DEEA),
                                child: msg.message.contains('file') ? _buildFileBubble(msg) : Text(
                                  displayMessage,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 2, bottom: 10),
                              child: Text(
                                dateFormatter(timeStamp: msg.timestamp),
                                style: const TextStyle(color: Colors.black54, fontSize: 10),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            MessagePanel(converser: widget.converser),
          ],
        ),
      )
    );
  }

  Widget _buildFileBubble(Msg msg) {
    dynamic data = jsonDecode(msg.message);
    String fileName = data['fileName'];
    String filePath = data['filePath'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            fileName,
            style: const TextStyle(
              color: Colors.black87,
            ),
            overflow: TextOverflow.visible,

          ),
        ),
        IconButton(
          icon: const Icon(Icons.file_open, color: Colors.black87),
          onPressed: () {
            FilePreview.openFile(filePath);
          },
        ),
      ],
    );
  }
}

String dateFormatter({required String timeStamp}) {
  DateTime dateTime = DateTime.parse(timeStamp);
  String formattedTime = DateFormat('hh:mm aa').format(dateTime);
  return formattedTime;
}
