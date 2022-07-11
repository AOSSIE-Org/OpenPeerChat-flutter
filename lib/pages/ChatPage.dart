import 'dart:developer';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/components/message_panel.dart';
import 'package:provider/provider.dart';
import '../classes/Msg.dart';
import '../classes/Global.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key, required this.converser});

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

  ScrollController _scrollController = new ScrollController();

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
    return Scaffold(
      // resizeToAvoidBottomInset: false,
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
                    shrinkWrap: true,
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: messageList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 55,
                        child: messageList[index].msgtype == 'sent'
                            ? Bubble(
                                margin: BubbleEdges.only(top: 10),
                                nip: BubbleNip.rightTop,
                                color: Color(0xffd1c4e9),
                                child: Text(
                                  messageList[index].msgtype +
                                      ": " +
                                      messageList[index].message,
                                  textAlign: TextAlign.right,
                                ),
                              )
                            : Bubble(
                                nip: BubbleNip.leftTop,
                                color: Color(0xff80DEEA),
                                margin: BubbleEdges.only(top: 10),
                                child: Text(
                                  messageList[index].msgtype +
                                      ": " +
                                      messageList[index].message,
                                ),
                              ),
                      );
                    },
                  ),
          ),
          MessagePanel(converser: widget.converser),
        ],
      ),
    );
  }
}
