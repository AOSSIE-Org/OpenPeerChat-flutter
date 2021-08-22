import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_nearby_connections_example/classes/Payload.dart';
import 'package:nanoid/nanoid.dart';
import 'package:intl/intl.dart';
import 'package:flutter_nearby_connections_example/p2p/MatrixServerModel.dart';

import '../database/DatabaseHelper.dart';
import '../classes/Msg.dart';
import '../classes/Global.dart';

class ChatPage extends StatefulWidget {
  ChatPage(this.converser);

  final Contact converser;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Msg> messageList = [];

  void initState() {
    Global.conversations[widget.converser]!.forEach((element) {
      element.forEach((key, value) {
        messageList.add(value);
      });
    });
  }

  ScrollController _scrollController = new ScrollController();

  Widget build(BuildContext context) {
    var server = context.watch<MatrixServer>();
    server.server.onEvent((data) {
      print('data: ${data.content['type']}');
      if (data.content['type'] == 'm.room.message') {
        print('data: ${data.content['sender']}');

        print(
            'bool: ${(data.content['sender'] as String).contains(widget.converser.userId!)}');
        // assuming only text will be send for now
        if ((data.content['sender'] as String)
            .contains(widget.converser.userId!)) {
          // save to db
          String msg = data.content['content']['body'];
          String sender = widget.converser.userId!;
          String timestamp = DateTime.now().toUtc().toString();
          print('data: ${msg}');
          var msgId = nanoid(21);
          setState(() {
            Global.conversations[widget.converser]!
                .add({msgId: Msg(msg, "received", timestamp, msgId)});
            insertIntoConversationsTable(Msg(msg, "received", timestamp, msgId),
                widget.converser.userId!);
          });
        }
      }
    });
    final myController = TextEditingController();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Chat with ' + widget.converser.displayName),
        ),
        body: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * .8,
                    child: Global.conversations[widget.converser] == null
                        ? Text("no messages")
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            // reverse: true,
                            controller: _scrollController,
                            padding: const EdgeInsets.all(8),
                            itemCount:
                                messageList == null ? 0 : messageList.length,
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
                                            textAlign: TextAlign.right),
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
                      onPressed: () async {
                        var message = await server.server.sendMessage(
                            widget.converser.userId!, myController.text,
                            roomId: widget.converser.roomId!);
                        print("message send to ${widget.converser.roomId!}");
                        print("message: $message");
                        var msgId = nanoid(21);
                        var data = {
                          "sender": "${Global.myName}",
                          "receiver": "$widget.device.deviceName",
                          "message": "$myController.text",
                          "id": "$msgId",
                          "Timestamp": "${DateTime.now().toUtc().toString()}",
                          "type": "Payload"
                        };
                        var Mesagedata = data.toString();
                        try {
                          Global.cache[msgId] = Payload(
                              msgId,
                              Global.myName,
                              widget.converser.displayName,
                              myController.text,
                              DateTime.now().toUtc().toString());
                          insertIntoMessageTable(Payload(
                              msgId,
                              Global.myName,
                              widget.converser.displayName,
                              myController.text,
                              DateTime.now().toUtc().toString()));
                          // Global.devices.forEach((element) {
                          //   Global.nearbyService!
                          //       .sendMessage(element.deviceId, Mesagedata);
                          // });
                          // Global.nearbyService!
                          //     .sendMessage(widget.device.deviceId, myController.text);
                        } finally {
                          setState(() {
                            // Global
                            //     .conversations[widget.device.deviceName][msgId](new Msg(widget.device.deviceId,
                            //         myController.text, "sent"));
                            Msg msg = Msg(myController.text, "sent",
                                data["Timestamp"]!, msgId);
                            Global.conversations[widget.converser]!
                                .add({msgId: msg});
                            messageList.add(msg);

                            insertIntoConversationsTable(
                                msg, widget.converser.displayName);
                          });
                        }
                      },
                      child: Text("send")),
                ],
              ),
            )));
  }
}
