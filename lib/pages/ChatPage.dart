import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/classes/Payload.dart';
import 'package:nanoid/nanoid.dart';

import '../database/DatabaseHelper.dart';
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

  // Function to fetch messages every time new message is sent
  void refreshMessages() {
    if (Global.conversations[widget.converser] != null) {
      messageList = [];
      Global.conversations[widget.converser]!.forEach((key, value) {
        messageList.add(value);
      });
      if (_scrollController.hasClients)
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
    }
  }

  @override
  void initState() {
    super.initState();
    refreshMessages();
  }

  ScrollController _scrollController = new ScrollController();

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Chat with ' + widget.converser),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .8,
                child: messageList.isEmpty
                    ? Center(
                        child: Text('No messages yet'),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
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
              TextFormField(
                controller: myController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Send Message?',
                  labelText: 'Send Message ',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  var msgId = nanoid(21);
                  var data = {
                    "sender": "$Global.myName",
                    "receiver": "$widget.device.deviceName",
                    "message": "$myController.text",
                    "id": "$msgId",
                    "Timestamp": "${DateTime.now().toUtc().toString()}",
                    "type": "Payload"
                  };
                  Global.cache[msgId] = Payload(
                      msgId,
                      Global.myName,
                      widget.converser,
                      myController.text,
                      DateTime.now().toUtc().toString());
                  insertIntoMessageTable(Payload(
                      msgId,
                      Global.myName,
                      widget.converser,
                      myController.text,
                      DateTime.now().toUtc().toString()));
                  // Global.devices.forEach((element) {
                  //   Global.nearbyService!
                  //       .sendMessage(element.deviceId, Mesagedata);
                  // });
                  // Global.nearbyService!
                  //     .sendMessage(widget.device.deviceId, myController.text);
                  setState(() {
                    // Global.conversations[widget.device.deviceName]![msgId](
                    //     new Msg(
                    //         widget.device.deviceId, myController.text, "sent"));
                    if (Global.conversations[widget.converser] == null) {
                      Global.conversations[widget.converser] = {};
                    }
                    Global.conversations[widget.converser]![msgId] = Msg(
                        myController.text, "sent", data["Timestamp"]!, msgId);

                    insertIntoConversationsTable(
                        Msg(myController.text, "sent", data["Timestamp"]!,
                            msgId),
                        widget.converser);
                  });
                  refreshMessages();
                  myController.clear();
                },
                child: Text("send"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
