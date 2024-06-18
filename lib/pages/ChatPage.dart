import 'dart:typed_data';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../components/message_panel.dart';
import '../classes/Msg.dart';
import '../classes/Global.dart';
import 'dart:convert';
import 'package:pointycastle/asymmetric/api.dart';
import '../components/view_file.dart';
import '../encyption/rsa.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key, required this.converser}) : super(key: key);

  final String converser;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  List<Msg> messageList = [];
  TextEditingController myController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  ScrollController _scrollController = ScrollController();

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
          duration: Duration(milliseconds: 300),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ' + widget.converser),
      ),
      body: Column(
        children: [
          Expanded(
            child: messageList.isEmpty
                ? Center(
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
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                              padding: BubbleEdges.all(12),
                              margin: BubbleEdges.only(top: 10),
                              //add shadow
                              style: BubbleStyle(
                                elevation: 3,
                                  shadowColor: Colors.black.withOpacity(0.5),
                              ),
                              // nip: msg.msgtype == 'sent' ? BubbleNip.rightTop : BubbleNip.leftTop,
                              radius: Radius.circular(10),
                              color: msg.msgtype == 'sent' ? Color(0xffd1c4e9) : Color(0xff80DEEA),
                              child: msg.message.contains('file') ? _buildFileBubble(msg) : Text(
                                displayMessage,
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2, bottom: 10),
                            child: Text(
                              dateFormatter(timeStamp: msg.timestamp),
                              style: TextStyle(color: Colors.black54, fontSize: 10),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
          MessagePanel(converser: widget.converser),
        ],
      ),
    );
  }

  Widget _buildFileBubble(Msg msg) {
    dynamic data = jsonDecode(msg.message);
    String fileName = data['fileName'];
    String filePath = data['filePath'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          fileName,
          style: TextStyle(
            // fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          icon: Icon(Icons.file_open, color: Colors.black87),
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
